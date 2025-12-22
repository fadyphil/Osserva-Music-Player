import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// This class isolates the "Background Service" logic from the rest of the app.
// It is the Single Source of Truth for the OS.
class MusicPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  final List<AudioSource> _currentQueue = [];
  MusicPlayerHandler({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _init();
  }

  Future<void> _init() async {
    try {
      //NOTE: strict replacement for setAudioSource(ConcatenatingAudioSource(...))
      await _player.setAudioSources(_currentQueue);
    } catch (e) {
      log('Error setting audio sources: $e');
    }
    _initPlayerListeners();
  }

  // 1. Initialize Listeners:
  // Sync just_audio events -> audio_service State
  void _initPlayerListeners() async {
    // Broadcast the current song details to the Lock Screen / Notification
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState.sequence;
      final items = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(items);
      // Update the "Now Playing" item (displays the title  and artwork of song)
      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        mediaItem.add(currentSource.tag as MediaItem);
      }

      // Update the position of the seek bar
    });

    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (duration != null && current != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
    });

    // Broadcast the Play/Pause/Loading state to the OS
    _player.playbackEventStream.listen((event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
          ],
          systemActions: const {
            MediaAction.setShuffleMode,
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
            MediaAction.setRepeatMode,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });

    // CRITICAL: just_audio's playbackEventStream doesn't fire continuously.
    // We need to bridge the position stream to AudioService so the seek bar works in UI.
    // However, AudioService calculates position based on 'updatePosition' + 'speed' * (now - updateTime).
    // So we just need to ensure we emit a state whenever Play/Pause/Seek happens.
    // _player.playbackEventStream handles this for us.
    // BUT, we might need to be explicit about the 'playing' state.
  }

  // 2. Playback Methods (Called by your UI/Repository)

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    if (enabled) {
      await _player.shuffle();
    }
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
      AudioServiceRepeatMode.group: LoopMode.all,
    }[repeatMode]!;
    await _player.setLoopMode(loopMode);
  }

  // 3. Custom Queue Management (The "True Background" Logic)

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    try {
      // Strategy: Always reconstruct the queue to ensure consistency across all platforms.
      final url = mediaItem.extras?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Cannot add  to queue : Url is missing');
      }

      final AudioSource source;
      if (Uri.parse(url).isScheme('content') ||
          Uri.parse(url).isScheme('file')) {
        source = AudioSource.uri(Uri.parse(url), tag: mediaItem);
      } else {
        source = AudioSource.file(url, tag: mediaItem);
      }

      _currentQueue.add(source);
      final currentIndex = _player.currentIndex;
      final currentPos = _player.position;
      await _player.setAudioSources(
        _currentQueue,
        initialIndex: currentIndex,
        initialPosition: currentPos,
      );

      log('Successfuly added to queue: ${mediaItem.title}');
    } catch (e, stack) {
      log('Error adding to queue: $e', stackTrace: stack);
      if (_currentQueue.isNotEmpty) {
        final lastItem = _currentQueue.last;
        if (lastItem is IndexedAudioSource && lastItem.tag is MediaItem) {
          _currentQueue.removeLast();
        }
      }
      rethrow;
    }
  }

  /// Replaces the entire queue and starts playing from [initialIndex]
  Future<void> setQueueItems({
    required List<MediaItem> items,
    required int initialIndex,
  }) async {
    try {
      // 1. Clear the local queue

      _currentQueue.clear();

      // 2. Rebuild list
      final sources = items.map((item) {
        return AudioSource.uri(
          Uri.parse(item.extras!['url'] as String),
          tag: item,
        );
      }).toList();
      _currentQueue.addAll(sources);

      // 3. set sources on player
      await _player.setAudioSources(_currentQueue, initialIndex: initialIndex);

      // 4. Ensure plaback starts
      await _player.play();
    } catch (e, stackTrace) {
      log("Error setting queue: $e", stackTrace: stackTrace);

      // Broadcast error to UI
      playbackState.add(
        playbackState.value.copyWith(
          processingState: AudioProcessingState.error,
          errorMessage: e.toString(),
        ),
      );

      rethrow; // Ensure caller knows about the failure
    }
  }

  // Add this new method to your Handler
  Future<void> insertNextQueueItem(MediaItem mediaItem) async {
    try {
      final url = mediaItem.extras?['url'] as String?;
      if (url == null || url.isEmpty) {
        throw Exception('Cannot add to queue: Url is missing');
      }

      final AudioSource source;
      if (Uri.parse(url).isScheme('content') ||
          Uri.parse(url).isScheme('file')) {
        source = AudioSource.uri(Uri.parse(url), tag: mediaItem);
      } else {
        source = AudioSource.file(url, tag: mediaItem);
      }

      // CALCULATE INSERT POSITION
      // If nothing is playing, add to start.
      // If playing, add right after current index.
      final index = (_player.currentIndex ?? -1) + 1;

      if (index < 0 || index > _currentQueue.length) {
        _currentQueue.add(source); // Fallback to append
      } else {
        _currentQueue.insert(index, source); // Insert specific
      }

      // Update Player
      final currentIndex = _player.currentIndex;
      final currentPos = _player.position;

      await _player.setAudioSources(
        _currentQueue,
        initialIndex: currentIndex,
        initialPosition: currentPos,
      );

      log('Successfully inserted next: ${mediaItem.title}');
    } catch (e) {
      log('Error inserting item: $e');
      rethrow;
    }
  }

  // Legacy/Single Song Fallback (Optional)
  Future<void> playSong({
    required String uri,
    required String title,
    required String artist,
    required String id,
    required String artUri,
  }) async {
    final item = MediaItem(
      id: id,
      album: "Local Music",
      title: title,
      artist: artist,
      artUri: Uri.parse(artUri),
      extras: {'url': uri},
    );
    await setQueueItems(items: [item], initialIndex: 0);
  }
}
