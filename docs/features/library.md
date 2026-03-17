---
title: Library Feature
description: Presentation-layer shell for local music tracks and playlists, with permission handling, search overlay, and persistent sort.
tags: [feature, ui, library, permissions, search, sort]
---

# Library Feature

> **Prerequisites:** The `local_music` and `playlists` features must be initialized.
> `LibraryPage` consumes `LocalMusicBloc` from `serviceLocator` directly — not from a
> parent `BlocProvider`. It owns its own BLoC lifecycle.

## Overview

The Library is the primary browsing hub for the user's music collection. It is a
**presentation-layer aggregator** — it owns no data of its own and delegates entirely to
`local_music` (for tracks) and `playlists` (for playlist views). Its responsibilities are
permission gating, segmented track/playlist toggling, persistent sort preference, and a
frosted-glass search overlay.

---

## Architecture

```
library/
└── presentation/
    ├── pages/
    │   ├── library_page.dart           # Main scaffold — owns LocalMusicBloc lifecycle
    │   └── library_tab_shell_page.dart # AutoRoute shell for the Library tab stack
    └── widgets/
        ├── library_toggle_bar.dart     # Segmented control: Tracks | Playlists
        ├── library_tracks_view.dart    # SliverList wrapper for song tiles
        ├── library_playlists_view.dart # Grid wrapper for playlist cards
        ├── library_stats_row.dart      # Song count / total duration row
        └── playlist_card.dart
```

`LibraryPage` mixes in `AutomaticKeepAliveClientMixin` so scroll position and BLoC state
are preserved when the user switches tabs and returns.

---

## Permission Flow

On `initState`, `_checkPermissionAndFetch()` runs before any data is loaded.

| Platform | Permission Requested |
| :--- | :--- |
| Android API < 33 | `Permission.storage` |
| Android API ≥ 33 | `Permission.audio` |
| iOS | `Permission.mediaLibrary` |
| Desktop (Linux / macOS / Windows) | Skipped — file access assumed. |

If permission is denied, a `_PermissionRequestView` is shown with a "Grant Access" button
that re-runs the check. Data fetching only begins after permission is confirmed.

---

## Sort Persistence

Sort preferences are saved to `SharedPreferences` under the key `local_songs_sort_option`
as an integer index into `SortOption.values`.

On permission grant, the saved sort is restored and dispatched **before** `getLocalSongs`:

```dart
void _onPermissionGranted() {
  final prefs = serviceLocator<SharedPreferences>();
  final savedIndex = prefs.getInt('local_songs_sort_option');
  if (savedIndex != null) {
    _bloc.add(LocalMusicEvent.sortSongs(SortOption.values[savedIndex]));
  }
  _bloc.add(const LocalMusicEvent.getLocalSongs());
}
```

`LocalMusicBloc` stores the sort as `_pendingSort` so even if `SortSongs` arrives before
the load completes, the sort is applied when `_onGetLocalSongs` finishes. This fixes the
race condition where a restore preference was ignored on first load.

### Sort Options

| Option | Label | Logic |
| :--- | :--- | :--- |
| `dateAdded` | Last Added | Descending by `song.id` (higher IDs were added later). |
| `titleAz` | Title A–Z | Case-insensitive alphabetical. |
| `titleZa` | Title Z–A | Reverse alphabetical. |
| `artistAz` | Artist A–Z | Case-insensitive by artist name. |
| `duration` | Duration | Descending by `song.duration`. |
| `mostPlayed` | Most Played | Descending by play count from `playCounts` map. |

---

## Search Overlay

The search is implemented as a **modal overlay widget** (`_SearchOverlay`) rendered in a
`Stack` above the `Scaffold`, not as a standard `AppBar` search.

The overlay appears when the user taps the floating `Icons.search` FAB, which itself is only
visible after scrolling past 120px.

### Overlay Behavior

- **Entry animation:** `CurvedAnimation` with `Curves.easeOutBack` for scale, `Curves.easeOut`
  for fade and blur. Total duration: 350ms.
- **Backdrop:** `BackdropFilter` with `ImageFilter.blur(sigmaX: 14, sigmaY: 14)`.
- **Dismiss:** Tap outside the card, tap "Cancel", or press Enter. Triggers `_controller.reverse()` before calling `onClose()`.
- **Search dispatch:** Each character change dispatches `LocalMusicEvent.searchSongs(query)`.
  `LocalMusicBloc` applies a 300ms debounce via `stream_transform`.
- **State preservation:** When the overlay opens, it pre-fills the text field with the
  current `searchQuery` from `LocalMusicBloc` state.

---

## Pull-to-Refresh

`RefreshIndicator` wraps the `CustomScrollView`. The `_refresh()` callback dispatches
`getLocalSongs` and waits for the BLoC stream to leave the `loading` state:

```dart
Future<void> _refresh() async {
  _bloc.add(const LocalMusicEvent.getLocalSongs());
  await _bloc.stream.firstWhere(
    (state) => state.maybeMap(loading: (_) => false, orElse: () => true),
  );
}
```

`AlwaysScrollableScrollPhysics` is applied so the `RefreshIndicator` activates even when
the list is shorter than the viewport.

---

## Extending the Library Tabs

To add a new section (e.g., Albums):

1. Add a value to the `LibraryViewMode` enum.
2. Add a segment to `LibraryToggleBar`.
3. Add a new `SliverList` or `SliverGrid` branch in `library_page.dart`'s `CustomScrollView`.

---

## Reference: Dependencies

| Dependency | Purpose |
| :--- | :--- |
| `local_music` feature | Source of truth for `SongEntity` list and `LocalMusicBloc`. |
| `playlists` feature | Source of truth for `PlaylistEntity` list. |
| `permission_handler` | Requesting OS audio/storage access. |
| `device_info_plus` | Detecting Android SDK version to select the correct permission. |
| `shared_preferences` | Persisting sort preference across sessions. |

---

## Troubleshooting

| Symptom | Probable Cause | Fix |
| :--- | :--- | :--- |
| Library loads but shows grant-permission screen briefly | `_hasPermission` starts `false`; first build renders the permission view before the async check completes | Expected behaviour — guard against it by ensuring the permission check is fast (SharedPreferences is synchronous after `getInstance()`). |
| Sort preference not applied on first load | `SortSongs` event dispatched after `GetLocalSongs` but `_pendingSort` not honoured | Verify `LocalMusicBloc._pendingSort` is read in `_onGetLocalSongs`, not just in `_onSortSongs`. |
| Search does not debounce | `stream_transform` not applied to `SearchSongs` handler | Confirm `on<SearchSongs>(_onSearchSongs, transformer: debounce(...))` is registered in `LocalMusicBloc`. |
| Scroll position lost on tab switch | `AutomaticKeepAliveClientMixin` not applied or `wantKeepAlive` returns `false` | Verify `_LibraryPageState` mixes in `AutomaticKeepAliveClientMixin` and `super.build(context)` is called in `build()`. |
