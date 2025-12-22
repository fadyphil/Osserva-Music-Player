---
title: User Profile Management
description: How to manage your user identity and application settings.
tags: [feature, profile, settings, user-guide]
---

# User Profile Management

> **Context:** The User Profile feature allows you to view and modify your personal information and application-related settings.

## Overview
Your profile page is where you can update your username, email, profile picture, and manage data like cached information and navigation bar styles.

## Accessing Your Profile

The Profile page is accessible via the main navigation (e.g., a dedicated tab in the Home screen).

## Managing Your Identity

### Updating Profile Details
1.  On the Profile page, tap the **Edit (Pencil)** icon usually found near your profile picture or details.
2.  **Avatar:** Tap the circular avatar to change your profile picture from your device's gallery.
3.  **Username/Email:** Update your Codename (username) and Frequency (email) in the respective fields.
4.  Tap **Save** to apply changes.

## Application Settings

### Change Navigation Bar Style
You can customize the appearance of the bottom navigation bar:
1.  Scroll down to the "Navigation Bar Style" section.
2.  Tap on the various style options (e.g., Simple, Prism, Neural) to preview them.
3.  Your selection will be applied instantly.

### Clear Cache
This action will remove all locally stored application data, including:
-   User profile information.
-   Analytics data.
-   Playlist and Favorites data.
-   **Warning:** This is an irreversible action and will effectively reset the application to its first-run state, requiring you to go through the onboarding process again.
1.  Tap **Clear Cache**.
2.  Confirm your decision in the prompt.
3.  The application will reset and navigate you back to the onboarding screen.

## Technical Details (Reference)

### Data Persistence
User profile information and navigation preferences are stored locally using `shared_preferences`.

### State Management
-   `ProfileBloc` manages the user's profile state and handles updates.

### Logic
-   `GetUserProfile` and `UpdateUserProfile` use cases handle the business logic for profile data.
-   `ClearCache` use case orchestrates the deletion of various local data stores (profile, analytics).
