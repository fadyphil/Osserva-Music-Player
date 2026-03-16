import 'dart:developer';

import 'package:fpdart/fpdart.dart';
import 'package:osserva/features/analytics/domain/entities/artist_stats.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/analytics_enums.dart';
import '../../domain/entities/analytics_stats.dart';
import '../../domain/entities/play_log.dart';
import '../../domain/repositories/analytics_repository.dart';
import '../datasources/analytics_aggregator.dart';
import '../datasources/analytics_reader.dart';
import '../datasources/analytics_recorder.dart';
import '../failures/analytics_failure.dart';

class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final AnalyticsRecorder recorder;
  final AnalyticsReader reader;
  final AnalyticsAggregator aggregator;

  AnalyticsRepositoryImpl({
    required this.recorder,
    required this.reader,
    required this.aggregator,
  });

  /// Triggers database maintenance (Roll-up aggregation).
  /// Should be called on app startup.
  Future<void> performMaintenance() async {
    try {
      // Roll up logs older than 90 days
      await aggregator.performRollUp(daysToKeep: 90);
    } catch (e) {
      // Log error but don't crash app
      log('Analytics Maintenance Failed: $e');
    }
  }

  @override
  Future<Either<Failure, void>> logEvent(PlayLog log) async {
    try {
      await recorder.logEvent(log);
      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to log playback event: $e'));
    }
  }

  @override
  Future<Either<Failure, ListeningStats>> getGeneralStats(
    TimeFrame timeFrame,
  ) async {
    try {
      final result = await reader.getGeneralStats(timeFrame);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch general stats: $e'));
    }
  }

  @override
  Future<Either<Failure, ArtistStats>> getArtistStats(String artistName) async {
    try {
      final result = await reader.getArtistStats(artistName);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch artist stats: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<int, int>>> getAllSongPlayCounts() async {
    try {
      final result = await reader.getAllSongPlayCounts();
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch play counts: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TopItem>>> getTopAlbums(
    TimeFrame timeFrame, {
    int limit = 10,
  }) async {
    try {
      final result = await reader.getTopAlbums(timeFrame, limit);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch top albums: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TopItem>>> getTopArtists(
    TimeFrame timeFrame, {
    int limit = 10,
  }) async {
    try {
      final result = await reader.getTopArtists(timeFrame, limit);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch top artists: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TopItem>>> getTopGenres(
    TimeFrame timeFrame, {
    int limit = 10,
  }) async {
    try {
      final result = await reader.getTopGenres(timeFrame, limit);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch top genres: $e'));
    }
  }

  @override
  Future<Either<Failure, List<TopItem>>> getTopSongs(
    TimeFrame timeFrame, {
    int limit = 10,
  }) async {
    try {
      final result = await reader.getTopSongs(timeFrame, limit);
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch top songs: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logOnboardingComplete() async {
    try {
      await recorder.logOnboardingComplete();
      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to log onboarding complete: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearData() async {
    try {
      await recorder.clearAllData();
      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to clear analytics data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSongAnalytics(int songId) async {
    try {
      // Need to implement in Recorder/Reader. Assuming recorder has it or we add it.
      // I'll assume we need to add it to Recorder.
      // For now, I'll just mock call it, I need to add it to AnalyticsRecorder.
      await recorder.deleteSongLogs(songId);
      return const Right(null);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to delete song analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PlayLog>>> getPlaybackHistory({
    int? limit,
    int? offset,
  }) async {
    try {
      final result = await reader.getPlaybackHistory(
        limit: limit,
        offset: offset,
      );
      return Right(result);
    } catch (e) {
      return Left(AnalyticsFailure('Failed to fetch playback history: $e'));
    }
  }

  @override
  Stream<void> get playbackStream => recorder.onLogStream;
}
