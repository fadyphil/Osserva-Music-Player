# Osserva 🎵

A local music player with smart listening analytics, built for Android with Flutter.

**v1.0.0 — Early Release** | Open source | [Download APK](../../releases)

---

## Features

- Background playback with lock-screen and notification controls
- Listening analytics — play counts, top artists/albums/genres, time-of-day 
  distribution, and activity heatmap
- Playlist and favorites management, fully offline
- Artist browsing with per-artist analytics
- Song metadata editing with custom artwork support
- Android 13+ permission handling

## Architecture

Feature-First Clean Architecture with BLoC state management. Each feature is 
self-contained across three layers (data / domain / presentation) with its own 
DI module.
```
lib/
├── core/           # DI modules, router, theme, shared usecases
└── features/       # analytics, artists, favorites, home, library,
                    # local_music, music_player, onboarding,
                    # playlists, profile, splash
```

Full breakdown → [docs/architecture.md](docs/architecture.md)

## Tech Stack

| Category       | Package                                         |
| :------------- | :---------------------------------------------- |
| State          | `flutter_bloc ^9.1.1`                           |
| DI             | `get_it ^9.1.1`                                 |
| Navigation     | `auto_route ^11.0.0`                            |
| Audio          | `just_audio ^0.10.5` + `audio_service ^0.18.18` |
| Media Query    | `on_audio_query` (forked)                       |
| Database       | `sqflite ^2.4.2`                                |
| Functional     | `fpdart ^1.2.0`                                 |
| Immutability   | `freezed ^3.2.3`                                |
| Charts         | `fl_chart ^1.1.1`                               |

## Building from Source

**Requirements:** Flutter stable ≥ 3.10, Android device or emulator (min API 21)
```bash
git clone https://github.com/your-username/osserva.git
cd osserva
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Troubleshooting

**`Missing concrete implementation` or `isn't defined` errors**
```bash
dart run build_runner build --delete-conflicting-outputs
```

**`Permission denied (READ_MEDIA_AUDIO)`**  
Accept the system prompt on first launch, or go to App Settings → Permissions.

**Background playback fails in a self-built release APK**  
Ensure `android/app/src/main/res/raw/keep.xml` is present. This file prevents 
R8 from stripping `audio_service` classes at build time.

## Known Limitations

- iOS is scaffolded but not tested on device
- BLoC unit test coverage is partial

## License

[MIT](LICENSE)