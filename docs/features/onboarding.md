---
title: Onboarding Feature
description: First-run detection, user registration flow, and Android Auto Backup fix.
tags: [feature, onboarding, shared_preferences, routing, android]
---

# Onboarding Feature

> **Context:** The onboarding state is stored in `SharedPreferences` under the key
> `is_first_timer`. The `OnboardingGuard` on `HomeRoute` reads this key on every cold start
> to decide whether to redirect.

## Overview

The Onboarding feature handles first-run detection, the introductory screen sequence, and
user profile creation (codename + avatar). After the user completes or skips onboarding,
`is_first_timer` is set to `false` and `OnboardingGuard` allows navigation to `HomeRoute`
on all subsequent launches.

---

## Architecture

```
onboarding/
├── data/
│   ├── datasources/
│   │   └── onboarding_local_data_source.dart   # SharedPreferences wrapper
│   └── repositories/
│       └── onboarding_repository_impl.dart
├── domain/
│   ├── failure/
│   │   └── onboarding_failure.dart
│   ├── repositories/
│   │   └── onboarding_repository.dart
│   └── usecases/
│       ├── check_if_user_is_first_timer.dart
│       ├── cache_first_timer.dart
│       └── log_onboarding_complete.dart
└── presentation/
    ├── cubit/
    │   ├── onboarding_cubit.dart
    │   ├── user_registration_cubit.dart
    │   └── user_registration_state.dart
    ├── pages/
    │   ├── onboarding_page.dart
    │   └── user_registration_page.dart
    └── widgets/
        └── onboarding_content.dart
```

---

## First-Run Detection

`OnboardingLocalDataSourceImpl` reads `SharedPreferences`:

```dart
Future<bool> checkIfUserIsFirstTimer() async {
  return sharedPreferences.getBool('is_first_timer') ?? true;
  // Returns true if key is absent (fresh install) → redirect to onboarding.
}

Future<void> cacheFirstTimer() async {
  await sharedPreferences.setBool('is_first_timer', false);
  // Called once onboarding is complete.
}
```

Both methods wrap their operations in `try/catch` and throw `OnboardingFailure` on error.

---

## Navigation Guard

`OnboardingGuard` intercepts navigation to `HomeRoute` on every cold start. It resolves
`CheckIfUserIsFirstTimer` from the service locator at call time (not at construction time),
so the check is always fresh.

On `SharedPreferences` failure, the guard defaults to showing onboarding rather than
letting a potentially invalid state through to `HomeRoute`.

---

## User Registration Flow

After the introductory screens, the user lands on `UserRegistrationPage`:

1. **Avatar** — Gallery image picker; stored as a local file path in `UserEntity.avatarUrl`.
2. **Codename** — Username, stored in `UserEntity.username`.
3. **Frequency** — Email, stored in `UserEntity.email`.
4. **Initialize** — Tapping this button calls `UserRegistrationCubit`, which:
   - Calls `UpdateUserProfile` to persist the profile via `ProfileRepository`.
   - Calls `LogOnboardingComplete` to set `is_first_timer = false`.
   - Calls `CacheFirstTimer` as a secondary write (belt-and-suspenders).

The user can also skip registration; in that case `cacheFirstTimer` is called with the
default profile and onboarding is marked complete.

---

## Android Auto Backup — Critical Fix

Android Auto Backup (enabled by default on Android 6+) can back up and restore
`SharedPreferences` files to Google Drive. If a user clears app data or reinstalls on a new
device, Android may restore a `SharedPreferences` file where `is_first_timer = false`,
causing the app to skip onboarding on what is effectively a fresh install.

**Fix:** Exclude `SharedPreferences` from Auto Backup in `AndroidManifest.xml`:

```xml
<application
  android:allowBackup="true"
  android:fullBackupContent="@xml/backup_rules"
  ...>
```

`res/xml/backup_rules.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<full-backup-content>
  <exclude domain="sharedpref" path="FlutterSharedPreferences.xml" />
</full-backup-content>
```

Without this exclusion, clearing app data and reinstalling may appear to bypass onboarding.

---

## Reference: Use Cases

| Use Case | Params | Returns |
| :--- | :--- | :--- |
| `CheckIfUserIsFirstTimer` | `NoParams` | `Either<OnboardingFailure, bool>` |
| `CacheFirstTimer` | `NoParams` | `Either<OnboardingFailure, void>` |
| `LogOnboardingComplete` | `NoParams` | `Either<OnboardingFailure, void>` |

## Reference: Cubits

| Cubit | Responsibility |
| :--- | :--- |
| `OnboardingCubit` | Manages intro screen state and calls `CacheFirstTimer` on skip. |
| `UserRegistrationCubit` | Handles form submission, calls `UpdateUserProfile`, `LogOnboardingComplete`, `CacheFirstTimer`. |
