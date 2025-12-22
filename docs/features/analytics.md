---
title: Music Analytics Dashboard
description: How to view your listening habits and music statistics.
tags: [feature, analytics, user-guide]
---

# Music Analytics Dashboard

> **Context:** The Analytics feature provides insights into your music listening habits based on your playback data.

## Overview
The Analytics Dashboard visually represents your listening patterns, including top songs, artists, albums, genres, total listening time, and preferred times of day for listening.

## Accessing the Dashboard

The Analytics Dashboard is accessible via the main navigation (e.g., a dedicated tab in the Home screen).

## Navigating the Dashboard

The dashboard is organized into several sections:

### Time Frame Selection
At the top of the dashboard, you can select the time frame for which you want to view analytics (e.g., Last Week, Last Month, All Time). This will update all the statistics accordingly.

### General Statistics
This section provides an overview of your listening, such as:
-   **Total Songs Played:** The total number of distinct songs played.
-   **Total Play Count:** The total number of times any song was played.
-   **Total Listening Time:** Your cumulative listening duration, usually displayed in hours or minutes.

### Listening Time Distribution
Visual charts illustrate when you listen to music:
-   **Time of Day Chart:** Shows your listening activity distribution across morning, afternoon, and night.

### Top Items
These sections rank your most listened-to content:
-   **Top Songs:** Your most played individual tracks.
-   **Top Artists:** Artists you listen to most frequently.
-   **Top Albums:** Albums you revisit most often.
-   **Top Genres:** Your favorite music genres.

## Data Collection
The application logs playback events locally. This data is used solely for generating your personal analytics and is not shared externally.

## Technical Details (Reference)

### Persistence
-   **Database:** `music_analytics.db` (SQLite).
-   **Table:** `playback_logs`.
-   **Data Points:** `song_id`, `title`, `artist`, `album`, `genre`, `timestamp`, `duration_listened`, `is_completed`, `time_of_day`.

### Logic
Playback logging is triggered by `MusicAnalyticsService` which observes the `MusicPlayerHandler`'s state changes. Analytics data is processed and aggregated by `AnalyticsBloc` via various Use Cases (e.g., `GetTopSongs`, `GetGeneralStats`).
