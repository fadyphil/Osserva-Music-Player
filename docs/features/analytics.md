---
title: Analytics Feature
description: Documentation for the local-first playback tracking and visualization engine.
tags: [feature, analytics, sqlite, visualization]
---

# Analytics Feature

> **Context:** This feature implements **Offline-First** data gathering using SQLite. It tracks user listening habits without external servers.

## Overview
The **Analytics** feature acts as the "Black Box" of the application, silently recording every playback event. It aggregates this raw data into meaningful insights (Top Genres, Listening Clock, etc.) displayed on the `AnalyticsDashboard`.

## Architecture

*   **Domain:** Defines the `PlaybackLog` entity and Use Cases (`LogPlayback`, `GetTopItems`).
*   **Data:** `AnalyticsLocalDataSource` executes raw SQL queries against `music_analytics.db`.
*   **Presentation:** `AnalyticsBloc` fetches data and prepares it for `fl_chart` widgets.

## Usage Guide (How-To)

### Logging Playback
Playback is logged automatically by the system, but can be triggered manually for testing.

### Code Example: Logging a Song
```dart
// IMPORTS
import 'package:osserva/features/analytics/domain/usecases/log_playback.dart';
import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

// LOGIC
Future<void> manualLog(LogPlayback logPlaybackUseCase, SongEntity song) async {
  // Logs a completed listen (duration > 30s)
  final result = await logPlaybackUseCase(
    LogPlaybackParams(
      song: song,
      durationListened: 180, // seconds
      isCompleted: true,
      timeOfDay: 'night',
    ),
  );

  result.fold(
    (failure) => print('Log failed: ${failure.message}'),
    (success) => print('Logged successfully'),
  );
}
```

### Retrieving Top Items
To get the top 5 artists, use the generic `GetTopItems` use case.

```dart
// IMPORTS
import 'package:osserva/features/analytics/domain/usecases/get_top_items.dart';

// LOGIC
void fetchTopArtists(GetTopItems getTopItems) async {
  final result = await getTopItems(
    const GetTopItemsParams(
      type: AnalyticsType.artist,
      limit: 5,
    ),
  );
}
```

## Reference: Database Schema

**Table:** `playback_logs`

| Column | Type | Notes |
| :--- | :--- | :--- |
| `id` | `INTEGER PK` | Auto-increment. |
| `song_id` | `INTEGER` | Links to the local media ID. |
| `timestamp` | `INTEGER` | Unix Epoch (milliseconds). |
| `is_completed` | `INTEGER` | 1 if the song was played > 80%, else 0. |
