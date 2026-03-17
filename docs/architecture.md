---
title: System Architecture
description: Feature-First Modular Clean Architecture in Osserva — layers, DI, routing, and error handling.
tags: [architecture, clean-architecture, ddd, bloc, get_it, auto_route]
---

# System Architecture

> **Context:** Osserva enforces **Feature-First Modular Clean Architecture** with BLoC state
> management. This document covers the layering strategy, dependency rules, DI setup, routing,
> and error handling conventions used across the entire codebase.

---

## Core Philosophy

The architecture follows **Domain-Driven Design (DDD)** principles inside a **Clean Architecture**
shell. The goal is to keep business logic completely decoupled from Flutter, SQLite, and Android
platform APIs. Those are treated as implementation details that can be swapped without touching
domain code.

---

## The Three-Layer Protocol

Every feature is a self-contained module with three strictly separated layers.

### 1. Domain Layer — The Inner Core

- **Role:** Pure business logic. Zero external dependencies — standard Dart only.
- **Components:**
  - **Entities** — Immutable `freezed` classes representing core concepts (`SongEntity`,
    `UserEntity`, `PlayLog`, `ArtistEntity`).
  - **Use Cases** — Single-responsibility classes implementing the `UseCase<Type, Params>`
    interface from `core/usecases/usecase.dart`. One class, one action.
  - **Repository Interfaces** — Abstract contracts defining *what* data is accessible, not how.
  - **Failures** — Feature-specific `Failure` subclasses (e.g., `MusicFailures`,
    `ArtistFailure`). All extend `core/error/failure.dart`.

### 2. Data Layer — The Adapter

- **Role:** Translates raw platform/database data into domain entities.
- **Dependencies:** `sqflite`, `on_audio_query`, `shared_preferences`, `audio_service`.
- **Components:**
  - **Data Sources** — Low-level accessors (`LocalMusicDatasourceImpl` queries Android
    `MediaStore` via `on_audio_query`; `AnalyticsRecorder` writes raw SQL).
  - **Models / Mappers** — Static mapper classes (e.g., `SongMapper`) that convert between
    raw query results and domain entities.
  - **Repository Implementations** — Concrete classes satisfying domain interfaces by
    coordinating data sources and mapping exceptions into `Either` types.

### 3. Presentation Layer — The Outer Shell

- **Role:** Displays state and captures user input.
- **Dependencies:** Flutter SDK, `flutter_bloc`, `auto_route`.
- **Components:**
  - **Pages** — Scaffold-level widgets annotated with `@RoutePage()`.
  - **Widgets** — Reusable, stateless UI components.
  - **BLoCs / Cubits** — Map user `Events` to use case calls and fold results into `States`.

---

## Dependency Rule

```
Presentation → Domain ← Data
```

- `Presentation` depends on `Domain` (calls use cases, reads entities).
- `Data` depends on `Domain` (implements repository interfaces, maps to entities).
- `Domain` depends on **nothing**.

Neither `Presentation` nor `Domain` may import from `Data`.

---

## Directory Structure

```
lib/
├── core/
│   ├── di/
│   │   ├── init_dependencies.dart      # Single entry point; calls all feature modules
│   │   └── modules/                    # One registration file per feature
│   │       ├── analytics_module.dart
│   │       ├── artists_module.dart
│   │       ├── favorites_module.dart
│   │       ├── local_music_module.dart
│   │       ├── music_player_module.dart
│   │       ├── onboarding_module.dart
│   │       ├── playlists_module.dart
│   │       └── profile_module.dart
│   ├── error/
│   │   └── failure.dart                # abstract class Failure { final String message; }
│   ├── router/
│   │   ├── app_router.dart             # AutoRoute config and route tree
│   │   ├── app_router.gr.dart          # Generated — do not edit
│   │   └── guards/
│   │       └── onboarding_guard.dart
│   ├── theme/
│   │   ├── app_pallete.dart
│   │   └── app_theme.dart
│   └── usecases/
│       └── usecase.dart                # UseCase<Type, Params> + NoParams
└── features/
    ├── analytics/
    ├── artists/
    ├── background_notification/
    ├── favorites/
    ├── home/
    ├── library/
    ├── local_music/
    ├── music_player/
    ├── onboarding/
    ├── playlists/
    ├── profile/
    └── splash/
```

---

## Dependency Injection

Osserva uses `get_it` as a service locator. The global instance is `serviceLocator`, exported
from `core/di/init_dependencies.dart`.

```dart
final serviceLocator = GetIt.instance;
```

### Initialization Sequence

`initDependencies()` is called once in `main.dart` before `runApp`. The order is significant —
each step can only depend on things registered before it.

```
1. SharedPreferences.getInstance()          → registered as lazy singleton
2. AudioPlayer()                            → registered as singleton
3. MediaStore, OnAudioQuery                 → registered as lazy singletons
4. AppRouter()                              → registered as singleton
5. AudioService.init(MusicPlayerHandler)    → AudioHandler registered as singleton
6. registerLocalMusicDependencies()
7. registerMusicPlayerDependencies()        → depends on AudioHandler
8. registerAnalyticsDependencies()          → depends on AudioPlayer
9. registerOnboardingDependencies()
10. registerProfileDependencies()           → depends on analytics use cases
11. registerPlaylistsDependencies()
12. registerFavoritesDependencies()         → depends on MusicRepository
13. registerArtistsDependencies()
14. HomeBloc                                → registered inline (no module)
15. serviceLocator<AudioAnalyticsTracker>().init()  → post-registration hook
```

### Registration Patterns

