---
title: System Architecture
description: A deep dive into the Feature-First Modular Clean Architecture implementation.
tags: [architecture, clean-code, ddd, bloc]
---

# System Architecture

> **Context:** This project enforces **Feature-First Modular Clean Architecture**. This document explains the layering strategy and dependency rules.

## Core Philosophy
We adhere to **Domain-Driven Design (DDD)** principles wrapped in a **Clean Architecture** shell. The primary goal is to isolate business logic (`Domain`) from external frameworks (`UI`, `Database`, `Network`).

## The "Three-Layer" Protocol
Every feature (e.g., `features/auth`, `features/music_player`) functions as a self-contained module consisting of three strictly separated layers:

### 1. Domain Layer (The Inner Core)
*   **Role:** The "Brain" of the feature. Contains pure business logic and enterprise rules.
*   **Dependencies:** **ZERO**. This layer relies only on standard Dart libraries. It knows nothing of Flutter, SQL, or HTTP.
*   **Components:**
    *   **Entities:** Immutable Dart objects representing core concepts (e.g., `Song`, `User`).
    *   **Value Objects:** Objects defined by their attributes, not identity (e.g., `EmailAddress`, `SongDuration`).
    *   **Use Cases (Interactors):** Classes encapsulating a single business action (e.g., `PlaySong`, `UpdateProfile`).
    *   **Repository Interfaces:** Abstract contracts defining *what* data can be accessed, but not *how*.

### 2. Data Layer (The Interface Adapter)
*   **Role:** The "Translator". Converts raw data from the outside world into Domain Entities.
*   **Dependencies:** External packages (`sqflite`, `dio`, `shared_preferences`).
*   **Components:**
    *   **Data Sources:** Low-level accessors (e.g., `LocalMusicDataSource` queries the OS `ContentResolver`).
    *   **DTOs (Data Transfer Objects):** Serializable models (JSON/SQL wrappers) that map to Entities.
    *   **Repository Implementations:** Concrete classes that implement the Domain interfaces, coordinating data sources.

### 3. Presentation Layer (The Outer Shell)
*   **Role:** The "Interface". Displays state and captures user input.
*   **Dependencies:** Flutter SDK, `flutter_bloc`.
*   **Components:**
    *   **Pages/Screens:** Scaffold-level widgets.
    *   **Widgets:** Reusable UI components.
    *   **State Management (BLoC):** Maps `Events` (User clicks) to `UseCases`, and `UseCases` results to `States` (UI updates).

## Dependency Rule
Dependencies flows **inward**.
*   `Presentation` depends on `Domain`.
*   `Data` depends on `Domain`.
*   `Domain` depends on **nothing**.

## Directory Structure (Reference)

```text
lib/
├── core/                  # Shared Kernel (DI, Themes, Failures)
├── features/
│   ├── analytics/         # [Feature] Listening History & Graphs
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── music_player/      # [Feature] Audio Engine & UI
│   └── ...
└── main.dart              # Entry Point & Service Locator
```
