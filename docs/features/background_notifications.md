---
title: Background Audio & Notifications
description: Documentation for the background audio service, media notifications, and OS integration using audio_service and just_audio.
tags: [feature, audio, background, notification, android, ios]
---

# Background Audio & Notifications

> **Context/Prerequisite:** This feature relies on `audio_service` for OS integration and `just_audio` for playback. It requires platform-specific configuration in `AndroidManifest.xml` and `Info.plist`.

## Overview
The **Background Notification Feature** is the engine room of the Music Player application. It allows audio to continue playing when the app is minimized or the screen is locked. It also provides the "Now Playing" notification with interactive controls (Play/Pause, Skip, Seek) that integrate directly with the operating system's media session (Android Auto, Lock Screen, Control Center).

This feature acts as the **Single Source of Truth** for the playback state. The UI (Flutter widgets) does not manage the player directly; instead, it listens to the state broadcast by this background service.

## Architecture (The "Source of Truth")

This feature implements the **Adapter Pattern** by wrapping the `just_audio` player within an `audio_service` `BaseAudioHandler`.

### Core Components
1.  **`MusicPlayerHandler` (The Service):** A singleton service that runs potentially in a separate isolate (on Android) or a background mode (iOS). It manages:
    *   **The Audio Player:** An instance of `just_audio`'s `AudioPlayer`.
    *   **The Queue:** The playlist of songs currently scheduled for playback.
    *   **The Notification:** The visual controls shown in the notification shade.
    *   **OS Interruptions:** Handling phone calls, headset unplugging, and other audio focus events.

2.  **Data Flow:**
    *   **UI -> Handler:** The UI sends *commands* (e.g., `play()`, `skipToNext()`, `addQueueItem()`) to the `MusicPlayerHandler`.
    *   **Handler -> OS:** The Handler updates the `playbackState` and `mediaItem` streams, which `audio_service` translates into OS-level media session updates.
    *   **Handler -> UI:** The UI listens to these same streams to update the progress bar, play button, and song title.

## Usage Guide (How-To)

### 1. Initializing the Service
The service must be initialized early in the app lifecycle (typically in `main.dart` or a DI container).

```dart
// IMPORTS
import 'package:audio_service/audio_service.dart';
import 'package:music_player/features/background-notification-feature/data/datasources/audio_handler.dart';

// LOGIC
Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MusicPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.mycompany.musicplayer.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
    ),
  );
}
```

### 2. Playing a Playlist (Queue)
To start playing a list of songs, use `setQueueItems`. This replaces the current queue.

```dart
// IMPORTS
import 'package:audio_service/audio_service.dart';

// LOGIC
Future<void> playAlbum(AudioHandler handler, List<Song> songs, int startIndex) async {
  // Convert domain entities to MediaItems
  final mediaItems = songs.map((song) => MediaItem(
    id: song.path, // Use file path as ID
    title: song.title,
    artist: song.artist,
    artUri: Uri.parse(song.albumArt),
    extras: {'url': song.path}, // CRITICAL: Pass the actual URL in extras
  )).toList();

  // Send to handler
  // Cast to MusicPlayerHandler to access custom methods if not exposed via extensions
  final playerHandler = handler as MusicPlayerHandler; 
  await playerHandler.setQueueItems(
    items: mediaItems,
    initialIndex: startIndex,
  );
}
```

### 3. Adding to Queue (Play Next)
To insert a song immediately after the current one ("Play Next"):

```dart
await (handler as MusicPlayerHandler).insertNextQueueItem(newMediaItem);
```

## Reference: Key Methods

### `MusicPlayerHandler`

| Method | Description |
| :--- | :--- |
| `play()` / `pause()` | Toggles playback state. |
| `skipToNext()` | Advances to the next item in the queue. |
| `seek(Duration position)` | Seeks to a specific timestamp in the current track. |
| `setQueueItems(...)` | **Custom:** Replaces the entire queue and starts playback. Required for playlist changes. |
| `addQueueItem(MediaItem)` | Adds a track to the end of the queue. |
| `insertNextQueueItem(MediaItem)` | **Custom:** Inserts a track immediately after the current playing index. |
| `setShuffleMode(...)` | Toggles shuffle. Note: This modifies the internal index mapping, not the queue list itself. |
| `setRepeatMode(...)` | Toggles repeat modes (Off, One, All). |

## Troubleshooting

### Notification Controls Missing?
*   **Cause:** The `_broadcastState()` method builds the list of controls. If the player state (Playing/Paused) isn't synchronized, controls might disappear.
*   **Fix:** Ensure `_initPlayerListeners` is subscribing to all `just_audio` streams (`playerStateStream`, `processingStateStream`, etc.).

### "Loading Interrupted" Error
*   **Cause:** Calling `setQueueItems` (which calls `setAudioSource`) too quickly while another load is in progress.
*   **Fix:** The handler catches this specific error to prevent crashes, but UI debounce logic might be needed for rapid user taps.

### Audio Stops When Backgrounded
*   **Cause:** Android configuration missing.
*   **Fix:** Ensure `AndroidManifest.xml` has `WAKE_LOCK` and `FOREGROUND_SERVICE` permissions, and the `MainActivity` is configured correctly for `audio_service`.