| Pattern | Used For |
| :--- | :--- |
| `registerSingleton` | `AudioPlayer`, `AudioHandler`, `AppRouter` — must be pre-initialized and shared for the full app lifetime. |
| `registerLazySingleton` | Repositories, data sources, use cases — stateless; instantiated on first access. |
| `registerFactory` | BLoCs — a fresh instance per `BlocProvider.create` call so each page lifecycle is independent. |

> **`MusicPlayerBloc` lifecycle note:** Currently registered as `registerFactory`.
> Pages that need to share the same playback state (e.g., MiniPlayer + MusicPlayerPage)
> must receive the instance via `BlocProvider.value` from a common ancestor rather than
> creating separate instances. See [`docs/features/music_player.md`](music_player.md).

### Accessing the Service Locator

```dart
import 'package:osserva/core/di/init_dependencies.dart';

// In a widget or page:
final myBloc = serviceLocator<MyBloc>();
```

---

## Use Case Interface

```dart
// core/usecases/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams<Type> {}
```

Use cases with no input take `NoParams()`. Use cases with input define a dedicated `Params`
class (e.g., `GetTopSongsParams`, `EditSongMetadataParams`, `CreatePlaylistParams`).

---

## Error Handling

All domain use cases return `Either<Failure, T>` from `fpdart`. `Failure` is defined in
`core/error/failure.dart`:

```dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}
```

Feature-level subclasses (e.g., `MusicFailures`, `PlaylistFailure`) extend `Failure` to
add context. BLoCs use `result.fold((l) => emit(errorState), (r) => emit(loadedState))`.
Exceptions are never used as control flow across layer boundaries.

---

## Routing

Navigation uses `auto_route`. Routes are declared in `app_router.dart` and the generated
`app_router.gr.dart` provides strongly-typed route classes.

### Route Tree

```
SplashRoute                              ← initial: true
OnboardingRoute
UserRegistrationRoute
HomeRoute                                ← guards: [OnboardingGuard]
  ├── HomeTabShellRoute (Tab 1)
  │     ├── HomeDashboardRoute           ← initial
  │     ├── LibraryRoute
  │     ├── FavoritesRoute
  │     ├── PlaylistDetailRoute
  │     └── HistoryRoute
  ├── LibraryTabShellRoute (Tab 2)
  │     ├── LibraryRoute                 ← initial
  │     └── PlaylistDetailRoute
  ├── ArtistsTabShellRoute (Tab 3)
  │     ├── ArtistsRoute                 ← initial
  │     └── ArtistDetailRoute
  ├── AnalyticsDashboardRoute (Tab 4)
  └── ProfileRoute (Tab 5)
MusicPlayerRoute                         ← sits above HomeRoute; full-screen overlay
```

### OnboardingGuard

`OnboardingGuard` intercepts every navigation to `HomeRoute`. It calls
`CheckIfUserIsFirstTimer` via `serviceLocator`. On failure or when the user has not completed
onboarding, it redirects to `OnboardingRoute`.

```dart
class OnboardingGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final result = await serviceLocator<CheckIfUserIsFirstTimer>()(NoParams());
    result.fold(
      (_) {
        resolver.next(false);
        router.replace(OnboardingRoute());
      },
      (isFirstTimer) {
        isFirstTimer
            ? router.replace(OnboardingRoute())
            : resolver.next(true);
      },
    );
  }
}
```

### Opening the Full-Screen Player

`MusicPlayerRoute` sits above the shell so it covers the bottom nav bar. Always push on the
**root** router:

```dart
context.router.root.push(MusicPlayerRoute(song: currentSong));
```

---

## State Management Conventions

- Events and States are `freezed` sealed unions.
- BLoCs contain no business logic; they orchestrate use cases and fold `Either` results.
- Cubits handle simpler, linear flows (`OnboardingCubit`, `UserRegistrationCubit`).
- High-frequency stream emissions (position, duration) are throttled with `stream_transform`
  before being dispatched as BLoC events to prevent excessive rebuilds.

---

## Audio Architecture

| Component | Registration | Role |
| :--- | :--- | :--- |
| `AudioPlayer` | `registerSingleton` | `just_audio` engine — shared between handler and analytics tracker. |
| `MusicPlayerHandler` | `registerSingleton` as `AudioHandler` | `BaseAudioHandler` subclass — bridges `just_audio` to `audio_service` / OS media session. |
| `AudioPlayerRepository` | `registerLazySingleton` | Domain interface abstracting handler methods. |
| `MusicPlayerBloc` | `registerFactory` | UI-facing state machine for queue, playback controls, and sleep timer. |
| `AudioAnalyticsTracker` | `registerLazySingleton` | Passive observer on the shared `AudioPlayer`; auto-logs plays independently of UI state. |

The `AudioPlayer` singleton is injected into both `MusicPlayerHandler` and
`AudioAnalyticsTracker`, ensuring both observe the same player instance without coupling.

---

## Further Reading

- [`docs/features/analytics.md`](features/analytics.md) — Star schema, play completion logic, BLoCs.
- [`docs/features/background_notifications.md`](features/background_notifications.md) — Audio handler, OS integration, release-mode gotchas.
- [`docs/features/music_player.md`](features/music_player.md) — Queue management, sleep timer, reorder guard.
- [`docs/features/library.md`](features/library.md) — Permission flow, search overlay, sort persistence.
- [`docs/features/onboarding.md`](features/onboarding.md) — First-run flow, Android Auto Backup fix.
- [`docs/features/profile.md`](features/profile.md) — Settings, cache clear, achievements.
