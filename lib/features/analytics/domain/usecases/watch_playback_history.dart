import '../repositories/analytics_repository.dart';

class WatchPlaybackHistory {
  final AnalyticsRepository repository;

  WatchPlaybackHistory(this.repository);

  Stream<void> call() {
    return repository.playbackStream;
  }
}
