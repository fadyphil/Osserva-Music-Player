import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:path_provider/path_provider.dart';

/// Bridges MusicPlayerBloc state → Android home screen widget.
/// Register as a singleton in DI and call [init] after the BLoC is ready.
class WidgetSyncService {
  String? _lastSongTitle;
  bool? _lastIsPlaying;
  bool? _lastIsShuffle;
  final MusicPlayerBloc _playerBloc;
  final OnAudioQuery _audioQuery;

  StreamSubscription<MusicPlayerState>? _stateSub;
  StreamSubscription<Uri?>? _clickSub;

  static const _androidWidgetName = 'MusicPlayerWidget';

  WidgetSyncService({
    required MusicPlayerBloc playerBloc,
    required OnAudioQuery audioQuery,
  }) : _playerBloc = playerBloc,
       _audioQuery = audioQuery;

  void init() {
    // Register background callback (required by home_widget even if unused)
    HomeWidget.registerInteractivityCallback(_widgetBackgroundCallback);

    // Handle shuffle button taps (other controls go direct via MediaKey)
    _clickSub = HomeWidget.widgetClicked.listen(_onWidgetClicked);

    // Sync state changes to the widget
    _stateSub = _playerBloc.stream.listen(_onPlayerStateChanged);

    // Push the current state immediately on init
    _onPlayerStateChanged(_playerBloc.state);
  }

  Future<void> _onPlayerStateChanged(MusicPlayerState state) async {
    final title = state.currentSong?.title;
    final isPlaying = state.isPlaying;
    final isShuffle = state.isShuffling;

    // Skip if nothing meaningful changed
    if (title == _lastSongTitle &&
        isPlaying == _lastIsPlaying &&
        isShuffle == _lastIsShuffle) {
      return;
    }

    _lastSongTitle = title;
    _lastIsPlaying = isPlaying;
    _lastIsShuffle = isShuffle;
    debugPrint(
      '[WidgetSync] song=${state.currentSong?.title}, playing=${state.isPlaying}',
    );

    await Future.wait([
      HomeWidget.saveWidgetData<String>(
        'song_title',
        state.currentSong?.title ?? '',
      ),
      HomeWidget.saveWidgetData<String>(
        'artist',
        state.currentSong?.artist ?? '',
      ),
      HomeWidget.saveWidgetData<bool>('is_playing', state.isPlaying),
      HomeWidget.saveWidgetData<bool>('is_shuffle', state.isShuffling),
    ]);

    if (state.currentSong != null) {
      await _saveArtwork(state.currentSong!.id);
    } else {
      await HomeWidget.saveWidgetData<String>('art_path', '');
    }

    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }

  Future<void> _saveArtwork(int songId) async {
    try {
      final art = await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: 200,
        quality: 90,
      );
      if (art != null && art.isNotEmpty) {
        final dir = await getApplicationSupportDirectory();
        final file = File('${dir.path}/widget_art.png');
        await file.writeAsBytes(art);
        await HomeWidget.saveWidgetData<String>('art_path', file.path);
        return;
      }
    } catch (_) {}
    await HomeWidget.saveWidgetData<String>('art_path', '');
  }

  void _onWidgetClicked(Uri? uri) {
    if (uri == null) return;
    if (uri.host == 'shuffle') {
      _playerBloc.add(const MusicPlayerEvent.toggleShuffle());
    }
  }

  void dispose() {
    _stateSub?.cancel();
    _clickSub?.cancel();
  }
}

/// Background callback — runs in a separate isolate when the app is not active.
/// Shuffle is handled in the foreground via [_onWidgetClicked].
/// Play/Pause/Next/Prev are handled natively via MediaKey, so nothing needed here.
@pragma('vm:entry-point')
Future<void> _widgetBackgroundCallback(Uri? uri) async {
  // intentionally empty — see architecture comment above
}
