---
title: Music Player Feature
description: Playback BLoC, queue management, sleep timer, mini player, and queue sheet.
tags: [feature, audio, bloc, queue, sleep-timer, mini-player]
---

# Music Player Feature

> **Prerequisites:** `MusicPlayerHandler` (background audio service) and
> `AudioPlayerRepository` must be initialized before this feature's BLoC is created.
> See [`docs/features/background_notifications.md`](background_notifications.md).

## Overview

The Music Player feature is the UI-facing state machine for audio playback. `MusicPlayerBloc`
owns the queue, current song, playback controls, and sleep timer. It subscribes to streams
from `AudioPlayerRepository` and translates them into `MusicPlayerState` that the rest of
the app consumes. The full-screen player, mini player, and queue sheet all read from this
single BLoC instance.

---

## Architecture

```
music_player/
├── data/
│   └── repos/
│       └── audio_player_repository_impl.dart  # Wraps AudioHandler methods
├── domain/
│   └── repos/
│       └── audio_player_repository.dart        # Abstract interface
└── presentation/
    ├── bloc/
    │   ├── music_player_bloc.dart
    │   ├── music_player_event.dart
    │   └── music_player_state.dart
    ├── pages/
    │   └── music_player_page.dart              # Full-screen player
    └── widgets/
        ├── mini_player.dart                    # Persistent bottom bar
        ├── queue_sheet.dart                    # Reorderable modal queue
        ├── lyrics_sheet.dart
        └── sleep_timer_sheet.dart
```

---

## `MusicPlayerState`

The state is a single `freezed` data class (not a sealed union). All fields have defaults
so the BLoC starts with a valid, empty state.

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `isPlaying` | `bool` | `false` | Reactive — driven by `isPlayingStream`. |
| `position` | `Duration` | `Duration.zero` | Throttled to 500ms updates. |
| `duration` | `Duration` | `Duration.zero` | Updated from `durationStream`. |
| `currentSong` | `SongEntity?` | `null` | The song currently loaded in the engine. |
| `queue` | `List<SongEntity>` | `[]` | Full ordered queue. |
| `currentIndex` | `int` | `0` | Index of `currentSong` in `queue`. |
| `isShuffling` | `bool` | `false` | Reactive — driven by `isShuffleModeEnabledStream`. |
| `loopMode` | `int` | `0` | `0` = off, `1` = all, `2` = one. |
| `playCounts` | `Map<int, int>` | `{}` | Song ID → total play count from analytics DB. |
| `queueActionStatus` | `QueueStatus` | `initial` | `initial` / `success` / `failure`. |
| `errorMessage` | `String` | `''` | Set alongside `queueActionStatus.failure`. |
| `timerRemaining` | `Duration?` | `null` | Countdown timer; `null` means no timer active. |
| `isEndTrackTimerActive` | `bool` | `false` | Stop at end of current track instead of countdown. |

---

## `MusicPlayerEvent` — Full Reference

### User Actions

| Event | Parameters | Description |
| :--- | :--- | :--- |
| `initMusicQueue` | `songs`, `currentIndex` | Replaces queue and starts playback. Emits optimistic state immediately before the engine loads. |
| `playSong` | `song: SongEntity` | Plays a single song directly via `AudioPlayerRepository.playSong`. |
| `playSongById` | `songId: int` | Resolves the song via `GetSongByIdUseCase`, then dispatches `playSong`. |
| `pause` | — | Pauses playback. |
| `resume` | — | Resumes playback. |
| `seek` | `Duration` | Seeks to a position; emits optimistic state immediately. |
| `playPreviousSong` | — | Calls `skipToPrevious()` on the repository. |
| `playNextSong` | — | Calls `skipToNext()` on the repository. |
| `toggleShuffle` | — | Flips `isShuffling` optimistically, then calls `setShuffleMode`. |
| `cycleLoopMode` | — | Cycles `loopMode` 0 → 1 → 2 → 0, then calls `setRepeatMode`. |
| `addToQueue` | `SongEntity` | Appends to end of queue. Sets `queueActionStatus`. |
| `playNextinQueue` | `SongEntity` | Inserts immediately after current index. |
| `removeFromQueue` | `index: int` | Removes by index. |
| `reorderQueue` | `oldIndex`, `newIndex` | Moves an item; sets `_reorderPending` flag. |
| `playQueueItem` | `index: int` | Jumps to a queue position via `skipToQueueItem`. |

### Sleep Timer

| Event | Parameters | Description |
| :--- | :--- | :--- |
| `setTimer` | `duration: Duration` | Starts a countdown. Cancels any existing timer. |
| `setEndTrackTimer` | `active: bool` | Stop playback at the end of the current track. |
| `cancelTimer` | — | Cancels countdown and clears state. |
| `tickTimer` | — | Internal — emitted every second by a `Timer.periodic`. |

### Internal Stream Events (Not dispatched by UI)

| Event | Description |
| :--- | :--- |
| `updatePosition` | From throttled `positionStream` (500ms intervals). |
| `updateDuration` | From `durationStream`. |
| `updatePlayerState` | From `isPlayingStream`. |
| `updateShuffleState` | From `isShuffleModeEnabledStream`. |
| `updateLoopState` | From `loopModeStream`. |
| `updateCurrentSong` | From `currentSongStream`. Suppressed during queue load (see guards below). |
| `queueUpdated` | From `queueStream`. Re-anchors `currentSong` to `queue[currentIndex]`. |
| `updatePlayCounts` | Populated from `GetAllSongPlayCounts` on BLoC creation. |
| `songFinished` | From `playerCompleteStream`. Sets `isPlaylistEnd = true`. |

