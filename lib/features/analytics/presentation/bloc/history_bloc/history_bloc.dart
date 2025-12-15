import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/analytics/domain/usecases/get_playback_history.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetPlaybackHistory _getPlaybackHistory;

  HistoryBloc({required GetPlaybackHistory getPlaybackHistory})
      : _getPlaybackHistory = getPlaybackHistory,
        super(const HistoryState.initial()) {
    on<_FetchRecentHistory>(_onFetchRecentHistory);
    on<_FetchAllHistory>(_onFetchAllHistory);
  }

  Future<void> _onFetchRecentHistory(
    _FetchRecentHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryState.loading());
    final result = await _getPlaybackHistory(const GetPlaybackHistoryParams(limit: 10));

    result.fold(
      (failure) => emit(HistoryState.failure(failure.message)),
      (logs) => emit(HistoryState.loaded(recentSongs: logs)),
    );
  }

  Future<void> _onFetchAllHistory(
    _FetchAllHistory event,
    Emitter<HistoryState> emit,
  ) async {
    // If we already have recent songs, keep them.
    final currentRecent = state.maybeMap(
      loaded: (s) => s.recentSongs,
      orElse: () => <PlayLog>[],
    );

    emit(const HistoryState.loading());
    // Fetch all (no limit)
    final result = await _getPlaybackHistory(const GetPlaybackHistoryParams());

    result.fold(
      (failure) => emit(HistoryState.failure(failure.message)),
      (logs) => emit(HistoryState.loaded(recentSongs: currentRecent, allHistory: logs)),
    );
  }
}
