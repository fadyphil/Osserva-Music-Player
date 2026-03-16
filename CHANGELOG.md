# Changelog

## [1.0.0] - 2026-03-16

### Added
- **Rebranded application to Osserva** (formerly AudioGraphy/Music Player)
- Updated launcher icons and splash screen assets with new high-resolution "Osserva" branding
- Replaced `MusicPlayerSheet` with full-screen `MusicPlayerRoute` overlay
- Added proper loop track wraparound detection in `AudioAnalyticsTracker` for LoopMode.one

### Fixed
- Fixed analytics hot path by using `SUM(play_count)` instead of `COUNT(*)` for correct play count aggregations
- Fixed duration accumulation in analytics recorder by retrieving missing `timestamp` in the query
- Fixed analytics timeframes referencing floating 24-hour windows to local midnight anchors
- Fixed 'evening' time of day bucket to properly cover 18:00-21:59 instead of being swallowed by 'night'
- Fixed `MusicPlayerBloc` state desync by discarding spurious just_audio emissions during queue load
- Fixed sort preference not applying on initial local music load

### Refactored
- Renamed all feature folders from `kebab-case` and `space case` to `snake_case`
- Extracted feature DI into per-module files under `core/di/modules/`
- Replaced `Map<String,dynamic>` domain boundary leak with typed `ArtistStats` entity
- Replaced `Future.wait` + `as dynamic` casts with Dart 3 record `.wait` in `AnalyticsBloc`
- `MusicPlayerBloc` changed from singleton to factory registration
- Cleaned up local music sliver UI and replaced static string literals

### Removed
- Deleted `mock_*` and `*_old` widget variants (archived at git tag `legacy-ui-archived`)
- Deleted `analytics_dashboard_page_new.dart` and `library_page_old.dart`
- Promoted `new_widgets/` contents into parent `widgets/` folder
