part of 'history_bloc.dart';

@freezed
class HistoryState with _$HistoryState {
  const factory HistoryState.initial() = _Initial;
  const factory HistoryState.loading() = _Loading;
  const factory HistoryState.loaded({
    @Default([]) List<PlayLog> recentSongs,
    @Default([]) List<PlayLog> allHistory,
  }) = _Loaded;
  const factory HistoryState.failure(String message) = _Failure;
}