---

## Queue Load Guard (`_isLoadingQueue`)

When `initMusicQueue` is dispatched, the BLoC emits optimistic state immediately (correct
song, correct index). However, `just_audio` emits a spurious `sequenceStateStream` event
during `setAudioSources` initialization, which would overwrite the optimistic state with
the wrong song.

`_isLoadingQueue` is set to `true` before `setQueue` is called. The `updateCurrentSong`
handler checks this flag:

1. Resets `_isLoadingQueue = false` unconditionally (to prevent the flag from getting stuck).
2. Compares the stream emission against the optimistic state.
3. If the stream contradicts the correct optimistic song, the event is discarded.

> **Critical:** The flag is always reset first, before the discard check. The original
> implementation returned early without resetting, permanently blocking all subsequent
> `updateCurrentSong` events (including legitimate auto-advance). This was a known bug —
> see the comment in `music_player_bloc.dart`.

---

## Queue Reorder Guard (`_reorderPending`)

Reordering the queue causes `queueStream` and `currentSongStream` to both emit. If the
`currentSongStream` emission arrives before `queueStream`, it may reference stale index
data and show the wrong song in the mini player momentarily.

`_reorderPending` suppresses spurious `updateCurrentSong` events while a reorder is in
flight. `queueUpdated` then re-anchors `currentSong` to the correct `queue[newIndex]`.
A 300ms `Timer` clears the flag after `queueUpdated` settles.

---

## How-To: Start Playing a Queue

Dispatch `initMusicQueue` with the full list and the index of the tapped song:

```dart
import 'package:osserva/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_event.dart';

void playSongFromList(
  BuildContext context,
  List<SongEntity> allSongs,
  int tappedIndex,
) {
  context.read<MusicPlayerBloc>().add(
    MusicPlayerEvent.initMusicQueue(
      songs: allSongs,
      currentIndex: tappedIndex,
    ),
  );
}
```

## How-To: Add to Queue from Anywhere

```dart
context.read<MusicPlayerBloc>().add(
  MusicPlayerEvent.addToQueue(song),
);
```

Listen to `queueActionStatus` in the BLoC state for feedback:

```dart
BlocListener<MusicPlayerBloc, MusicPlayerState>(
  listenWhen: (p, c) => p.queueActionStatus != c.queueActionStatus,
  listener: (context, state) {
    if (state.queueActionStatus == QueueStatus.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Added to queue')),
      );
    }
  },
)
```

## How-To: Set a Sleep Timer

```dart
// Countdown timer (e.g., 30 minutes)
context.read<MusicPlayerBloc>().add(
  const MusicPlayerEvent.setTimer(duration: Duration(minutes: 30)),
);

// Stop at end of current track
context.read<MusicPlayerBloc>().add(
  const MusicPlayerEvent.setEndTrackTimer(active: true),
);

// Cancel
context.read<MusicPlayerBloc>().add(const MusicPlayerEvent.cancelTimer());
```

---

## Mini Player

`MiniPlayer` is a persistent widget rendered at the bottom of the `HomeRoute` scaffold,
above the navigation bar. It is only visible when `currentSong != null`.

Key implementation details:

- Uses a `PageView` over the queue list so the user can swipe between songs without opening
  the full player. Swiping dispatches `initMusicQueue` with the new index.
- A `UserScrollNotification` listener sets `_isUserScrolling` to prevent programmatic page
  jumps conflicting with user drags.
- Artwork uses a `Hero` tag `'currentArtwork'` shared with `MusicPlayerPage` for a smooth
  expand animation on tap.
- `flightShuttleBuilder` always uses the **source** hero's child to avoid a blank frame
  during the Hero flight (the destination's `QueryArtworkWidget` would trigger a fresh async
  load).
- Tapping or swiping up opens `MusicPlayerPage` on the root router:
  `context.router.root.push(MusicPlayerRoute(...))`.

## Queue Sheet

`QueueSheet` is a modal bottom sheet (`showModalBottomSheet`) displaying a
`ReorderableListView` of the current queue.

- Drag handle (`ReorderableDragStartListener`) for reordering — dispatches `reorderQueue`.
- Swipe-to-dismiss removes the item — dispatches `removeFromQueue`.
- Tap plays the item immediately — dispatches `playQueueItem`.
- The currently playing song is highlighted with `AppPallete.accent` text and a `graphic_eq`
  icon instead of the drag handle.
- Uses `ValueKey(song.uniqueId ?? '${song.id}_$index')` for stable keys across reorders.

---

## Troubleshooting

| Symptom | Probable Cause | Fix |
| :--- | :--- | :--- |
| Mini player flickers wrong song on first tap | `_isLoadingQueue` stuck `true` from a previous bug | Ensure `_isLoadingQueue = false` is set **before** the discard check in `updateCurrentSong`. |
| Queue reorder shows wrong current song briefly | Reorder guard not active | Verify `_reorderPending = true` is set in `reorderQueue` and that `queueUpdated` sets `anchoredSong`. |
| `addToQueue` succeeds but no snackbar shown | `queueActionStatus` not observed in listener | Add a `BlocListener` with `listenWhen` on `queueActionStatus` changes. |
| Sleep timer doesn't stop playback | `tickTimer` event not firing | Verify `_sleepTimer` is not cancelled prematurely. Check `cancelTimer` isn't dispatched unintentionally. |
| `playSongById` never plays | `GetSongByIdUseCase` returns failure | Confirm the song ID exists in the MediaStore. `queryAudiosFrom` uses `ALBUM_ID` — verify the correct ID type is passed. |
