---
title: Background Audio & Notifications
description: Background audio service, Android media session integration, and OS notification controls.
tags: [feature, audio, background, notification, android, audio_service, just_audio]
---

# Background Audio & Notifications

> **Prerequisites:** Requires `audio_service ^0.18.18` and `just_audio ^0.10.5`. Platform
> permissions (`WAKE_LOCK`, `FOREGROUND_SERVICE`) must be declared in `AndroidManifest.xml`.
> The handler is initialized in `initDependencies()` before any feature module runs.

## Overview

This feature bridges `just_audio` (the audio decoding engine) with Android's media session
system via `audio_service`. It allows playback to continue when the app is backgrounded or
the screen is locked, and exposes interactive controls in the notification shade, lock screen,
and Bluetooth/headset buttons. `MusicPlayerHandler` is the single source of truth for
playback state that both the OS and the UI read from.

---

## Architecture

```
background_notification/
└── data/
    └── datasources/
        └── audio_handler.dart    # MusicPlayerHandler — the only file in this feature
```

`MusicPlayerHandler` extends `BaseAudioHandler` (from `audio_service`) and mixes in
`QueueHandler` and `SeekHandler`. It owns a `just_audio` `AudioPlayer` instance (injected
from the DI singleton) and registers all state listeners on construction.

### Component Relationships

```
MusicPlayerBloc / UI
        │  method calls
        ▼
AudioPlayerRepository          ← domain interface
        │
AudioPlayerRepositoryImpl
        │
MusicPlayerHandler             ← singleton registered as AudioHandler
    ├── AudioPlayer (just_audio)
    │       └── stream listeners → _broadcastState()
    └── audio_service
            └── playbackState / mediaItem streams
                    └── Android MediaSession / Notification / Lock Screen
```

### Initialization

`MusicPlayerHandler` is constructed once in `initDependencies()` and registered as a
singleton under the abstract `AudioHandler` type:

```dart
final audioHandler = await AudioService.init(
  builder: () => MusicPlayerHandler(player: audioPlayer),
  config: const AudioServiceConfig(
    androidNotificationChannelId: 'com.osserva.app.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: false,
  ),
);
serviceLocator.registerSingleton<AudioHandler>(audioHandler);
```

> **`androidStopForegroundOnPause`** is not set (defaults to `false` in the current config).
> This keeps the foreground service alive when paused, which is essential in release builds —
> stopping the foreground service on pause causes the notification to be dismissed and
> resumption to fail silently.

---

## Stream Listeners

`_initPlayerListeners()` subscribes to five `AudioPlayer` streams. Every emission from any
of them calls `_broadcastState()` to keep the OS notification in sync.

| Stream | Purpose |
| :--- | :--- |
| `sequenceStateStream` | Updates `queue` and `mediaItem` when the track or playlist changes. |
| `durationStream` | Updates `mediaItem.duration` once the track is loaded. |
| `playbackEventStream` | Triggers state broadcast on any playback event. |
| `processingStateStream` | Maps `just_audio` processing state to `AudioProcessingState`. |
| `playingStream` | Triggers state broadcast on play/pause transitions. |
| `shuffleModeEnabledStream` | Triggers state broadcast when shuffle is toggled. |
| `loopModeStream` | Triggers state broadcast when repeat mode changes. |

---

## Notification Controls

`_broadcastState()` rebuilds the notification controls dynamically on every state change.
The five-button layout is: `[Shuffle, Previous, Play/Pause, Next, Repeat]`.

The compact notification (small view) shows buttons at indices `[1, 2, 3]` — Previous,
Play/Pause, Next.

Shuffle and Repeat use **custom drawable resources** from `android/app/src/main/res/drawable/`:

| State | Drawable |
| :--- | :--- |
| Shuffle off | `ic_shuffle` |
| Shuffle on | `ic_shuffle_on` |
| Repeat off | `ic_repeat` |
| Repeat all | `ic_repeat_on` |
| Repeat one | `ic_repeat_one` |

