---
title: Onboarding and User Registration
description: Guide for first-time users to set up their profile.
tags: [feature, onboarding, user-registration, user-guide]
---

# Onboarding and User Registration

> **Context:** This guide is for new users experiencing the application for the first time.

## Overview
The onboarding process guides you through the initial setup of your application, including a brief introduction to its features and the creation of your user profile (identity).

## First-Time Experience

When you launch the application for the very first time:
1.  You will see a series of introductory screens highlighting the key features of the music player.
2.  Tap **Next** to proceed through these screens.
3.  On the final onboarding screen, you will be prompted to either **Skip** the user registration or **Proceed** to create your identity.

## Creating Your Identity (User Registration)

If you choose to create your identity:
1.  **Avatar:** Tap the camera icon or the circular avatar placeholder to upload a profile picture from your device's gallery.
2.  **Codename (Username):** Enter your preferred username. This will be visible within your profile.
3.  **Frequency (Email):** Enter your email address. This is used for identification and potentially for future account recovery.
4.  Tap the **Initialize** button to complete your registration.

Upon successful registration, you will be taken to the main application interface.

## Technical Details (Reference)

### Data Persistence
User registration data (username, email, avatar path) is stored locally using `shared_preferences`. The system also logs the completion of onboarding.

### State Management
-   `OnboardingCubit` manages the state of the onboarding screens and caches the 'first-timer' status.
-   `UserRegistrationCubit` handles the form submission and profile creation.

### Logic
The `CheckIfUserIsFirstTimer` use case determines if the user has completed the onboarding flow, guiding the initial navigation after the splash screen.
