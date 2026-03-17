---
title: Home Dashboard Feature
description: Main shell, bottom navigation, greeting logic, and quick-resume grid.
tags: [feature, home, dashboard, navigation, bloc]
---

# Home Dashboard Feature

> **Prerequisites:** `MusicRepository` must be initialized — `HomeBloc` queries the local
> song count. `HistoryBloc` (from `analytics`) must be available for the recently-played list.

## Overview

The Home feature is the main application shell. It hosts the bottom navigation bar, renders
the `HomeDashboardPage` as the first tab, and provides a personalized greeting and
quick-resume grid. `HomeBloc` has no repository of its own — it is registered inline in
`initDependencies()` with only `MusicRepository` injected.

---

## Architecture

```
home/
├── domain/
│   └── entities/
│       └── home_tab.dart
└── presentation/
    ├── bloc/
    │   └── home_bloc/
    │       └── home_bloc.dart
    ├── pages/
    │   ├── home_page.dart           # Bottom nav bar shell
    │   ├── home_dashboard_page.dart # Dashboard content (greeting, grid, history)
    │   └── home_tab_shell_page.dart # AutoRoute shell for Tab 1 nested stack
    └── widgets/
        ├── home_header.dart
        ├── quick_resume_grid.dart
        ├── recently_played_list.dart
        ├── pulse_bottom_nav_bar.dart
        ├── simple_animated_nav_bar.dart
        ├── prism_knob_navigation.dart
        └── neural_string_navigation.dart
```

---

## `HomeBloc`

Registered **inline** in `initDependencies()` — no module file:

```dart
serviceLocator.registerFactory(
  () => HomeBloc(musicRepository: serviceLocator()),
);
```

Responsibilities: time-of-day greeting logic and total song count.

---

## Navigation Bar

The active navigation widget is determined by `UserEntity.preferredNavBar` from
`ProfileBloc`. The user can switch styles from the Profile page. Three implementations
are available:

| `NavBarStyle` | Widget |
| :--- | :--- |
| `simple` | `SimpleAnimatedNavBar` |
| `prism` | `PrismKnobNavigation` |
| `neural` | `NeuralStringNavigation` |

The nav bar must be wrapped in `SafeArea` or use `MediaQuery.of(context).padding.bottom` to
avoid being obscured by the system gesture bar on Android.

---

## Dashboard Layout

`HomeDashboardPage` uses `MultiBlocProvider` to wire `HomeBloc` and `HistoryBloc` together.
The page uses a `CustomScrollView` with `SliverAppBar` for a collapsible header.

| Widget | Data Source |
| :--- | :--- |
| `HomeHeader` | `HomeBloc` — greeting string and total song count. |
| `QuickResumeGrid` | `HistoryBloc` — most recent 4 tracks for one-tap resume. |
| `RecentlyPlayedList` | `HistoryBloc` — last 10 played tracks as a horizontal list. |
