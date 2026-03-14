import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_aggregator.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_reader.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_recorder.dart';
import 'package:music_player/features/analytics/data/datasources/audio_analytics_tracker.dart';
import 'package:music_player/features/analytics/data/datasources/db/analytics_database.dart';
import 'package:music_player/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:music_player/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:music_player/features/analytics/domain/usecases/clear_analytics.dart';
import 'package:music_player/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:music_player/features/analytics/domain/usecases/get_general_stats.dart';
import 'package:music_player/features/analytics/domain/usecases/get_playback_history.dart';
import 'package:music_player/features/analytics/domain/usecases/get_top_items.dart';
import 'package:music_player/features/analytics/domain/usecases/log_playback.dart';
import 'package:music_player/features/analytics/domain/usecases/watch_playback_history.dart';
import 'package:music_player/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';

void registerAnalyticsDependencies(GetIt sl) {
  sl.registerLazySingleton(() => AnalyticsDatabase());
  sl.registerLazySingleton(() => AnalyticsRecorder(sl()));
  sl.registerLazySingleton(() => AnalyticsReader(sl()));
  sl.registerLazySingleton(() => AnalyticsAggregator(sl()));

  sl.registerLazySingleton<AnalyticsRepository>(() {
    final repo = AnalyticsRepositoryImpl(
      recorder: sl(),
      reader: sl(),
      aggregator: sl(),
    );
    repo.performMaintenance();
    return repo;
  });

  sl.registerLazySingleton(() => LogPlayback(sl()));
  sl.registerLazySingleton(() => GetAllSongPlayCounts(sl()));
  sl.registerLazySingleton(() => GetTopSongs(sl()));
  sl.registerLazySingleton(() => GetTopArtists(sl()));
  sl.registerLazySingleton(() => GetTopAlbums(sl()));
  sl.registerLazySingleton(() => GetTopGenres(sl()));
  sl.registerLazySingleton(() => GetGeneralStats(sl()));
  sl.registerLazySingleton(() => GetPlaybackHistory(sl()));
  sl.registerLazySingleton(() => WatchPlaybackHistory(sl()));
  sl.registerLazySingleton(() => ClearAnalytics(sl()));

  sl.registerLazySingleton(
    () => AudioAnalyticsTracker(sl<AudioPlayer>(), sl<LogPlayback>()),
  );

  sl.registerFactory(
    () => AnalyticsBloc(
      logPlayback: sl(),
      getTopSongs: sl(),
      getTopArtists: sl(),
      getTopAlbums: sl(),
      getTopGenres: sl(),
      getGeneralStats: sl(),
      watchPlaybackHistory: sl(),
    ),
  );

  sl.registerFactory(
    () => HistoryBloc(getPlaybackHistory: sl(), watchPlaybackHistory: sl()),
  );
}
