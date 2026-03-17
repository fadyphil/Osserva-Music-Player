---
title: Local Music Feature
description: Local media scanning, song management, metadata editing, and deletion.
tags: [feature, local-music, on_audio_query, media_store, metadata]
---

# Local Music Feature

> **Prerequisites:** Android audio permission must be granted before `getLocalSongs` is
> called. The `Library` feature handles permission gating. On Android 13+, the required
> permission is `READ_MEDIA_AUDIO` (`Permission.audio`); on older versions it is
> `READ_EXTERNAL_STORAGE` (`Permission.storage`).

## Overview

The Local Music feature is the media foundation of Osserva. It scans the device for
compatible audio files, exposes them as `SongEntity` objects, and provides use cases for
deletion and metadata editing. All other features that display or play songs consume data
from this feature's `MusicRepository`.

---

## Architecture

```
local_music/
├── data/
│   ├── datasource/
│   │   └── local_music_datasource.dart      # Platform-specific media access
│   ├── failures/
│   │   ├── music_failures.dart
│   │   └── music_failures.freezed.dart
│   ├── models/
│   │   └── song_model.dart                  # on_audio_query SongModel → SongEntity mapper
│   └── repositories/
│       └── music_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── song_entity.dart                 # Freezed: id, title, artist, album, path, duration…
│   ├── repositories/
│   │   └── music_repository.dart
│   └── usecases/
│       ├── get_local_songs_use_case.dart
│       ├── get_song_by_id_use_case.dart
│       ├── delete_song.dart
│       └── edit_song_metadata.dart
└── presentation/
    ├── managers/
    │   ├── local_music_bloc.dart
    │   ├── local_music_event.dart
    │   └── local_music_state.dart
    ├── pages/
    │   └── song_list_page.dart
    └── widgets/
        ├── song_list_tile.dart
        ├── song_artwork.dart
        ├── edit_song_metadata_sheet.dart
        └── song_options_sheet.dart
```

---

## Media Scanning

`LocalMusicDatasourceImpl.getLocalMusic()` uses platform-specific paths:

| Platform | Implementation |
| :--- | :--- |
| **Android** | `OnAudioQuery.querySongs()` with `UriType.EXTERNAL`, sorted descending by `DATE_ADDED`. |
| **macOS / Windows** | `OnAudioQuery.querySongs()` without URI filtering. |
| **Linux** | Manual directory scan of `~/Music` and `~/Downloads` using `dart:io`. Parses `"Artist - Title.ext"` filename convention for metadata. |

### Filtering Rules

After querying, songs are filtered to remove noise:

- **All platforms:** `duration > 5000ms` (5 seconds) — removes notification sounds and short clips.
- **Android:** `isMusic == true || isPodcast == true` — removes ringtones, alarms, and notifications.
- **Desktop:** All files passing the duration check are included (system cannot classify `isMusic` reliably).

### Supported Formats

`.mp3`, `.m4a`, `.wav`, `.ogg`, `.flac`

---

## `LocalMusicBloc`

`LocalMusicBloc` is registered as `registerFactory`. It manages searching, sorting, and
play count display alongside the core song list.

On `getLocalSongs`, two queries run in parallel using Dart 3 record `.wait`:

```dart
final (songsResult, countsResult) = await (
  _getLocalSongsUseCase(NoParams()),
  _getAllSongPlayCountsUseCase(NoParams()),
).wait;
```

Play counts from the analytics database are merged into the loaded state so the
`mostPlayed` sort option has data immediately.

### `LocalMusicState` Variants

| Variant | Description |
| :--- | :--- |
| `initial` | No data loaded yet. |
| `loading` | Scan in progress. |
| `loaded` | `allSongs`, `processedSongs` (filtered+sorted), `playCounts`, `searchQuery`, `sortOption`. |
| `failure` | `Failure` object from the repository. |

### Search

`SearchSongs` is handled with a 300ms `debounce` transformer from `stream_transform`.
Filtering is case-insensitive and matches both `song.title` and `song.artist`.

### Sort

`_pendingSort` is stored on the BLoC instance so a `SortSongs` event dispatched before the
initial load completes is honoured when `_onGetLocalSongs` finishes. Sort is applied to
`processedSongs`; `allSongs` is never mutated.

---

## Song Deletion

`DeleteSong` calls `LocalMusicDatasourceImpl.deleteSong`, which uses platform-specific
deletion:

| Platform | Method |
| :--- | :--- |
| **Android** | `MediaStore.deleteFileUsingUri(uriString)` triggers the native system permission dialog (Android 11+). Falls back to `File.delete()` for files owned by the app. |
| **Desktop** | `File.delete()` directly. |

After a successful deletion, the BLoC re-dispatches `GetLocalSongs` to refresh the list.
The `DeleteSong` use case also cleans up the song's analytics logs and removes it from all
playlists.

---

## Metadata Editing

`EditSongMetadata` calls `LocalMusicDatasourceImpl.editSongMetadata`, which uses the
`audiotags` package to read and write ID3/MP4 tags.

> **Unsupported formats:** `.opus` and `.wav` files are silently skipped — `editSongMetadata`
> returns `false` without throwing. The caller receives a failure and should surface this to
> the user.

The edit is a **partial update**: existing tags are read first, and only supplied fields are
overwritten. Artwork is handled separately — if `artworkBytes` is provided, it replaces the
existing cover; if null, the existing artwork is preserved.

After writing tags, `OnAudioQuery.scanMedia(path)` is called on Android to force the
`MediaStore` to re-index the updated file.

### `EditSongMetadataParams`

| Field | Type | Description |
| :--- | :--- | :--- |
| `song` | `SongEntity` | The song to edit (provides `path` for file access). |
| `title` | `String?` | New title; `null` preserves existing. |
| `artist` | `String?` | New artist; `null` preserves existing. |
| `album` | `String?` | New album; `null` preserves existing. |
| `genre` | `String?` | New genre; `null` preserves existing. |
| `year` | `String?` | Release year as string; parsed to `int`. `null` preserves existing. |
| `artworkBytes` | `Uint8List?` | New cover art bytes; `null` preserves existing artwork. |

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `GetLocalSongsUseCase` | `NoParams` | `Either<Failure, List<SongEntity>>` |
| `GetSongByIdUseCase` | `int songId` | `Either<Failure, SongEntity>` |
| `DeleteSong` | `SongEntity` | `Either<Failure, bool>` |
| `EditSongMetadata` | `EditSongMetadataParams` | `Either<Failure, bool>` |

---

## Troubleshooting

| Symptom | Probable Cause | Fix |
| :--- | :--- | :--- |
| Song list is empty on Android | Permission not granted | Verify `LibraryPage._checkPermissionAndFetch()` is called and permission is accepted. |
| Deleted song reappears after restart | `MediaStore` not updated | Confirm `_onAudioQuery.scanMedia(path)` is called after file deletion on Android. |
| Metadata edit has no effect on `.opus` files | Format not supported by `audiotags` | The datasource explicitly returns `false` for `.opus` and `.wav`. Inform the user in the UI. |
| `GetSongByIdUseCase` returns failure | `queryAudiosFrom` uses `ALBUM_ID` not `AUDIO_ID` | This is a known issue in the current datasource. Cross-reference the ID type being passed — the current implementation queries by `ALBUM_ID`. |
