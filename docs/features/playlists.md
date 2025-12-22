---
title: Playlist Management
description: How to create, manage, and play playlists.
tags: [feature, user-guide, playlists]
---

# Playlist Management

> **Context/Prerequisite:** Ensure you have local music files scanned in the application.

## Overview
The Playlist feature allows users to organize their local music collection into custom lists. Users can create, edit, delete playlists, and manage songs within them. This guide covers the basic operations.

## Creating a Playlist

### Steps
1. Navigate to the **Playlists** tab (or access via the Library).
2. Tap the **+ (Add)** button in the top right corner.
3. Enter a **Name** and an optional **Description**.
4. Tap **Create**.

## Managing Songs

### Adding Songs
Currently, songs can be added via the Song List or Player (Implementation Dependent). 
*Future Update:* Select songs directly from the Playlist Detail view.

### Removing Songs
1. Open a Playlist.
2. Swipe left on a song or tap the **Remove** icon.
3. Confirm if prompted.

## Editing Playlist Details
1. Open the Playlist.
2. Tap the **Edit (Pencil)** icon in the header.
3. Update the Name or Description.
4. Tap **Save**.

## Technical Details (Reference)

### Data Structure
Playlists are stored in a local SQLite database (`playlists.db`).
- **Entity:** `PlaylistEntity`
- **Tables:** `playlists`, `playlist_songs`

### Limitations
- Only local files are supported.
- Playlists are local-only and do not sync to cloud.
