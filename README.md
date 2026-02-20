> 🚧 **Work in Progress**
> This project is currently under active development. I am using it to strictly practice
> **Clean Architecture** and **BLoC**. Some features may be incomplete.

---
title: Music Player
description: A production-grade Flutter application demonstrating Feature-First Clean Architecture, BLoC, and Offline-First principles.
tags: [flutter, clean-architecture, bloc, audio, sqlite]
---

# Music Player 🎵

> **Status:** Active Development (Beta)  
> **Architecture:** Feature-First Clean Architecture (DDD)  
> **State Management:** BLoC (Business Logic Component)

## Overview

This project serves as a strictly typed, production-grade reference implementation for **Clean Architecture** in Flutter. It is designed to demonstrate how to build a scalable, testable, and offline-first mobile application that survives background process termination.

**Key Features:**
- **Background Audio:** Robust playback with notification controls (`audio_service` + `just_audio`).
- **Offline-First:** Local SQLite database for analytics (`sqflite`).
- **Granular Permissions:** Handling Android 13+ media permissions.
- **Complex UI:** Physics-based animations and custom shaders.

## Documentation

*   **[System Architecture](docs/architecture.md):** Deep dive into the Three-Layer Clean Architecture, DDD, and Folder Structure.
*   **[Background Audio Feature](docs/features/background_notifications.md):** How the background service and notifications work.
*   **[Analytics Feature](docs/features/analytics.md):** Implementation of local-first data tracking.

## Getting Started

### Prerequisites

- **Flutter SDK:** Stable channel (v3.10+)
- **Platform:** Android (min SDK 21) or iOS (min 13.0).

### Installation & Run

1.  **Clone and Install:**
    ```bash
    git clone [repository_url]
    flutter pub get
    ```

2.  **Code Generation (Mandatory):**
    This project uses `freezed` and `json_serializable`. You must run the build runner before launching:
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

3.  **Run Application:**
    ```bash
    flutter run
    ```

## Tech Stack

| Category         | Package                 |
| :--------------- | :---------------------- |
| **State**        | `flutter_bloc`          |
| **DI**           | `get_it`                |
| **Functional**   | `fpdart`                |
| **Immutability** | `freezed`               |
| **Database**     | `sqflite`               |
| **Audio**        | `just_audio`            |

## Troubleshooting

**Error:** `Missing concrete implementation of ...` or `The method ... isn't defined.`
*   **Fix:** Run `dart run build_runner build --delete-conflicting-outputs`.

**Error:** `Permission denied (READ_MEDIA_AUDIO)`
*   **Fix:** Accept the system dialog, or manually enable permissions in App Settings.
