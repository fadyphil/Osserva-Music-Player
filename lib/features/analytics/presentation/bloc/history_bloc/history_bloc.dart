import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';
import 'package:osserva/features/analytics/domain/usecases/get_playback_history.dart';
import 'package:osserva/features/analytics/domain/usecases/watch_playback_history.dart';

part 'history_event.dart';
part 'history_state.dart';
part 'history_bloc.freezed.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetPlaybackHistory _getPlaybackHistory;
  final WatchPlaybackHistory _watchPlaybackHistory;
  StreamSubscription<void>? _historySubscription;

  HistoryBloc({
    required GetPlaybackHistory getPlaybackHistory,
    required WatchPlaybackHistory watchPlaybackHistory,
  }) : _getPlaybackHistory = getPlaybackHistory,
       _watchPlaybackHistory = watchPlaybackHistory,
       super(const HistoryState.initial()) {
    on<_FetchRecentHistory>(_onFetchRecentHistory);
    on<_FetchAllHistory>(_onFetchAllHistory);

    _historySubscription = _watchPlaybackHistory().listen((_) {
      add(const HistoryEvent.fetchRecentHistory());
    });
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchRecentHistory(
    _FetchRecentHistory event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! _Loaded) {
      emit(const HistoryState.loading());
    }
    final result = await _getPlaybackHistory(
      const GetPlaybackHistoryParams(limit: 10),
    );

    result.fold((failure) => emit(HistoryState.failure(failure.message)), (
      logs,
    ) {
      // Preserve existing allHistory if present
      final currentAll = state.maybeMap(
        loaded: (s) => s.allHistory,
        orElse: () => <PlayLog>[],
      );
      emit(HistoryState.loaded(recentSongs: logs, allHistory: currentAll));
    });
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

    if (state is! _Loaded) {
      emit(const HistoryState.loading());
    }
    // Fetch all (no limit)
    final result = await _getPlaybackHistory(const GetPlaybackHistoryParams());

    result.fold(
      (failure) => emit(HistoryState.failure(failure.message)),
      (logs) => emit(
        HistoryState.loaded(recentSongs: currentRecent, allHistory: logs),
      ),
    );
  }
}
