---
title: Splash Screen Feature
description: Cold-start experience, native splash removal, and onboarding routing decision.
tags: [feature, splash, routing, flutter_native_splash]
---

# Splash Screen Feature

> **Context:** The Splash screen is the `initial: true` route in `AppRouter`. It runs
> synchronously with DI initialization and hands routing control to either `OnboardingRoute`
> or `HomeRoute` (which is then intercepted by `OnboardingGuard`).

## Overview

`SplashPage` displays the app logo and branding during the brief window between process
launch and the first navigable screen. It removes the native white splash via
`FlutterNativeSplash.remove()`, plays an entrance animation, then routes based on the
result of `CheckIfUserIsFirstTimer`.

---

## Architecture

```
splash/
└── presentation/
    └── pages/
        └── splash_page.dart
```

The splash feature has no data or domain layers. All routing logic is delegated to
`OnboardingGuard` — `SplashPage` only needs to call `router.replace(HomeRoute())` and let
the guard handle the redirect.

---

## Routing Logic

```dart
void navigateNext(BuildContext context, bool isFirstRun) async {
  FlutterNativeSplash.remove();         // Remove native static screen
  await Future.delayed(const Duration(seconds: 2));  // Branding animation
  if (isFirstRun) {
    context.router.replace(const OnboardingRoute());
  } else {
    context.router.replace(const HomeRoute());
    // OnboardingGuard on HomeRoute will verify and redirect if needed.
  }
}
```

---

## Native Splash Configuration

Configured in `pubspec.yaml`:

```yaml
flutter_native_splash:
  color: "#121212"
  image: assets/images/splash.png
  android_12:
    image: assets/images/splash.png
    icon_background_color: "#121212"
```

Run `dart run flutter_native_splash:create` after any change to regenerate the native
drawable and launch screen files.
