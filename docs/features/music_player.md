---
title: Music Player Controls
description: How to use the core playback controls, queue management, and player settings.
tags: [feature, music-player, user-guide]
---

# Music Player Controls

> **Context/Prerequisite:** A song must be playing or paused to interact with the full music player. The mini-player is visible when a queue is active.

## Overview
The Music Player is the central hub for audio playback. It offers comprehensive controls for the current song, queue management, and settings like shuffle and repeat modes.

## Accessing the Full Player

The full player can be accessed from anywhere in the app by tapping on the **Mini Player** at the bottom of the screen.

## Core Playback Controls

On the full player screen, you will find:
-   **Play/Pause Button:** Toggles playback.
-   **Previous Button:** Skips to the previous song in the queue.
-   **Next Button:** Skips to the next song in the queue.
-   **Seek Bar:** Drag the slider to jump to any point in the current song.

## Queue Management

The player maintains a dynamic queue of songs.
-   **Swipe on Mini Player:** You can quickly skip to the next/previous song by swiping left/right on the mini-player.
-   **Adding Songs:** Songs can be added to the queue from the local music list (left swipe action).

## Player Settings

### Shuffle Mode
-   **Icon:** `Shuffle` icon (often two overlapping arrows).
-   **Function:** Toggles shuffle mode. When active, songs will play in a random order.

### Repeat Mode
-   **Icon:** `Repeat` icon (a circular arrow).
-   **Function:** Toggles through different repeat modes:
    1.  **Repeat Off:** No repetition.
    2.  **Repeat All:** Repeats the entire queue once it finishes.
    3.  **Repeat One:** Repeats the current song indefinitely.

## Technical Details (Reference)

### Audio Engine
The player leverages `just_audio` and `audio_service` for robust background playback and integration with system media controls (lock screen, notifications).

### State Management
The player's state (current song, playback position, play/pause status, shuffle/repeat modes) is managed by `MusicPlayerBloc`.
