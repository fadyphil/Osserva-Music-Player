---
title: Favorites Feature
description: How to like songs and manage favorites.
tags: [feature, favorites, user-guide]
---

# Favorites Feature

> **Context:** Favorites allow users to bookmark songs for quick access.

## Overview
The Favorites feature provides a "Like" mechanism (Heart icon) across the application. Liked songs are aggregated in a dedicated "Favorites" list.

## How to Use

### Liking a Song
1. Locate the **Heart Icon** on any song tile or in the player controls.
2. Tap the icon to toggle status.
   - **Filled Heart:** The song is in your favorites.
   - **Outline Heart:** The song is not in your favorites.

### Viewing Favorites
1. Navigate to the **Favorites** page (accessible via Home/Library).
2. The list displays all liked songs, sorted by most recently added.

## Technical Details

### Persistence
- **Database:** `favorites.db` (SQLite).
- **Table:** `favorites` (`song_id`, `added_at`).
- **State:** Managed by `FavoritesBloc` (Global).

### Architecture
- **Use Cases:** `AddFavorite`, `RemoveFavorite`, `GetFavoriteSongs`.
- **Optimization:** The system loads `favoriteIds` (Set) for O(1) lookup in lists, and fetches full `SongEntity` details lazily or when viewing the Favorites page.
