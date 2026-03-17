---
title: Playlists Feature
description: Offline playlist creation, management, song ordering, and detail view.
tags: [feature, playlists, sqlite, bloc]
---

# Playlists Feature

> **Prerequisites:** `MusicRepository` must be initialized. `GetPlaylistSongs` joins playlist
> song IDs with the media store to return full `SongEntity` objects.

## Overview

The Playlists feature provides full CRUD for offline playlists. Playlists and their song
associations are stored in a local SQLite database (`playlists.db`). The feature exposes
two BLoCs: `PlaylistBloc` for the list screen and `PlaylistDetailBloc` for the detail screen.

---

## Architecture

```
playlists/
├── data/
│   ├── datasources/
│   │   └── playlist_local_datasource.dart   # playlists.db read/write
│   ├── models/
│   │   └── playlist_model.dart              # Freezed DTO with JSON serialization
│   └── repositories/
│       └── playlist_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── playlist_entity.dart
│   ├── failures/
│   ├── repositories/
│   └── usecases/
│       ├── create_playlist.dart
│       ├── delete_playlist.dart
│       ├── edit_playlist.dart
│       ├── get_playlists.dart
│       ├── get_playlist_songs.dart
│       ├── add_song_to_playlist.dart
│       └── remove_song_from_playlist.dart
└── presentation/
    ├── bloc/
    │   ├── playlist_bloc.dart           # List screen
    │   └── playlist_detail_bloc.dart    # Detail screen
    ├── pages/
    │   ├── playlist_list_page.dart
    │   └── playlist_detail_page.dart
    └── widgets/
        └── add_to_playlist_sheet.dart
```

---

## Database Schema (`playlists.db`)

```sql
CREATE TABLE playlists (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  name        TEXT NOT NULL,
  description TEXT NOT NULL,
  image_path  TEXT,
  created_at  INTEGER NOT NULL,
  updated_at  INTEGER NOT NULL
)

CREATE TABLE playlist_songs (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
  song_id     INTEGER NOT NULL,
  duration    INTEGER DEFAULT 0,
  added_at    INTEGER NOT NULL
)

CREATE INDEX idx_playlist_id ON playlist_songs (playlist_id)
```

`ON DELETE CASCADE` — deleting a playlist automatically removes its song associations.
Songs within a playlist are ordered by `added_at ASC` (insertion order).

`totalSongs` and `totalDurationSeconds` are computed at query time via a `GROUP BY` join
and stored on the `PlaylistModel`. Duration is stored as milliseconds in the DB and
converted to seconds in the response.

---

## `PlaylistBloc`

Handles the list screen: load, create, delete, and add-song operations. After any mutation,
it re-dispatches `loadPlaylists` to refresh counts and durations.

### State Variants

| Variant | Description |
| :--- | :--- |
| `initial` | Not loaded. |
| `loading` | Query in progress. |
| `loaded` | `List<PlaylistEntity>`. |
| `failure` | Error message. |

---

## `PlaylistDetailBloc`

Handles the detail screen: load songs, add song, remove song, and edit metadata. Registered
as `registerFactory`.

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `GetPlaylists` | `NoParams` | `Either<PlaylistFailure, List<PlaylistEntity>>` |
| `CreatePlaylist` | `CreatePlaylistParams(name, description, imagePath?)` | `Either<PlaylistFailure, PlaylistEntity>` |
| `DeletePlaylist` | `int playlistId` | `Either<PlaylistFailure, void>` |
| `EditPlaylist` | edit params | `Either<PlaylistFailure, PlaylistEntity>` |
| `GetPlaylistSongs` | `int playlistId` | `Either<PlaylistFailure, List<SongEntity>>` |
| `AddSongToPlaylist` | `AddSongToPlaylistParams(playlistId, song)` | `Either<PlaylistFailure, void>` |
| `RemoveSongFromPlaylist` | `playlistId`, `songId` | `Either<PlaylistFailure, void>` |

`GetPlaylistSongs` depends on both `PlaylistRepository` and `MusicRepository`:

```dart
sl.registerLazySingleton(
  () => GetPlaylistSongs(playlistRepository: sl(), musicRepository: sl()),
);
```

---

## Known Limitations

- Playlists are local-only and do not sync to any cloud service.
- Duplicate songs in a playlist are supported by the schema but `removeSongFromPlaylist`
  removes only one instance per call (by selecting the row with the lowest `id` matching
  the `(playlist_id, song_id)` pair).
