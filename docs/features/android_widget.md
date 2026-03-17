# Android Home Screen Widget

The **Android Home Screen Widget** provides a convenient way for users to control playback and view current song information directly from their device's home screen, without needing to open the app.

## Overview

The widget is built using a hybrid approach:
1.  **Native Android UI:** A `RemoteViews` layout (`music_widget.xml`) defines the visual structure.
2.  **HomeWidget Bridge:** Uses the `home_widget` package to sync state between Flutter and Android SharedPreferences.
3.  **Direct Signaling:** To ensure responsiveness when the app is "killed," the native widget sends explicit broadcasts directly to the `AudioService`'s `MediaButtonReceiver`.

## Key Capabilities

-   **Real-time State Sync:** Automatically updates the song title, artist, and play/pause icon.
-   **Album Art Integration:** Displays the current song's album art using Android's `content://` MediaStore URIs.
-   **Cold Start Playback:** If no music is playing and the app is closed, pressing "Play" on the widget triggers the `AudioHandler` to load the local library and start playback from the first song.
-   **Instant Wake-up:** Uses explicit intents to bypass the OS's media session registration delays, ensuring the background engine wakes up immediately on interaction.

## Architecture

### 1. State Synchronization (`WidgetSyncService`)
The `WidgetSyncService` listens to the `MusicPlayerBloc` stream. Whenever the state (current song, playing status, shuffle mode) changes, it saves this data to the `home_widget` SharedPreferences and triggers a widget update.

### 2. Interaction Handling (`MusicPlayerWidget.kt`)
The native Kotlin side handles interactions via `onReceive`:
-   **Play/Pause, Next, Previous:** Sends an `ACTION_MEDIA_BUTTON` intent directly to `com.ryanheise.audioservice.MediaButtonReceiver`. This is more reliable than generic media key dispatch for cold starts.
-   **Shuffle:** Launches the app via a specialized deep link (`audiography://widget/shuffle`) which is caught by the `WidgetSyncService` in the foreground.

### 3. Background Isolate Initialization
When a widget button is pressed while the app is closed:
1.  The `MediaButtonReceiver` starts the `AudioService`.
2.  The Flutter background isolate is spawned.
3.  `initDependencies()` is called, registering the `GetLocalSongsUseCase` and initializing the `MusicPlayerHandler`.
4.  The `AudioHandler` receives the play command and, seeing an empty queue, loads the library to start playback.

## Configuration & Assets

-   **Layout:** `android/app/src/main/res/layout/music_widget.xml`
-   **Metadata:** `android/app/src/main/res/xml/music_widget_info.xml`
-   **Kotlin Provider:** `android/app/src/main/kotlin/com/osserva/app/MusicPlayerWidget.kt`
-   **Flutter Bridge:** `lib/core/services/widget_sync_service.dart`

## Performance & Reliability

-   **Memory:** The native widget consumes minimal resources as it uses `RemoteViews`.
-   **Efficiency:** The `WidgetSyncService` uses a "change detection" check to avoid redundant SharedPreferences writes and widget updates if the data hasn't changed.
-   **Resilience:** The explicit intent targeting ensures the widget remains functional even if the app's process is reclaimed by the OS.
