import 'package:osserva/features/local_music/domain/entities/song_entity.dart';

abstract class AudioPlayerRepository {
  // Actions
  Future<void> setQueue(List<SongEntity> songs, int initialIndex);
  Future<void> addQueueItem(SongEntity song);
  Future<void> removeQueueItemAt(int index);
  Future<void> reorderQueue(int oldIndex, int newIndex);
  Future<void> skipToQueueItem(int index);
  Future<void> playNext(SongEntity song);

  // Legacy / Single Song
  Future<void> playSong(
    String path,
    String title,
    String artist,
    String songId,
    String albumId,
    String? artUri,
  );

  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> skipToNext();
  Future<void> skipToPrevious();

  Future<void> setShuffleMode(bool enabled);
  Future<void> setRepeatMode(int mode); // 0: Off, 1: All, 2: One
  // Actually, UI usually cycles: Off -> All -> One -> Off
  Future<void> cycleRepeatMode();

  // Data Streams (The UI listens to these to update the slider/buttons)
  Stream<bool> get isPlayingStream;
  Stream<bool> get isShuffleModeEnabledStream;
  Stream<int> get loopModeStream; // 0: off, 1: all, 2: one
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;
  Stream<void> get playerCompleteStream; // Listen to queue end or song end?
  Stream<SongEntity?>
  get currentSongStream; // New: Listen to current song updates from OS
  Stream<List<SongEntity>> get queueStream;
}
