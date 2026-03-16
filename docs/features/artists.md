---
title: Artists Feature
description: Documentation for the Artist listing and navigation feature.
tags: [feature, ui, artists, browsing]
---

# Artists Feature

> **Context:** This feature is a simple presentation layer that aggregates songs by Artist metadata.

## Overview
The **Artists** feature provides a list view of all unique artists found in the local music library. Tapping on an artist navigates to a filtered view of their songs.

## Architecture

*   **Presentation:** `ArtistsBloc` loads data from the `local_music` repository.
*   **UI:** `ArtistsPage` displays a `ListView` of `ArtistCard` widgets.

## Usage Guide (How-To)

### Loading Artists
The artist list is loaded automatically when the page is built via the `BlocProvider`.

### Code Example: Artist Page Structure
```dart
// IMPORTS
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/features/artists/presentation/bloc/artists/artists_bloc.dart';
import 'package:osserva/features/artists/presentation/bloc/artists/artists_event.dart';

// LOGIC
Widget buildPage() {
  return BlocProvider(
    // Trigger load on creation
    create: (_) => serviceLocator<ArtistsBloc>()..add(const ArtistsEvent.loadArtists()),
    child: BlocBuilder<ArtistsBloc, ArtistsState>(
      builder: (context, state) {
        return state.when(
          loading: () => const CircularProgressIndicator(),
          loaded: (artists) => ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) => ArtistCard(artist: artists[index]),
          ),
          initial: () => const SizedBox(),
          error: (msg) => Text(msg),
        );
      },
    ),
  );
}
```

## Reference: UI Components

| Component | Description |
| :--- | :--- |
| `ArtistCard` | A list tile displaying the artist name and song count. |
