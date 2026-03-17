---
title: Analytics Feature
description: Local-first playback tracking, SQLite star schema, and visualization engine.
tags: [feature, analytics, sqlite, star-schema, bloc]
---

# Analytics Feature

> **Prerequisites:** `AudioAnalyticsTracker` must be initialized after DI setup via
> `serviceLocator<AudioAnalyticsTracker>().init()`. This is called at the end of
> `initDependencies()`. No network access is used; all data is on-device.

## Overview

The Analytics feature silently records every qualifying playback event at the `AudioPlayer`
stream level — below the UI layer, so it captures plays regardless of whether the app is
foregrounded or backgrounded. Raw events are accumulated into a SQLite database, aggregated
into daily rollups, and exposed as pre-computed stats (top artists, genre density, listening
heatmap, time-of-day distribution) to the `AnalyticsDashboard`.

---

## Architecture

```
features/analytics/
├── data/
│   ├── datasources/
│   │   ├── analytics_recorder.dart       # Transactional write path
│   │   ├── analytics_reader.dart         # Query layer for dashboard
│   │   ├── analytics_aggregator.dart     # Daily rollup computation
│   │   ├── audio_analytics_tracker.dart  # Passive AudioPlayer stream observer
│   │   └── db/
│   │       └── analytics_database.dart   # Schema v3, migrations v1→v2→v3
│   └── repositories/
│       └── analytics_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── analytics_stats.dart   # ListeningStats, TopItem (freezed)
│   │   ├── artist_stats.dart
│   │   ├── play_log.dart
│   │   └── analytics_enums.dart   # TimeFrame, (time-of-day is a plain String)
│   ├── repositories/
│   │   └── analytics_repository.dart
│   ├── services/
│   │   └── music_analytics_service.dart
│   └── usecases/
│       ├── log_playback.dart
│       ├── get_top_items.dart         # GetTopSongs, GetTopArtists, GetTopAlbums, GetTopGenres
│       ├── get_general_stats.dart
│       ├── get_playback_history.dart
│       ├── watch_playback_history.dart
│       ├── get_all_song_play_counts.dart
│       └── clear_analytics.dart
└── presentation/
    ├── bloc/
    │   ├── analytics_bloc.dart
    │   └── history_bloc/
    │       └── history_bloc.dart
    └── widgets/
        └── analytics_dashboard_page.dart
```

### Data Flow

```
AudioPlayer (just_audio)
    │ stream subscriptions
    ▼
AudioAnalyticsTracker
    │ calls LogPlayback use case when qualified session ends
    ▼
AnalyticsRecorder ──► SQLite (playback_logs fact table)
                          │
              AnalyticsAggregator (daily_aggregates rollup)
                          │
              AnalyticsReader ──► AnalyticsBloc ──► Dashboard UI
```

---

## Play Qualification Logic

`AudioAnalyticsTracker` subscribes directly to four `AudioPlayer` streams:
`playingStream`, `sequenceStateStream`, `durationStream`, `processingStateStream`, and
`positionStream` (for loop detection).

A session is finalized and logged when:

- The track changes (`sequenceStateStream` emits a new item ID), **or**
- `ProcessingState.completed` fires (normal end of track), **or**
- A loop is detected via `positionStream` (position resets from near-end to near-zero
  while `LoopMode.one` is active, since `completed` never fires in loop mode).

A finalized session is **discarded** (not logged) if `listenedSeconds <= 5`.

The `is_completed` flag in the log row is set to `1` when:

- `listenedSeconds >= songDurationSeconds * 0.9` (90% threshold), **or**
- `forceCompleted: true` (track ended naturally or looped).

### Consecutive Play Accumulation

If the same song is played again within **10 minutes** of the last log entry, the recorder
**updates** the existing row (incrementing `play_count` and accumulating `duration_listened`)
rather than inserting a new row. This prevents artificial inflation of play counts from
repeated short listens or skips.

### Time-of-Day Buckets

| Bucket | Hours |
| :--- | :--- |
| `morning` | 05:00 – 11:59 |
| `afternoon` | 12:00 – 17:59 |
| `evening` | 18:00 – 21:59 |
| `night` | 22:00 – 04:59 |

---

## Database Schema (`music_analytics.db`, v3)

### Dimension Tables

| Table | Columns | Notes |
| :--- | :--- | :--- |
| `artists` | `id PK`, `name UNIQUE` | Normalized artist dimension. |
| `albums` | `id PK`, `name UNIQUE` | Normalized album dimension. |
| `genres` | `id PK`, `name UNIQUE` | Normalized genre dimension. |
| `songs` | `id PK`, `source_id`, `title`, `artist_id FK`, `album_id FK`, `genre_id FK` | `source_id` is the original Android `MediaStore` ID. Indexed for fast lookup. |

### Fact Table: `playback_logs` (Hot Data)

| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | `INTEGER PK` | Auto-increment. |
| `song_id` | `INTEGER FK` | Internal analytics song ID (not MediaStore ID). |
| `timestamp` | `INTEGER` | Unix epoch (ms) of the session end, anchored to local time. |
| `duration_listened` | `INTEGER` | Seconds played in this session (accumulated). |
| `is_completed` | `INTEGER` | `1` if ≥ 90% was played or track ended naturally. |
| `play_count` | `INTEGER` | Consecutive plays rolled into this row (default 1). Added in v3. |
| `time_of_day` | `TEXT` | `morning`, `afternoon`, `evening`, or `night`. |

