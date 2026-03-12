---
title: Music Player Feature
description: Documentation for the core playback engine, queue management, and UI controls.
tags: [feature, audio, bloc, state-management]
---

# Music Player Feature

> **Context:** This feature manages the foreground UI and BLoC state for audio playback. It interacts with the `Background Audio` service.

## Overview
The **Music Player** feature serves as the visual interface for the audio engine. It orchestrates user intents (Play, Pause, Seek) and visualizes the current playback state (Progress, Metadata, Queue).

## Architecture

This feature follows the **Clean Architecture** pattern:

*   **Presentation:** `MusicPlayerBloc` receives UI events and maps them to Use Cases.
*   **Domain:** Use Cases like `PlaySong`, `ToggleShuffle` abstract the logic.
*   **Data:** Repositories interact with the `AudioHandler` (Background Service).

## Usage Guide (How-To)

### Controlling Playback Programmatically
To control the player from anywhere in the app, dispatch events to the `MusicPlayerBloc`.

### Code Example: Controlling the Player
```dart
// IMPORTS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';

// LOGIC
void togglePlayback(BuildContext context) {
  // Dispatches a simple event to toggle state
  context.read<MusicPlayerBloc>().add(
    const MusicPlayerEvent.togglePlayPause(),
  );
}

void playSpecificSong(BuildContext context, SongEntity song) {
  // Starts playback of a new song
  context.read<MusicPlayerBloc>().add(
    MusicPlayerEvent.playSong(song: song),
  );
}
```

## Reference: Events

The `MusicPlayerEvent` union class defines all possible interactions.

| Event | Description |
| :--- | :--- |
| `playSong({required SongEntity song})` | Starts playing a specific song immediately. |
| `toggleShuffle()` | Toggles the shuffle mode in the underlying service. |
| `cycleLoopMode()` | Cycles between Off -> All -> One. |
| `reorderQueue(oldIndex, newIndex)` | Drag-and-drop queue management. |
| `addToQueue(SongEntity song)` | Appends a song to the end of the current queue. |

## UI Components

*   **`MusicPlayerPage`:** The full-screen immersive player with physics-based drag-to-dismiss.
*   **`MiniPlayer`:** The persistent bottom bar shown when audio is active but the player is minimized.
*   **`QueueSheet`:** A modal bottom sheet displaying the current playlist.
