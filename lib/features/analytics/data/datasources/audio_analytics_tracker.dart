// lib/features/analytics/data/datasources/audio_analytics_tracker.dart
import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/analytics/domain/usecases/log_playback.dart';

/// Tracks analytics directly at the AudioPlayer level — below the UI layer.
/// This runs in the same context as the AudioHandler, so it always captures
/// playback time regardless of whether the app is foregrounded or backgrounded.
class AudioAnalyticsTracker {
  final AudioPlayer _player;
  final LogPlayback _logPlayback;

  final _subs = <StreamSubscription>[];

  MediaItem? _currentItem;
  Duration _songDuration = Duration.zero;
  DateTime? _playStartTime;
  int _accumulatedMs = 0;
  bool _isPlaying = false;

  AudioAnalyticsTracker(this._player, this._logPlayback);

  void init() {
    _subs.add(_player.playingStream.listen(_onPlayingChanged));
    _subs.add(_player.sequenceStateStream.listen(_onSequenceStateChanged));
    _subs.add(_player.durationStream.listen(_onDurationChanged));
    _subs.add(_player.processingStateStream.listen(_onProcessingStateChanged));
  }

  void _onPlayingChanged(bool isPlaying) {
    final now = DateTime.now();
    if (isPlaying && !_isPlaying) {
      _playStartTime = now;
    } else if (!isPlaying && _isPlaying) {
      if (_playStartTime != null) {
        _accumulatedMs += now.difference(_playStartTime!).inMilliseconds;
        _playStartTime = null;
      }
    }
    _isPlaying = isPlaying;
  }

  void _onDurationChanged(Duration? duration) {
    if (duration != null && duration != Duration.zero) {
      _songDuration = duration;
    }
  }

  void _onSequenceStateChanged(SequenceState? state) {
    final newItem = state?.currentSource?.tag as MediaItem?;
    if (newItem?.id == _currentItem?.id) return; // metadata refresh, skip

    if (_currentItem != null) {
      _finalizeAndLog(_currentItem!, _songDuration);
    }

    _currentItem = newItem;
    _songDuration = newItem?.duration ?? Duration.zero;
    _accumulatedMs = 0;
    _playStartTime = _isPlaying ? DateTime.now() : null;
  }

  void _onProcessingStateChanged(ProcessingState state) {
    if (state == ProcessingState.completed && _currentItem != null) {
      _finalizeAndLog(_currentItem!, _songDuration, forceCompleted: true);
      _accumulatedMs = 0;
      _playStartTime = _isPlaying ? DateTime.now() : null;
    }
  }

  void _finalizeAndLog(
    MediaItem item,
    Duration songDuration, {
    bool forceCompleted = false,
  }) {
    // Snapshot any ongoing session — then immediately restart the clock
    // so the next log doesn't lose time that accrued after this finalize.
    if (_isPlaying && _playStartTime != null) {
      _accumulatedMs += DateTime.now()
          .difference(_playStartTime!)
          .inMilliseconds;
      _playStartTime = DateTime.now(); // restart, not null
    }

    final listenedSeconds = (_accumulatedMs / 1000).round();
    if (listenedSeconds <= 5) return;

    final now = DateTime.now();
    final hour = now.hour;
    final timeOfDay = hour >= 5 && hour < 12
        ? 'morning'
        : hour >= 12 && hour < 18
        ? 'afternoon'
        : 'night';

    final songDurationSeconds = songDuration.inSeconds;
    final isCompleted =
        forceCompleted ||
        (songDurationSeconds > 0 &&
            listenedSeconds >= songDurationSeconds * 0.9);

    final songId = int.tryParse(item.id) ?? 0;

    final playLog = PlayLog(
      songId: songId,
      songTitle: item.title,
      artist: item.artist ?? 'Unknown',
      album: item.album ?? 'Unknown',
      genre: 'Unknown',
      timestamp: now,
      durationListenedSeconds: listenedSeconds,
      isCompleted: isCompleted,
      sessionTimeOfDay: timeOfDay,
    );

    // Fire-and-forget — don't block the stream callback
    _logPlayback(playLog)
        .then(
          (_) => log('Analytics: logged "${item.title}" ${listenedSeconds}s'),
        )
        .catchError((e) => log('Analytics: failed to log "${item.title}": $e'));
  }

  /// Call this when the app process is truly being killed (task removed).
  void flushAndDispose() {
    if (_currentItem != null) {
      _finalizeAndLog(_currentItem!, _songDuration);
    }
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
  }
}
