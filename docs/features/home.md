---
title: Home Dashboard Feature
description: Documentation for the main application dashboard and aggregation logic.
tags: [feature, ui, dashboard, aggregation]
---

# Home Dashboard Feature

> **Context:** The Home feature acts as the "Grand Central Station" of the app, aggregating data from multiple sources (Profile, History, Osserva).

## Overview
The **Home Dashboard** is the first screen the user sees after onboarding. It provides a personalized greeting, quick access to recently played tracks ("Quick Resume"), and a list of playback history.

## Architecture

This feature uses **MultiBlocProvider** to coordinate states from different domains:
1.  **`HomeBloc`:** Manages Greeting logic (Morning/Afternoon/Night) and aggregate track counts.
2.  **`HistoryBloc`:** Fetches playback history from the `analytics` feature.
3.  **`MusicPlayerBloc`:** Receives "Play" commands from the dashboard widgets.

## Usage Guide (How-To)

### Dashboard Layout
The `HomeDashboardPage` uses a `CustomScrollView` to lazily load sections.

### Code Example: Coordinating Blocs
```dart
// IMPORTS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/home/presentation/bloc/home_bloc/home_bloc.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';

// LOGIC
Widget buildDashboard() {
  return MultiBlocProvider(
    providers: [
      // 1. Load Greetings
      BlocProvider(create: (_) => serviceLocator<HomeBloc>()..add(const HomeEvent.loadHomeData())),
      // 2. Load History
      BlocProvider(create: (_) => serviceLocator<HistoryBloc>()..add(const HistoryEvent.fetchRecentHistory())),
    ],
    child: const HomeBody(), // Consumes states
  );
}
```

## Reference: UI Components

| Component | Role |
| :--- | :--- |
| `HomeHeader` | Displays dynamic greeting (e.g., "Good Morning, User") and track stats. |
| `QuickResumeGrid` | A 2x2 grid of the 4 most recent tracks for one-tap playback. |
| `RecentlyPlayedList` | A horizontal list of the last 10 tracks. |
