import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:music_player/features/music_player/domain/repos/audio_player_repository.dart';
import 'package:music_player/features/local%20music/domain/use%20cases/get_song_by_id_use_case.dart';
import 'music_player_event.dart';
import 'music_player_state.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final AudioPlayerRepository _audioRepository;
  final GetSongByIdUseCase _getSongByIdUseCase;
  final GetAllSongPlayCounts _getAllSongPlayCounts;

  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _completionSubscription;
  StreamSubscription? _currentSongSubscription;
  StreamSubscription? _shuffleSubscription;
  StreamSubscription? _loopSubscription;
  StreamSubscription? _queueSubscription;

  Timer? _sleepTimer;

  MusicPlayerBloc(
    this._audioRepository,
    this._getSongByIdUseCase,
    this._getAllSongPlayCounts,
  ) : super(const MusicPlayerState()) {
    // 1. Setup Listeners
    _positionSubscription = _audioRepository.positionStream.listen((pos) {
      add(MusicPlayerEvent.updatePosition(pos));
    });

    _durationSubscription = _audioRepository.durationStream.listen((dur) {
      add(MusicPlayerEvent.updateDuration(dur));
    });

    _playerStateSubscription = _audioRepository.isPlayingStream.listen((
      isPlaying,
    ) {
      add(MusicPlayerEvent.updatePlayerState(isPlaying));
    });

    _shuffleSubscription = _audioRepository.isShuffleModeEnabledStream.listen((
      enabled,
    ) {
      add(MusicPlayerEvent.updateShuffleState(enabled));
    });

    _loopSubscription = _audioRepository.loopModeStream.listen((mode) {
      add(MusicPlayerEvent.updateLoopState(mode));
    });

    // Subscribe to the truth
    // when the repo (and handler) changes the queue this listener fires
    _queueSubscription = _audioRepository.queueStream.listen((queue) {
      add(MusicPlayerEvent.queueUpdated(queue));
    });

    // Listen to the Operating System / Audio Service for the current song
    _currentSongSubscription = _audioRepository.currentSongStream.listen((
      song,
    ) {
      if (song != null) {
        add(MusicPlayerEvent.updateCurrentSong(song));
      }
    });

    _completionSubscription = _audioRepository.playerCompleteStream.listen((_) {
      add(const MusicPlayerEvent.songFinished());
    });

    _refreshPlayCounts();

    // 2. Handle Events
    on<MusicPlayerEvent>((event, emit) async {
      await event.map(
        initMusicQueue: (e) async {
          try {
            // Optimistic update
            emit(
              state.copyWith(
                queue: e.songs,
                currentIndex: e.currentIndex,
                currentSong: e.songs[e.currentIndex],
                isPlaying: true,
              ),
            );
            // Delegate to Handler
            await _audioRepository.setQueue(e.songs, e.currentIndex);
          } catch (e) {
            // Revert or show error
            // If "Loading interrupted", it's fine.
            emit(
              state.copyWith(
                errorMessage: "Failed to initialize queue: $e",
              ),
            );
          }
        },
        playSong: (e) async {
          // Play Single Song (Legacy/Specific use case)
          emit(state.copyWith(currentSong: e.song, isPlaying: true));
          final artworkUri =
              "content://media/external/audio/media/${e.song.id}/albumart";
          await _audioRepository.playSong(
            e.song.path,
            e.song.title,
            e.song.artist,
            e.song.id.toString(),
            e.song.album,
            artworkUri,
          );
        },
        playSongById: (e) async {
          final result = await _getSongByIdUseCase(e.songId);
          result.fold(
            (failure) {
              emit(
                state.copyWith(
                  queueActionStatus: QueueStatus.failure,
                  errorMessage: 'Failed to play song: ${failure.message}',
                ),
              );
              emit(state.copyWith(queueActionStatus: QueueStatus.initial));
            },
            (song) {
              add(MusicPlayerEvent.playSong(song: song));
            },
          );
        },
        playNextSong: (_) async {
          // Delegate to Handler
          await _audioRepository.skipToNext();
        },
        playPreviousSong: (_) async {
          // Delegate to Handler
          await _audioRepository.skipToPrevious();
        },
        songFinished: (_) async {
          // The player handles song transitions automatically.
          // This event now only signifies the END of the entire playlist.
          emit(state.copyWith(isPlaying: false, isPlaylistEnd: true));
        },
        pause: (_) async {
          await _audioRepository.pause();
        },
        resume: (_) async {
          await _audioRepository.resume();
        },
        toggleShuffle: (_) async {
          final newValue = !state.isShuffling;
          // Optimistic update
          emit(state.copyWith(isShuffling: newValue));
          await _audioRepository.setShuffleMode(newValue);
        },
        cycleLoopMode: (_) async {
          final nextMode = (state.loopMode + 1) % 3;
          // Optimistic update
          emit(state.copyWith(loopMode: nextMode));
          await _audioRepository.setRepeatMode(nextMode);
        },
        seek: (e) async {
          emit(state.copyWith(position: e.position));
          await _audioRepository.seek(e.position);
        },
        updatePosition: (e) async {
          emit(state.copyWith(position: e.position));
        },
        updateDuration: (e) async {
          emit(state.copyWith(duration: e.duration));
        },
        updatePlayerState: (e) async {
          emit(state.copyWith(isPlaying: e.isPlaying));
        },
        updateShuffleState: (e) async {
          emit(state.copyWith(isShuffling: e.isShuffleModeEnabled));
        },
        updateLoopState: (e) async {
          emit(state.copyWith(loopMode: e.loopMode));
        },
        updateCurrentSong: (e) async {
          // Try to match the incoming song (from OS) with our full-detail queue
          final index = state.queue.indexWhere((s) => s.id == e.song.id);
          final fullSong = index != -1 ? state.queue[index] : e.song;

          // Placeholder: Fetch genre if needed. For now, we assume it's unknown
          // as SongEntity doesn't have it.
          const genre = 'Unknown';

          final bool isChangingTrack =
              state.currentSong != null && state.currentSong!.id != fullSong.id;

          emit(
            state.copyWith(
              currentSong: fullSong,
              currentIndex: index != -1 ? index : state.currentIndex,
              currentGenre: genre,
            ),
          );

          if (state.isEndTrackTimerActive && isChangingTrack) {
            add(const MusicPlayerEvent.pause());
            add(const MusicPlayerEvent.cancelTimer());
          }
        },
        updatePlayCounts: (e) async {
          emit(state.copyWith(playCounts: e.playCounts));
        },
        addToQueue: (e) async {
          try {
            // we ask the repo to add it
            // we DO NOT update the UI state locally
            // we wait for the 'queueUpdated' event to  fire via the stream
            await _audioRepository.addQueueItem(e.song);
            // Emit Success status to trigger Green snackbar
            emit(state.copyWith(queueActionStatus: QueueStatus.success));
            // Immediately reset status so  it doesn't trigger again on the next rebuild
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
            // OPTIONAL : Emit a 'Side Effect' for the UI (Like a Snackbar trigger)
            // you might have a separate status field for the one-off messages
            // emit(state.copyWith(status: Status.success, message: 'Song added to queue'))
          } catch (e) {
            // if the handler failed (bad URL) , we catch it here
            // the queue list in the state never changed
            // the UI shows an error
            // emit(state.copyWith(status: Status.error, message: e.toString()));
            emit(
              state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Couldn't add song : $e",
              ),
            );
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        removeFromQueue: (e) async {
          try {
            await _audioRepository.removeQueueItemAt(e.index);
            // Success status (optional, maybe no snackbar needed for removal)
          } catch (e) {
            emit(
              state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to remove song: $e",
              ),
            );
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        reorderQueue: (e) async {
          try {
            await _audioRepository.reorderQueue(e.oldIndex, e.newIndex);
          } catch (e) {
             emit(state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to reorder: $e"
             ));
             emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        playQueueItem: (e) async {
          try {
            await _audioRepository.skipToQueueItem(e.index);
          } catch (e) {
            emit(state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to play queue item: $e"
            ));
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        addToPlaylist: (e) async {
          // Placeholder for Playlist feature
          // Ideally, this would open a dialog in UI, but the Bloc just handles logic.
          // Since we don't have a playlist Repo yet, we do nothing or just emit a side-effect if needed.
          // For now, no state change.
        },
        queueUpdated: (e) {
          // This is the ONLY place state.queue should change
          emit(state.copyWith(queue: e.queue));
        },
        playNextinQueue: (e) async {
          try {
            await _audioRepository.playNext(e.song);
            emit(state.copyWith(queueActionStatus: QueueStatus.success));
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          } catch (e) {
            emit(
              state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to set play next song : $e",
              ),
            );
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        setTimer: (e) async {
          _sleepTimer?.cancel();
          emit(
            state.copyWith(
              timerRemaining: e.duration,
              isEndTrackTimerActive: false,
            ),
          );
          _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            add(const MusicPlayerEvent.tickTimer());
          });
        },
        setEndTrackTimer: (e) async {
          _sleepTimer?.cancel();
          emit(
            state.copyWith(
              timerRemaining: null,
              isEndTrackTimerActive: e.active,
            ),
          );
        },
        cancelTimer: (_) async {
          _sleepTimer?.cancel();
          emit(
            state.copyWith(
              timerRemaining: null,
              isEndTrackTimerActive: false,
            ),
          );
        },
        tickTimer: (_) async {
          if (state.timerRemaining != null) {
            final newDuration =
                state.timerRemaining! - const Duration(seconds: 1);
            if (newDuration.isNegative || newDuration == Duration.zero) {
              _sleepTimer?.cancel();
              emit(state.copyWith(timerRemaining: Duration.zero));
              add(const MusicPlayerEvent.pause());
              add(const MusicPlayerEvent.cancelTimer());
            } else {
              emit(state.copyWith(timerRemaining: newDuration));
            }
          }
        },
      );
    });
  }

  Future<void> _refreshPlayCounts() async {
    final result = await _getAllSongPlayCounts(NoParams());
    result.fold((_) => null, (counts) {
      add(MusicPlayerEvent.updatePlayCounts(counts));
    });
  }

  @override
  Future<void> close() {
    _sleepTimer?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _completionSubscription?.cancel();
    _currentSongSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopSubscription?.cancel();
    _queueSubscription?.cancel();
    return super.close();
  }
}
