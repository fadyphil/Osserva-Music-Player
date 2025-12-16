import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// This class isolates the "Background Service" logic from the rest of the app.
// It is the Single Source of Truth for the OS.
class MusicPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  ConcatenatingAudioSource? _playlist;

  MusicPlayerHandler({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _initPlayerListeners();
  }

  // 1. Initialize Listeners: Sync just_audio events -> audio_service State
  void _initPlayerListeners() {
    // Broadcast the current song details to the Lock Screen / Notification
    _player.sequenceStateStream.listen((sequenceState) {
      // Update Current Media Item
      final currentItem = sequenceState.currentSource;
      if (currentItem != null) {
        final tag = currentItem.tag as MediaItem;
        mediaItem.add(tag);
      }

      // Update Queue (Optional: if we modify queue dynamically)
      final sequence = sequenceState.sequence;
      if (sequence.isNotEmpty) {
        final items = sequence
            .map((source) => source.tag as MediaItem)
            .toList();
        queue.add(items);
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
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
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
    // Strategy: Always reconstruct the queue to ensure consistency across all platforms.
    final currentMediaItems = queue.hasValue ? queue.value : <MediaItem>[];
    log("Adding item to queue. Current size: ${currentMediaItems.length}. New item: ${mediaItem.title}");

    final newItems = [...currentMediaItems, mediaItem];

    // Capture current state to restore playback position
    final currentIndex = _player.currentIndex ?? 0;
    final currentPos = _player.position;
    final wasPlaying = _player.playing;

    try {
      // Re-set the entire source
      await setQueueItems(items: newItems, initialIndex: currentIndex);

      // Restore state
      await _player.seek(currentPos);
      if (!wasPlaying) {
        await _player.pause();
      }
    } catch (e) {
      log("Add to Queue Failed: $e");
      rethrow;
    }
  }

  /// Replaces the entire queue and starts playing from [initialIndex]
  Future<void> setQueueItems({
    required List<MediaItem> items,
    required int initialIndex,
  }) async {
    try {
      // 1. Convert MediaItems to AudioSources
      final audioSources = items.map((item) {
        final url = item.extras!['url'] as String;
        // Robust handling: Check if it's already a URI (e.g. file:// or http://)
        if (Uri.tryParse(url)?.hasScheme ?? false) {
          return AudioSource.uri(Uri.parse(url), tag: item);
        } else {
          return AudioSource.file(url, tag: item);
        }
      }).toList();

      // 2. Set the player to this playlist and jump to index
      _playlist = ConcatenatingAudioSource(children: audioSources);
      await _player.setAudioSource(_playlist!, initialIndex: initialIndex);

      // 4. Play
      await _player.play();

      // 5. Update AudioService Queue (For UI to see)
      // queue.add is handled by the sequenceStateStream listener
      // mediaItem.add(items[initialIndex]); // also handled by listener
    } catch (e, stackTrace) {
      log("Error setting queue: $e", stackTrace: stackTrace);

      // Broadcast error to UI
      playbackState.add(playbackState.value.copyWith(
        processingState: AudioProcessingState.error,
        errorMessage: e.toString(),
      ));

      rethrow; // Ensure caller knows about the failure
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
