---
title: Splash Screen Feature
description: Documentation for the application launch sequence and routing logic.
tags: [feature, ui, splash, routing]
---

# Splash Screen Feature

> **Context:** The Splash feature handles the initial "Cold Start" experience, including native splash removal and routing decisions.

## Overview
The **Splash Screen** is a transient UI that displays branding while the app initializes essential services (DI, Database). Once initialization is complete, it decides whether to route the user to `Onboarding` (first run) or `Home` (returning user).

## Architecture

*   **Native Integration:** Uses `flutter_native_splash` to show a static image immediately upon process launch, which is then programmatically removed.
*   **Animation:** Uses `flutter_animate` to sequence logo fade-ins and scale effects.
*   **Routing:** Uses `AutoRouter` to replace the navigation stack.

## Usage Guide (How-To)

### Routing Logic
The routing decision is passed into the `SplashPage` constructor via `AppRouter`.

### Code Example: Navigation Decision
```dart
// IMPORTS
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:auto_route/auto_route.dart';

// LOGIC
void navigateNext(BuildContext context, bool isFirstRun) async {
  // 1. Remove the native white screen
  FlutterNativeSplash.remove();

  // 2. Artificial delay for branding animation
  await Future.delayed(const Duration(seconds: 2));

  // 3. Route
  if (isFirstRun) {
    context.router.replace(const OnboardingRoute());
  } else {
    context.router.replace(const HomeRoute());
  }
}
```

## Reference: Configuration

The native splash screen is configured in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#121212"
  image: assets/images/splash.png
  android_12:
    image: assets/images/splash.png
    icon_background_color: "#121212"
```
