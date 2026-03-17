---
title: Favorites Feature
description: Song bookmarking, O(1) ID lookup, and optimistic toggle.
tags: [feature, favorites, sqlite, bloc]
---

# Favorites Feature

> **Prerequisites:** `MusicRepository` must be initialized before `GetFavoriteSongs` runs,
> as it resolves full `SongEntity` objects from the media store by ID.

## Overview

Favorites lets users bookmark songs by tapping a heart icon anywhere in the app.
Bookmarks are persisted to a dedicated SQLite database (`favorites.db`). The feature uses a
two-tier access pattern: a lightweight `Set<int>` of IDs for O(1) list-tile checks, and full
`SongEntity` resolution only when viewing the Favorites page.

---

## Architecture

```
favorites/
├── data/
│   ├── datasources/
│   │   └── favorites_local_datasource.dart  # favorites.db read/write
│   └── repositories/
│       └── favorites_repository_impl.dart
├── domain/
│   ├── failures/
│   ├── repositories/
│   │   └── favorites_repository.dart
│   └── usecases/
│       ├── add_favorite.dart
│       ├── remove_favorite.dart
│       ├── get_favorite_ids.dart      # Returns List<int> — sorted newest first
│       └── get_favorite_songs.dart   # Resolves IDs → full SongEntity list
└── presentation/
    ├── bloc/
    │   └── favorites_bloc.dart
    ├── pages/
    │   └── favorites_page.dart
    └── widgets/
        └── favorite_button.dart
```

---

## Database Schema (`favorites.db`)

```sql
CREATE TABLE favorites (
  song_id  INTEGER PRIMARY KEY,
  added_at INTEGER NOT NULL        -- Unix epoch ms; used for 'newest first' ordering
)
```

`song_id` is the primary key — duplicate favorites are silently replaced
(`ConflictAlgorithm.replace`). `getFavoriteIds` returns IDs ordered by `added_at DESC`.

---

## `FavoritesBloc`

### Optimistic Toggle

`_onToggleFavorite` applies the toggle to the in-memory state immediately before the
database operation completes. If the operation fails, the previous state is restored:

```
User taps heart
  → Emit updated state with ID added/removed
  → Await AddFavorite / RemoveFavorite
  → On failure: re-emit the original loaded state (revert)
```

### State Variants

| Variant | Description |
| :--- | :--- |
| `initial` | Not yet loaded. |
| `loading` | `GetFavoriteSongs` in progress. |
| `loaded` | `favoriteIds: Set<int>`, `favoriteSongs: List<SongEntity>`. |
| `failure` | Error message string. |

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `AddFavorite` | `SongEntity` | `Either<FavoritesFailure, void>` |
| `RemoveFavorite` | `int songId` | `Either<FavoritesFailure, void>` |
| `GetFavoriteIds` | `NoParams` | `Either<FavoritesFailure, List<int>>` |
| `GetFavoriteSongs` | `NoParams` | `Either<FavoritesFailure, List<SongEntity>>` |

`GetFavoriteSongs` depends on both `FavoritesRepository` (for IDs) and `MusicRepository`
(for song resolution). Registered in `favorites_module.dart`:

```dart
sl.registerLazySingleton(
  () => GetFavoriteSongs(favoritesRepository: sl(), musicRepository: sl()),
);
```
