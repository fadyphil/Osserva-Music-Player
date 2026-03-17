---
title: Profile Feature
description: User identity, navigation preferences, achievements, all-time stats, and cache management.
tags: [feature, profile, settings, shared_preferences, bloc]
---

# Profile Feature

> **Prerequisites:** The `analytics` feature must be initialized — `ProfileBloc` calls
> `GetGeneralStats(TimeFrame.all)` and `ClearAnalytics` directly.

## Overview

The Profile page surfaces the user's listening identity, all-time stats, achievements,
navigation layout preferences, and app information. `ProfileBloc` loads all three data
sources (user profile, achievements, general stats) in a single event. Cache clearing
wipes both the profile `SharedPreferences` key and the entire analytics database.

---

## Architecture

```
profile/
├── data/
│   ├── datasources/
│   │   └── profile_local_datasource.dart    # SharedPreferences wrapper
│   ├── failures/
│   ├── models/
│   └── repositories/
│       └── profile_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart                 # Freezed: id, username, email, avatarUrl, preferredNavBar
│   │   └── achievement_entity.dart          # Freezed: id, title, description, isUnlocked, progress
│   ├── repositories/
│   │   └── profile_repository.dart
│   └── usecases/
│       ├── get_user_profile.dart
│       ├── update_user_profile.dart
│       ├── clear_cache.dart
│       └── get_achievements.dart
└── presentation/
    ├── bloc/
    │   └── profile_bloc.dart
    └── pages/
        └── profile_page.dart
```

---

## Data Persistence

User profile data is stored as a JSON string under `SharedPreferences` key
`cached_user_profile`. If the key is absent or the stored JSON is malformed (schema change),
`getUserProfile()` returns a default user (`username: 'Music Lover'`, empty avatar,
`preferredNavBar: NavBarStyle.simple`) rather than throwing.

`clearCache()` removes both `cached_user_profile` and `is_first_timer` from
`SharedPreferences`. This resets the app to a fresh-install state and redirects the user
through onboarding.

---

## `ProfileBloc`

### Loading

`_onLoadProfile` runs three sequential `Either` folds (user → achievements → stats). If any
step fails, an error state is emitted immediately without running subsequent steps.

```dart
// Simplified:
userResult.fold(
  (f) => emit(ProfileState.error(f.message)),
  (user) => achievementsResult.fold(
    (f) => emit(ProfileState.error(f.message)),
    (achievements) => statsResult.fold(
      (f) => emit(ProfileState.error(f.message)),
      (stats) => emit(ProfileState.loaded(user, achievements, stats)),
    ),
  ),
);
```

### Cache Clear

`_onClearCache` calls `ClearCache` (profile SharedPreferences) and `ClearAnalytics`
(analytics SQLite) sequentially. Either failure emits an error state. On success, emits
`ProfileState.cacheCleared()`, which `profile_page.dart` listens to and responds by
calling `context.router.replaceAll([OnboardingRoute()])`.

### Nav Bar Style Change

`_onChangeNavBarStyle` reads the current `loaded` state, produces an updated `UserEntity`
with the new `NavBarStyle`, and dispatches `updateProfile` which persists and reloads.

---

## Reference: States

| State | Description |
| :--- | :--- |
| `initial` | Not loaded. |
| `loading` | All three queries in progress. |
| `loaded` | `user`, `achievements`, `listeningStats`. |
| `cacheCleared` | Emitted after successful cache wipe — triggers navigation to onboarding. |
| `error` | Error message string. |

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `GetUserProfile` | `NoParams` | `Either<Failure, UserEntity>` |
| `UpdateUserProfile` | `UserEntity` | `Either<Failure, UserEntity>` |
| `ClearCache` | `NoParams` | `Either<Failure, void>` — removes `cached_user_profile` + `is_first_timer`. |
| `GetAchievements` | `NoParams` | `Either<Failure, List<AchievementEntity>>` |

`ProfileBloc` also directly uses `ClearAnalytics` and `GetGeneralStats` from the
`analytics` feature. Both are registered in `analytics_module.dart` as lazy singletons and
injected into `ProfileBloc` via `profile_module.dart`.

---

## Achievements

Achievements are currently computed statically in `ProfileLocalDataSourceImpl.getAchievements()`.
Four achievements are defined: Early Bird, Night Owl, Marathoner, Explorer. In a future
version these will be computed dynamically from the analytics database.

---

## About Section

The Profile page includes an About section (`_AboutSection`) at the bottom of the scroll
view showing the app name, version, license (MIT), and privacy statement. See
`profile_page.dart` for the widget implementation.

---

## Navigation Bar Styles

`NavBarStyle` enum values control which navigation widget is rendered in `home_page.dart`:

| Value | Description |
| :--- | :--- |
| `simple` | Standard bottom nav bar. Labelled "Default" in the UI. |
| `prism` | Custom prism knob nav bar widget. |
| `neural` | Custom neural string nav bar widget. |

The selected style is persisted via `UpdateUserProfile` and restored on every app launch.
