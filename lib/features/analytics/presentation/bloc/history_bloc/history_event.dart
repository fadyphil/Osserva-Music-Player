part of 'history_bloc.dart';

@freezed
class HistoryEvent with _$HistoryEvent {
  const factory HistoryEvent.fetchRecentHistory() = _FetchRecentHistory;
  const factory HistoryEvent.fetchAllHistory() = _FetchAllHistory;
}
