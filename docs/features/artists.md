---
title: Artists Feature
description: Artist list, per-artist song browsing, and analytics drill-down.
tags: [feature, artists, on_audio_query, analytics]
---

# Artists Feature

> **Prerequisites:** `on_audio_query` must have audio permission before `GetArtists` is
> called. The `analytics` feature must be initialized for per-artist stats to load.

## Overview

The Artists feature provides a paginated list of all unique artists in the local library and
a detail screen for each artist showing their songs and play statistics. It owns its own data
layer — it does not delegate to `local_music` for artist queries.

---

## Architecture

```
artists/
├── data/
│   ├── datasources/
│   │   └── artist_local_datasource.dart    # OnAudioQuery artist + song queries
│   ├── models/
│   │   └── artist_mapper.dart
│   └── repositories/
│       └── artist_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── artist_entity.dart              # Freezed: id, name, numberOfTracks, numberOfAlbums
│   ├── failures/
│   │   └── artist_failure.dart
│   ├── repositories/
│   │   └── artist_repository.dart
│   └── usecases/
│       ├── get_artists.dart
│       ├── get_artist_songs.dart
│       └── get_artist_analytics_stats.dart
└── presentation/
    ├── bloc/
    │   ├── artists/
    │   │   └── artists_bloc.dart           # Drives artist list page
    │   └── artist_details/
    │       └── artist_detail_bloc.dart     # Drives artist detail page
    ├── pages/
    │   ├── artists_page.dart
    │   ├── artist_detail_page.dart
    │   └── artists_tab_shell_page.dart
    └── widgets/
        └── artist_card.dart
```

---

## Data Source

`ArtistLocalDataSourceImpl` uses `on_audio_query` on Android/iOS and a manual
`~/Music` + `~/Downloads` directory scan on Linux.

- **`getArtists()`** — queries with `ArtistSortType.ARTIST`, `OrderType.ASC_OR_SMALLER`.
- **`getArtistSongs(artistId)`** — uses `queryAudiosFrom(AudiosFromType.ARTIST_ID, artistId)`.
- **`getArtistStats()`** — returns `{}` (stats are fetched via `GetArtistAnalyticsStats`,
  which queries the analytics database, not the media store).

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `GetArtists` | `NoParams` | `Either<ArtistFailure, List<ArtistEntity>>` |
| `GetArtistSongs` | `artistName: String` (or `artistId: int`) | `Either<ArtistFailure, List<SongEntity>>` |
| `GetArtistAnalyticsStats` | `artistName: String` | `Either<Failure, ArtistStats>` from analytics DB |

## Reference: BLoC Registration

Both BLoCs are registered as `registerFactory`:

```
sl.registerFactory(() => ArtistsBloc(sl(), sl()));         // GetArtists, GetArtistSongs
sl.registerFactory(() => ArtistDetailBloc(sl(), sl()));    // GetArtistSongs, GetArtistAnalyticsStats
```

## Known Limitation

Artist name matching between the media store and the analytics database is exact and
case-sensitive. Tracks with featured artist notation (e.g., `"Song - Artist ft. Other"`)
are attributed to the full raw metadata string rather than the primary artist. Collaboration
normalisation is a planned improvement.