Custom button taps are handled in `customAction(name, extras)`. The `name` field maps to
`'shuffle_mode'` or `'repeat_mode'` and cycles the corresponding mode.

---

## How-To: Replace the Queue and Start Playback

`setQueueItems` replaces the entire queue and begins playback from `initialIndex`. This is
the primary entry point called by `MusicPlayerBloc` when the user taps a song.

```dart
import 'package:audio_service/audio_service.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

Future<void> playFromList(
  AudioHandler handler,
  List<SongEntity> songs,
  int startIndex,
) async {
  final items = songs.map((song) => MediaItem(
    id: '${song.id}',
    title: song.title,
    artist: song.artist,
    album: song.album,
    duration: Duration(milliseconds: song.duration),
    artUri: song.albumArt.isNotEmpty ? Uri.file(song.albumArt) : null,
    extras: <String, dynamic>{'url': song.path},
  )).toList();

  await (handler as MusicPlayerHandler).setQueueItems(
    items: items,
    initialIndex: startIndex,
  );
}
```

> **`extras['url']`** is required. `_createSource` reads this key to construct the
> `AudioSource`. Omitting it throws `Exception("Missing URL")`.

---

## How-To: Insert Next in Queue

Inserts a track immediately after the currently playing index.

```dart
await (handler as MusicPlayerHandler).insertNextQueueItem(mediaItem);
```

If the queue is empty, the item is appended instead.

---

## Reference: Key Methods

| Method | Description |
| :--- | :--- |
| `play()` | Resumes or starts playback. |
| `pause()` | Pauses. Foreground service stays alive (see config note). |
| `seek(Duration)` | Seeks to a position in the current track. |
| `skipToNext()` | Calls `_player.seekToNext()`. |
| `skipToPrevious()` | Calls `_player.seekToPrevious()`. |
| `setQueueItems({items, initialIndex})` | **Custom.** Replaces entire queue via `_player.setAudioSources`. |
| `addQueueItem(MediaItem)` | Appends a track via `_player.addAudioSource`. |
| `insertNextQueueItem(MediaItem)` | **Custom.** Inserts at `currentIndex + 1`. |
| `removeQueueItemAt(int)` | Removes by index via `_player.removeAudioSourceAt`. |
| `moveQueueItem(oldIndex, newIndex)` | Reorders via `_player.moveAudioSource`. |
| `skipToQueueItem(int)` | Seeks to index and plays via `_player.seek(Duration.zero, index:)`. |
| `setShuffleMode(AudioServiceShuffleMode)` | Calls `_player.shuffle()` then `setShuffleModeEnabled`. |
| `setRepeatMode(AudioServiceRepeatMode)` | Maps to `LoopMode` and calls `_player.setLoopMode`. |

---

## Troubleshooting

| Symptom | Probable Cause | Fix |
| :--- | :--- | :--- |
| Background playback fails in release APK | R8 strips `audio_service` classes referenced by runtime string lookups | Verify `android/app/src/main/res/raw/keep.xml` contains the AAPT keep directives for `audio_service`. Without this file, release builds silently break. |
| Notification disappears when paused | `androidStopForegroundOnPause` incorrectly set to `true` | Ensure it is `false` (or absent) in `AudioServiceConfig`. |
| Notification controls missing | `_broadcastState()` not triggered after state changes | Verify all five streams are subscribed in `_initPlayerListeners` and that `_subscriptions` is not being cleared prematurely. |
| `setQueueItems` throws "Loading interrupted" | Called while a previous `setAudioSources` is still in progress | `MusicPlayerHandler` catches and swallows this error. Add debounce or loading guards in `MusicPlayerBloc` for rapid taps. |
| Audio stops when backgrounded | Missing `WAKE_LOCK` or `FOREGROUND_SERVICE` permissions | Add both to `AndroidManifest.xml` and verify the service declaration is present. |
| Art missing in notification | `artUri` is `null` | Ensure `artUri` is set on the `MediaItem`. For local files, use `Uri.file(albumArtPath)`. |
