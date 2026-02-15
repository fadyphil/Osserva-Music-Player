import 'package:audio_service/audio_service.dart';
import 'package:music_player/features/background-notification-feature/data/datasources/audio_handler.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/music_player/domain/repos/audio_player_repository.dart';

class AudioPlayerRepositoryImpl implements AudioPlayerRepository {
  // Inject the abstract AudioHandler
  final AudioHandler _audioHandler;

  AudioPlayerRepositoryImpl(this._audioHandler);

  // Helper to access custom methods of our handler
  MusicPlayerHandler get _handler => _audioHandler as MusicPlayerHandler;

  @override
  Future<void> setQueue(List<SongEntity> songs, int initialIndex) async {
    final mediaItems = songs.map((song) {
      final uniqueId = DateTime.now().microsecondsSinceEpoch.toString() +
          song.id.toString(); // Simple unique ID
      return MediaItem(
        id: song.id.toString(),
        album: song.album,
        title: song.title,
        artist: song.artist,
        artUri: song.albumId != null
            ? Uri.parse(
                "content://media/external/audio/albumart/${song.albumId}",
              )
            : null,
        duration: Duration(milliseconds: song.duration.toInt()),
        extras: {'url': song.path, 'uniqueId': uniqueId},
      );
    }).toList();

    await _handler.setQueueItems(items: mediaItems, initialIndex: initialIndex);
  }

  @override
  Future<void> addQueueItem(SongEntity song) async {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString() +
        song.id.toString();
    final item = MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      artUri: song.albumId != null
          ? Uri.parse("content://media/external/audio/albumart/${song.albumId}")
          : null,
      duration: Duration(milliseconds: song.duration.toInt()),
      extras: {'url': song.path, 'uniqueId': uniqueId},
    );
    await _handler.addQueueItem(item);
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    await _handler.removeQueueItemAt(index);
  }

  @override
  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    await _handler.moveQueueItem(oldIndex, newIndex);
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await _handler.skipToQueueItem(index);
  }

  @override
  Future<void> playSong(
    String path,
    String title,
    String artist,
    String songId,
    String albumId,
    String? artUri,
  ) async {
    // Legacy support
    await _handler.playSong(
      uri: path,
      title: title,
      artist: artist,
      id: songId,
      artUri: artUri ?? "content://media/external/audio/media/$songId/albumart",
    );
  }

  @override
  Future<void> pause() => _audioHandler.pause();

  @override
  Future<void> resume() => _audioHandler.play();

  @override
  Future<void> seek(Duration position) => _audioHandler.seek(position);

  @override
  Future<void> stop() => _audioHandler.stop();

  @override
  Future<void> skipToNext() => _audioHandler.skipToNext();

  @override
  Future<void> skipToPrevious() => _audioHandler.skipToPrevious();

  @override
  Future<void> setShuffleMode(bool enabled) {
    return _audioHandler.setShuffleMode(
      enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    );
  }

  @override
  Future<void> setRepeatMode(int mode) {
    final repeatMode = switch (mode) {
      1 => AudioServiceRepeatMode.all,
      2 => AudioServiceRepeatMode.one,
      _ => AudioServiceRepeatMode.none,
    };
    return _audioHandler.setRepeatMode(repeatMode);
  }

  @override
  Future<void> cycleRepeatMode() async {
    // Logic handled by UI calling setRepeatMode
  }

  // STREAMS

  @override
  Stream<bool> get isPlayingStream =>
      _audioHandler.playbackState.map((state) => state.playing).distinct();

  @override
  Stream<bool> get isShuffleModeEnabledStream => _audioHandler.playbackState
      .map((state) => state.shuffleMode == AudioServiceShuffleMode.all)
      .distinct();

  @override
  Stream<int> get loopModeStream => _audioHandler.playbackState.map((state) {
        switch (state.repeatMode) {
          case AudioServiceRepeatMode.none:
            return 0;
          case AudioServiceRepeatMode.all:
            return 1;
          case AudioServiceRepeatMode.one:
            return 2;
          default:
            return 0;
        }
      }).distinct();

  @override
  Stream<Duration> get positionStream => AudioService.position;

  @override
  Stream<Duration> get durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration ?? Duration.zero);

  @override
  Stream<void> get playerCompleteStream => _audioHandler.playbackState
      .where((state) => state.processingState == AudioProcessingState.completed)
      .map((event) => null)
      .distinct();

  @override
  Stream<SongEntity?> get currentSongStream =>
      _audioHandler.mediaItem.map((item) {
        if (item == null) return null;
        return SongEntity(
          id: int.tryParse(item.id) ?? 0,
          title: item.title,
          artist: item.artist ?? 'Unknown',
          album: item.album ?? 'Unknown',
          albumId: int.tryParse(item.artUri?.pathSegments.last ?? ''),
          path: item.extras?['url'] as String? ?? '',
          duration: (item.duration?.inMilliseconds ?? 0).toDouble(),
          size: 0,
          uniqueId: item.extras?['uniqueId'] as String?,
        );
      });

  @override
  Stream<List<SongEntity>> get queueStream {
    // we listen to the AudioHandler's queue (Which comes from just_audio)
    return _audioHandler.queue.map((mediaItems) {
      // Map List<MediaItem> -> List<SongEntity>
      return mediaItems.map((item) {
        return SongEntity(
          id: int.tryParse(item.id) ?? 0,
          title: item.title,
          artist: item.artist ?? 'Unknown',
          album: item.album ?? 'Unknown',
          albumId: int.tryParse(item.artUri?.pathSegments.last ?? ''),
          path: item.extras?['url'] as String? ?? '',
          duration: (item.duration?.inMilliseconds ?? 0).toDouble(),
          size: 0,
          uniqueId: item.extras?['uniqueId'] as String?,
        );
      }).toList();
    });
  }

  @override
  Future<void> playNext(SongEntity song) async {
    final uniqueId = DateTime.now().microsecondsSinceEpoch.toString() +
        song.id.toString();
    final item = MediaItem(
      id: song.id.toString(),
      album: song.album,
      title: song.title,
      artist: song.artist,
      artUri: song.albumId != null
          ? Uri.parse("content://media/external/audio/albumart/${song.albumId}")
          : null,
      extras: {'url': song.path, 'uniqueId': uniqueId},
    );
    await (_audioHandler as MusicPlayerHandler).insertNextQueueItem(item);
  }
}