### Fact Table: `daily_aggregates` (Cold Data)

Pre-computed daily rollups per song per time-of-day bucket. Written by `AnalyticsAggregator`
so dashboard queries remain O(1) as the play log grows.

| Column | Type | Description |
| :--- | :--- | :--- |
| `date_epoch` | `INTEGER` | Midnight timestamp (ms) of the day in local time. |
| `song_id` | `INTEGER FK` | Internal analytics song ID. |
| `play_count` | `INTEGER` | Total plays on this date. |
| `total_duration` | `INTEGER` | Total seconds listened on this date. |
| `time_of_day` | `TEXT` | Bucket for this aggregate row. |

Unique constraint on `(date_epoch, song_id, time_of_day)`.

### Schema Migrations

| Version | Change |
| :--- | :--- |
| v1 → v2 | Extracted flat `playback_logs` into star schema (dimensions + songs + logs). Full data migration preserves existing history. |
| v2 → v3 | Added `play_count` column to `playback_logs` to support consecutive-play accumulation. |

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `LogPlayback` | `PlayLog` | `Either<Failure, void>` |
| `GetTopSongs` | `GetTopSongsParams(timeFrame, limit)` | `Either<Failure, List<TopItem>>` |
| `GetTopArtists` | `GetTopSongsParams(timeFrame, limit)` | `Either<Failure, List<TopItem>>` |
| `GetTopAlbums` | `GetTopSongsParams(timeFrame, limit)` | `Either<Failure, List<TopItem>>` |
| `GetTopGenres` | `GetTopSongsParams(timeFrame, limit)` | `Either<Failure, List<TopItem>>` |
| `GetGeneralStats` | `TimeFrame` | `Either<Failure, ListeningStats>` |
| `GetPlaybackHistory` | date range params | `Either<Failure, List<PlayLog>>` |
| `WatchPlaybackHistory` | — | `Stream<List<PlayLog>>` |
| `GetAllSongPlayCounts` | `NoParams` | `Either<Failure, Map<int, int>>` |
| `ClearAnalytics` | `NoParams` | `Either<Failure, void>` |

`TimeFrame` enum values: `day`, `week`, `month`, `year`, `all`.

## Reference: Domain Entities

### `TopItem` (freezed)

| Field | Type | JSON Key |
| :--- | :--- | :--- |
| `id` | `String` | `id` |
| `title` | `String` | `label` |
| `subtitle` | `String?` | `sub_label` |
| `count` | `int` | `value` |
| `type` | `String` | `type` (default `'unknown'`) |

### `ListeningStats` (freezed)

| Field | Type | JSON Key |
| :--- | :--- | :--- |
| `totalMinutes` | `int` | `total_duration` |
| `totalSongsPlayed` | `int` | `total_count` |
| `timeOfDayDistribution` | `Map<String, int>` | — (default `{}`) |

## Reference: BLoCs

### `AnalyticsBloc`

Loaded via `registerFactory`. The dashboard creates a new instance via `BlocProvider.create`.

Internally subscribes to `WatchPlaybackHistory` on construction. When the stream emits (a
new play is logged), if the BLoC is in the `loaded` state it re-fetches all five queries
using the current `TimeFrame`.

All five queries (`GetTopSongs`, `GetTopArtists`, `GetTopAlbums`, `GetTopGenres`,
`GetGeneralStats`) run in parallel using Dart 3 record `.wait`:

```dart
final (songsRes, artistsRes, albumsRes, genresRes, statsRes) = await (
  _getTopSongs(params),
  _getTopArtists(params),
  _getTopAlbums(params),
  _getTopGenres(params),
  _getGeneralStats(timeFrame),
).wait;
```

### `HistoryBloc`

Loaded via `registerFactory`. Used by the Home dashboard to display recent play history.

## Reference: Dashboard Widgets

| Widget | Description |
| :--- | :--- |
| `HeatmapWidget` | Day × hour grid showing listening intensity. |
| `ListeningTimeChart` | Line chart of daily minutes over a rolling window. |
| `GenreDensityCard` | Donut chart of genre distribution by play count. |
| `TopGenresHorizontalBar` | Ranked horizontal bars for top genres. |
| `ActivityByTimeCard` | Morning / afternoon / evening / night distribution. |
| `RecentActivityCard` | 7-day summary card shown on the Home dashboard. |
| `TemporalDistributionChart` | Week-of-month listening pattern. |

---

## Troubleshooting

| Symptom | Probable Cause | Fix |
| :--- | :--- | :--- |
| Stats are zero despite playback | `AudioAnalyticsTracker.init()` not called | Verify the final line of `initDependencies()` calls `.init()`. |
| `WatchPlaybackHistory` stream never emits | `AnalyticsRecorder._logController` not being triggered | Confirm `logEvent` is completing without exception; check `AnalyticsRecorder.onLogStream`. |
| Consecutive plays inflate count incorrectly | Timestamp null bug (pre-fix) | Ensure `analytics_recorder.dart` includes `'timestamp'` in the `columns` list of the last-row query. This was a known bug — see the comment in `analytics_recorder.dart`. |
| Dashboard loads but charts are empty after fresh install | `daily_aggregates` not yet populated | The aggregator runs on first data access. Play a few tracks and reload. |
