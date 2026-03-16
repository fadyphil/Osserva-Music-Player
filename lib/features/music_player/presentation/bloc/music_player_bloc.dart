import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/usecases/usecase.dart';
import 'package:osserva/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:osserva/features/local_music/domain/usecases/get_song_by_id_use_case.dart';
import 'package:osserva/features/music_player/domain/repos/audio_player_repository.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:stream_transform/stream_transform.dart';

class MusicPlayerBloc extends Bloc<MusicPlayerEvent, MusicPlayerState> {
  final AudioPlayerRepository _audioRepository;

  /// True only while `setQueue` is actively loading a new playlist.
  /// Guards against spurious `mediaItem` emissions from just_audio
  /// during playlist initialisation — but NOT during normal auto-advance.
  bool _isLoadingQueue = false;
  bool _reorderPending = false;
  Timer? _reorderClearTimer;
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
    _positionSubscription = _audioRepository.positionStream
        .throttle(const Duration(milliseconds: 500))
        .listen((pos) {
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

    _queueSubscription = _audioRepository.queueStream.listen((queue) {
      add(MusicPlayerEvent.queueUpdated(queue));
    });

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

    on<MusicPlayerEvent>((event, emit) async {
      await event.map(
        initMusicQueue: (e) async {
          try {
            _isLoadingQueue = true;
            // Optimistic update — UI sees the correct song immediately,
            // before just_audio finishes loading the playlist.
            emit(
              state.copyWith(
                queue: e.songs,
                currentIndex: e.currentIndex,
                currentSong: e.songs[e.currentIndex],
                isPlaying: true,
              ),
            );
            await _audioRepository.setQueue(e.songs, e.currentIndex);
            _isLoadingQueue = false;
          } catch (e) {
            _isLoadingQueue = false;
            emit(
              state.copyWith(errorMessage: "Failed to initialize queue: $e"),
            );
          }
        },
        playSong: (e) async {
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
          await _audioRepository.skipToNext();
        },
        playPreviousSong: (_) async {
          await _audioRepository.skipToPrevious();
        },
        songFinished: (_) async {
          // Only mark playlist end; isPlaying is managed reactively
          // by updatePlayerState (via isPlayingStream) so we don't
          // force it false here — that would break auto-advance.
          emit(state.copyWith(isPlaylistEnd: true));
        },
        pause: (_) async {
          await _audioRepository.pause();
        },
        resume: (_) async {
          await _audioRepository.resume();
        },
        toggleShuffle: (_) async {
          final newValue = !state.isShuffling;
          emit(state.copyWith(isShuffling: newValue));
          await _audioRepository.setShuffleMode(newValue);
        },
        cycleLoopMode: (_) async {
          final nextMode = (state.loopMode + 1) % 3;
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
          if (_reorderPending &&
              state.currentSong != null &&
              e.song.id != state.currentSong!.id) {
            return;
          }

          final index = state.queue.indexWhere((s) => s.id == e.song.id);
          final fullSong = index != -1 ? state.queue[index] : e.song;

          // FIX: Reset the flag unconditionally first, THEN check whether to
          // discard this specific event. The original code left _isLoadingQueue=true
          // on early return, permanently blocking all subsequent updateCurrentSong
          // events (including legitimate auto-advance ones).
          if (_isLoadingQueue) {
            _isLoadingQueue =
                false; // always reset — we only suppress ONE event
            if (state.currentSong != null && index != -1) {
              final expectedSong = state.currentIndex < state.queue.length
                  ? state.queue[state.currentIndex]
                  : null;
              final optimisticIsCorrect =
                  expectedSong != null &&
                  state.currentSong!.id == expectedSong.id;
              final streamContradictsOptimistic =
                  fullSong.id != expectedSong?.id;

              if (optimisticIsCorrect && streamContradictsOptimistic) {
                // Spurious just_audio emission during setQueue init — discard.
                // _isLoadingQueue is already false above; safe to return.
                return;
              }
            }
          }

          final genre = 'Unknown';
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
            await _audioRepository.addQueueItem(e.song);
            emit(state.copyWith(queueActionStatus: QueueStatus.success));
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          } catch (e) {
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
            _reorderPending = true; // ADD
            _reorderClearTimer?.cancel(); // ADD
            await _audioRepository.reorderQueue(e.oldIndex, e.newIndex);
          } catch (e) {
            _reorderPending = false; // ADD
            _reorderClearTimer?.cancel(); // ADD
            emit(
              state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to reorder: $e",
              ),
            );
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        playQueueItem: (e) async {
          try {
            await _audioRepository.skipToQueueItem(e.index);
          } catch (e) {
            emit(
              state.copyWith(
                queueActionStatus: QueueStatus.failure,
                errorMessage: "Failed to play queue item: $e",
              ),
            );
            emit(state.copyWith(queueActionStatus: QueueStatus.initial));
          }
        },
        addToPlaylist: (e) async {},
        queueUpdated: (e) {
          int newIndex = state.currentIndex;
          if (state.currentSong != null && e.queue.isNotEmpty) {
            final byUniqueId = state.currentSong!.uniqueId != null
                ? e.queue.indexWhere(
                    (s) => s.uniqueId == state.currentSong!.uniqueId,
                  )
                : -1;
            final byId = byUniqueId == -1
                ? e.queue.indexWhere((s) => s.id == state.currentSong!.id)
                : -1;
            final resolved = byUniqueId != -1 ? byUniqueId : byId;
            if (resolved != -1) newIndex = resolved;
          }

          // Explicitly re-anchor currentSong to queue[newIndex].
          // This is the safety net: even if a spurious updateCurrentSong
          // slips through below, the state here is definitively correct.
          final anchoredSong = e.queue.isNotEmpty && newIndex < e.queue.length
              ? e.queue[newIndex]
              : state.currentSong;

          emit(
            state.copyWith(
              queue: e.queue,
              currentIndex: newIndex,
              currentSong: anchoredSong, // ADD
            ),
          );

          // Safety valve: keep _reorderPending true long enough to cover
          // both orderings (spurious updateCurrentSong before OR after us).
          // 300ms comfortably outlasts any stream emission latency.
          if (_reorderPending) {
            _reorderClearTimer?.cancel();
            _reorderClearTimer = Timer(const Duration(milliseconds: 300), () {
              _reorderPending = false;
            });
          }
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
            state.copyWith(timerRemaining: null, isEndTrackTimerActive: false),
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
    _reorderClearTimer?.cancel();
    return super.close();
  }
}
