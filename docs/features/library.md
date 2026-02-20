---
title: Library Feature
description: The aggregator UI that manages local music tracks, playlists, and user permissions.
tags: [ui, navigation, aggregation, search]
---

# Library Feature

> **Context:** This feature is a **Presentation-Layer Aggregator**. It does not own data; it displays data from `local_music` and `playlists` features.

## Overview
The **Library** is the central hub for the user's personal music collection. It serves as the primary "Shell" for browsing content that resides on the device.

**Key Responsibilities:**
1.  **Aggregation:** Combines "Tracks" and "Playlists" into a unified view.
2.  **Permissions:** Manages the critical Android 13+ granular media permissions (`READ_MEDIA_AUDIO`).
3.  **Search:** Provides a Mac-style, blur-backed search overlay for filtering local content.
4.  **Sorting:** Persists user sort preferences (e.g., Date Added, Title) using `SharedPreferences`.

## Architecture (The "Shell" Pattern)

Unlike other features, `library` consists primarily of a **Presentation Layer**.

*   **State Management:** It consumes `LocalMusicBloc` to drive the track list.
*   **UI Structure:** Uses a `CustomScrollView` with `SliverAppBar` to provide a native, collapsible header experience.

```text
lib/features/library/presentation/
├── pages/
│   └── library_page.dart       # Main Scaffold, Permission Logic, Search Overlay
└── widgets/
    ├── library_toggle_bar.dart # Segmented Control (Tracks | Playlists)
    ├── library_tracks_view.dart # ListView wrapper for Songs
    └── library_playlists_view.dart # GridView wrapper for Playlists
```

## Features & UX

### 1. Granular Permissions (Android 13+)
The library implements a smart permission check using `device_info_plus` and `permission_handler`.

*   **Android < 13:** Requests `Permission.storage`.
*   **Android 13+:** Requests `Permission.audio`.
*   **Desktop:** Skips permissions (assumes file access).

### 2. The Search Overlay
Instead of a standard `AppBar` search, this feature implements a custom **Modal Overlay**:
*   **Visuals:** Uses `BackdropFilter` with `ImageFilter.blur` for a "frosted glass" effect.
*   **Animation:** Physics-based entry (`CurvedAnimation` with `Curves.easeOutBack`).
*   **Behavior:** Filters the `LocalMusicBloc` in real-time.

### 3. Persistent Sorting
Sort options are saved to `SharedPreferences` key `local_songs_sort_option`. On app launch, the `LibraryPage` restores this preference and dispatches a `SortSongs` event to the Bloc immediately.

## Usage Guide

### Embedding the Library
The `LibraryPage` is designed to be a tab within the `HomeTabShell`.

```dart
// AutoRouter configuration in app_router.dart
AutoRoute(
  page: LibraryRoute.page,
  path: 'library',
  maintainState: true, // Keep scroll position
)
```

### Extending the Tabs
To add a new section (e.g., "Albums"):
1.  Update `LibraryViewMode` enum in the state.
2.  Add a segment to `LibraryToggleBar`.
3.  Add a `SliverToBoxAdapter` or `SliverList` to the `CustomScrollView` in `library_page.dart`.

## Reference: Dependencies

| Dependency | Purpose |
| :--- | :--- |
| `local_music` (Feature) | Source of Truth for Song Entities and State. |
| `playlists` (Feature) | Source of Truth for Playlist Entities. |
| `permission_handler` | Requesting OS access. |
| `device_info_plus` | Determining Android SDK version. |
| `flutter_bloc` | Consuming `LocalMusicBloc`. |
