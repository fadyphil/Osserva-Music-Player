# Changelog

All notable changes to Osserva are documented here.  
Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [1.0.0] - 2026-03-16

### Added
- Background playback with lock-screen notification controls
- Full-screen music player
- Listening analytics: play counts, top artists/albums/genres,
  time-of-day distribution, and activity heatmap
- Playlist creation, editing, and per-song management
- Favorites with persistent local storage
- Artist browsing with per-artist stats
- Song metadata editing with custom artwork support
- Onboarding flow with Android 13+ permission handling

### Fixed
- Play counts reported incorrect totals for songs played multiple times
- Listening time undercounted sessions due to missing timestamp in query
- Analytics time windows now anchor to local midnight, fixing "Today" 
  and weekly breakdowns
- Evening activity (18:00–21:59) was incorrectly grouped under "Night"
- Queue reorder flashed the wrong current song during drag-and-drop
- Sort preference was ignored on initial library load
- Background playback notification failed in release builds

### Known Issues
- iOS not validated on device
- BLoC unit test coverage is partial