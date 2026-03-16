// lib/features/analytics/data/datasources/audio_analytics_tracker.dart
import 'dart:async';
import 'dart:developer';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';
import 'package:osserva/features/analytics/domain/usecases/log_playback.dart';

/// Tracks analytics directly at the AudioPlayer level — below the UI layer.
/// Always captures playback time regardless of foreground/background state.
class AudioAnalyticsTracker {
  final AudioPlayer _player;
  final LogPlayback _logPlayback;

  final _subs = <StreamSubscription>[];

  MediaItem? _currentItem;
  Duration _songDuration = Duration.zero;
  DateTime? _playStartTime;
  int _accumulatedMs = 0;
  bool _isPlaying = false;

  // FIX: Loop tracking — track last known position to detect wraparound.
  // In LoopMode.one, just_audio silently restarts: ProcessingState.completed
  // never fires and _onSequenceStateChanged short-circuits (same item id).
  // The only observable signal is the position jumping from near-end back to 0.
  Duration _lastPosition = Duration.zero;

  // How close to the end (in seconds) we must be before a position reset
  // counts as a loop rather than a manual seek-to-start.
  static const int _loopEndThresholdSeconds = 4;

  AudioAnalyticsTracker(this._player, this._logPlayback);

  void init() {
    _subs.add(_player.playingStream.listen(_onPlayingChanged));
    _subs.add(_player.sequenceStateStream.listen(_onSequenceStateChanged));
    _subs.add(_player.durationStream.listen(_onDurationChanged));
    _subs.add(_player.processingStateStream.listen(_onProcessingStateChanged));
    // Loop detection — must come after the others are registered.
    _subs.add(_player.positionStream.listen(_onPositionChanged));
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

  void _onPositionChanged(Duration position) {
    // Detect loop: position was near the end of the track and has reset to the
    // beginning while the same item is still playing. This is the only reliable
    // signal for LoopMode.one because just_audio never emits completed.
    final durationSec = _songDuration.inSeconds;
    if (_isPlaying &&
        _currentItem != null &&
        durationSec > 0 &&
        _lastPosition.inSeconds >= durationSec - _loopEndThresholdSeconds &&
        position.inSeconds < _loopEndThresholdSeconds) {
      // The song wrapped around — log the completed play, reset the clock.
      _finalizeAndLog(_currentItem!, _songDuration, forceCompleted: true);
      _accumulatedMs = 0;
      _playStartTime = DateTime.now();
    }
    _lastPosition = position;
  }

  void _onSequenceStateChanged(SequenceState? state) {
    final newItem = state?.currentSource?.tag as MediaItem?;
    // Same item id means a metadata refresh or the loop guard handled it —
    // skip to avoid double-logging.
    if (newItem?.id == _currentItem?.id) return;

    if (_currentItem != null) {
      _finalizeAndLog(_currentItem!, _songDuration);
    }

    _currentItem = newItem;
    _songDuration = newItem?.duration ?? Duration.zero;
    _accumulatedMs = 0;
    _lastPosition = Duration.zero;
    _playStartTime = _isPlaying ? DateTime.now() : null;
  }

  void _onProcessingStateChanged(ProcessingState state) {
    // Fires on track completion in normal (non-loop-one) playback.
    if (state == ProcessingState.completed && _currentItem != null) {
      _finalizeAndLog(_currentItem!, _songDuration, forceCompleted: true);
      _accumulatedMs = 0;
      _lastPosition = Duration.zero;
      _playStartTime = _isPlaying ? DateTime.now() : null;
    }
  }

  void _finalizeAndLog(
    MediaItem item,
    Duration songDuration, {
    bool forceCompleted = false,
  }) {
    // Snapshot any ongoing session then restart the clock so the next play
    // doesn't lose time that accrued after this finalize.
    if (_isPlaying && _playStartTime != null) {
      _accumulatedMs += DateTime.now()
          .difference(_playStartTime!)
          .inMilliseconds;
      _playStartTime = DateTime.now();
    }

    final listenedSeconds = (_accumulatedMs / 1000).round();
    if (listenedSeconds <= 5) return;

    final now = DateTime.now();
    final hour = now.hour;
    // FIX: Added 'evening' bucket (18:00–21:59).
    // Previously everything from 18:00 onward collapsed into 'night',
    // making the time-of-day chart unrepresentative for evening listeners.
    // Buckets: morning 05–11, afternoon 12–17, evening 18–21, night 22–04.
    final timeOfDay = hour >= 5 && hour < 12
        ? 'morning'
        : hour >= 12 && hour < 18
        ? 'afternoon'
        : hour >= 18 && hour < 22
        ? 'evening'
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

    _logPlayback(playLog)
        .then(
          (_) => log('Analytics: logged "${item.title}" ${listenedSeconds}s'),
        )
        .catchError((e) => log('Analytics: failed to log "${item.title}": $e'));
  }

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
