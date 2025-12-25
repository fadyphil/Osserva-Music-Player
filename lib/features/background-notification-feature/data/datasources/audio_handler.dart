import 'dart:developer';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

// This class isolates the "Background Service" logic from the rest of the app.
// It is the Single Source of Truth for the OS.
class MusicPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player;
  MusicPlayerHandler({AudioPlayer? player})
    : _player = player ?? AudioPlayer() {
    _init();
  }

  Future<void> _init() async {
    try {
      //NOTE: strict replacement for setAudioSource(ConcatenatingAudioSource(...))
      await _player.setAudioSources([]);
    } catch (e) {
      log('Error setting audio sources: $e');
    }
    _initPlayerListeners();
  }

  // 1. Initialize Listeners

  void _initPlayerListeners() {
    // 1. Listen to Playlist Changes (Queue)
    _player.sequenceStateStream.listen((sequenceState) {
      final sequence = sequenceState.sequence;
      final items = sequence.map((source) => source.tag as MediaItem).toList();
      queue.add(items);

      final currentSource = sequenceState.currentSource;
      if (currentSource != null) {
        mediaItem.add(currentSource.tag as MediaItem);
      }
    });

    // 2. Listen to Duration
    _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (duration != null && current != null) {
        if (current.duration != duration) {
          mediaItem.add(current.copyWith(duration: duration));
        }
      }
    });

    // 3. LISTEN TO ALL STATE CHANGES
    // We listen to all 3 streams. If ANY of them fire, we run _broadcastState().
    // This ensures icons and play/pause state are always in sync.
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.shuffleModeEnabledStream.listen((_) => _broadcastState());
    _player.loopModeStream.listen((_) => _broadcastState());
    _player.playingStream.listen((_) => _broadcastState());
    _player.processingStateStream.listen((_) => _broadcastState());
  }

  /// HELPER: Builds the notification state dynamically
  void _broadcastState() {
    final playing = _player.playing;
    final shuffleMode = _player.shuffleModeEnabled;
    final loopMode = _player.loopMode;

    // Fix for Duration: If mediaItem has no duration but player does, update it.
    if (mediaItem.value != null &&
        mediaItem.value!.duration == null &&
        _player.duration != null) {
      mediaItem.add(mediaItem.value!.copyWith(duration: _player.duration));
    }

    // --- 1. Define Shuffle Button ---
    final shuffleControl = MediaControl.custom(
      // Swap icon based on state
      androidIcon: shuffleMode
          ? 'drawable/ic_shuffle_on'
          : 'drawable/ic_shuffle',
      label: 'Shuffle',
      name: 'shuffle_mode', // Custom action name
    );

    // --- 2. Define Repeat Button ---
    final MediaControl repeatControl;
    if (loopMode == LoopMode.one) {
      repeatControl = MediaControl.custom(
        androidIcon: 'drawable/ic_repeat_one',
        label: 'Repeat One',
        name: 'repeat_mode',
      );
    } else if (loopMode == LoopMode.all) {
      repeatControl = MediaControl.custom(
        androidIcon:
            'drawable/ic_repeat_on', // Optional: Different icon for Loop All
        label: 'Repeat All',
        name: 'repeat_mode',
      );
    } else {
      repeatControl = MediaControl.custom(
        androidIcon: 'drawable/ic_repeat',
        label: 'Repeat Off',
        name: 'repeat_mode',
      );
    }

    // --- 3. Build the Full List of Controls ---
    // We recreate the list every time something changes so we don't lose buttons.
    final controls = [
      shuffleControl,
      MediaControl.skipToPrevious,
      playing ? MediaControl.pause : MediaControl.play,
      MediaControl.skipToNext,
      repeatControl,
    ];

    // --- 4. Broadcast to System ---
    playbackState.add(
      playbackState.value.copyWith(
        controls: controls,
        // Shows: Prev, Play/Pause, Next in the compact (small) notification
        androidCompactActionIndices: const [1, 2, 3],

        systemActions: const {
          MediaAction.setShuffleMode,
          MediaAction.setRepeatMode,
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
        },

        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,

        // Inform the OS of the specific modes (important for Android Auto/Bluetooth)
        shuffleMode: shuffleMode
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        repeatMode: loopMode == LoopMode.one
            ? AudioServiceRepeatMode.one
            : (loopMode == LoopMode.all
                  ? AudioServiceRepeatMode.all
                  : AudioServiceRepeatMode.none),
        processingState: _getProcessingState(),
      ),
    );
  }

  // Helper function to map states safely without crashing
  AudioProcessingState _getProcessingState() {
    // 1. Check if the player has an error (AudioService needs to know this)
    // just_audio keeps state as 'idle' on error, so we check explicitly.
    /* 
       Note: just_audio doesn't have a direct 'hasError' boolean on the player 
       that persists easily in this context without tracking it manually, 
       but standard mapping is usually sufficient unless you are handling broken URLs.
    */

    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }

  // 2. Playback Methods (Called by your UI/Repository)

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == 'shuffle_mode') {
      final mode = _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.none
          : AudioServiceShuffleMode.all;
      await setShuffleMode(mode);
    } else if (name == 'repeat_mode') {
      final current = _player.loopMode;
      final next = {
        LoopMode.off: AudioServiceRepeatMode.all,
        LoopMode.all: AudioServiceRepeatMode.one,
        LoopMode.one: AudioServiceRepeatMode.none,
      }[current]!;
      await setRepeatMode(next);
    }
  }

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

      await _player.addAudioSource(source);

      log('Successfuly added to queue: ${mediaItem.title}');
    } catch (e, stack) {
      log('Error adding to queue: $e', stackTrace: stack);

      rethrow;
    }
  }

  /// Replaces the entire queue and starts playing from [initialIndex]
  Future<void> setQueueItems({
    required List<MediaItem> items,
    required int initialIndex,
  }) async {
    try {
      // 2. Rebuild list
      final sources = items.map((item) {
        return AudioSource.uri(
          Uri.parse(item.extras!['url'] as String),
          tag: item,
        );
      }).toList();

      // FIX FOR FIRST SONG BUG:
      // Force stop the player before loading a completely new list.
      // This clears the buffer and prevents "ghosting" of the first track.
      if (_player.playing) {
        await _player.stop();
      }

      // 3. set sources on player
      await _player.setAudioSources(
        sources,
        initialIndex: initialIndex,
        initialPosition: Duration.zero,
      );

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

      final currentIndex = _player.currentIndex;

      if (currentIndex == null || (_player.sequence.isEmpty)) {
        await _player.setAudioSource(source);
      } else {
        final nextIndex = currentIndex + 1;
        await _player.insertAudioSource(nextIndex, source);
      }

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
    Duration? duration,
  }) async {
    final item = MediaItem(
      id: id,
      album: "Local Music",
      title: title,
      artist: artist,
      artUri: Uri.parse(artUri),
      extras: {'url': uri},
      duration: duration,
    );
    await setQueueItems(items: [item], initialIndex: 0);
  }
}
