import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_aggregator.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_reader.dart';
import 'package:music_player/features/analytics/data/datasources/analytics_recorder.dart';
import 'package:music_player/features/analytics/data/datasources/db/analytics_database.dart';
import 'package:music_player/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:music_player/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:music_player/features/analytics/domain/usecases/get_general_stats.dart';
import 'package:music_player/features/analytics/domain/usecases/get_playback_history.dart';
import 'package:music_player/features/analytics/domain/usecases/get_top_items.dart';
import 'package:music_player/features/analytics/domain/usecases/watch_playback_history.dart';
import 'package:music_player/features/analytics/domain/usecases/get_all_song_play_counts.dart';
import 'package:music_player/features/analytics/domain/usecases/log_playback.dart';
import 'package:music_player/features/analytics/domain/usecases/clear_analytics.dart';
import 'package:music_player/features/analytics/domain/services/music_analytics_service.dart';
import 'package:music_player/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:music_player/features/background-notification-feature/data/datasources/audio_handler.dart';
import 'package:music_player/features/local%20music/data/datasource/local_music_datasource.dart';
import 'package:music_player/features/local%20music/data/repositories/music_repository_impl.dart';
import 'package:music_player/features/local%20music/domain/repositories/music_repository.dart';
import 'package:music_player/features/local%20music/domain/use%20cases/get_local_songs_use_case.dart';
import 'package:music_player/features/local%20music/domain/use%20cases/get_song_by_id_use_case.dart';
import 'package:music_player/features/local%20music/domain/usecases/delete_song.dart';
import 'package:music_player/features/local%20music/domain/usecases/edit_song_metadata.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/music_player/data/repos/audio_player_repository_impl.dart';
import 'package:music_player/features/music_player/domain/repos/audio_player_repository.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/onboarding/data/datasources/onboarding_local_data_source.dart';
import 'package:music_player/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:music_player/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:music_player/features/onboarding/domain/usecases/cache_first_timer.dart';
import 'package:music_player/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:music_player/features/onboarding/domain/usecases/log_onboarding_complete.dart';
import 'package:music_player/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:music_player/features/onboarding/presentation/cubit/user_registration_cubit.dart';
import 'package:music_player/features/home/presentation/bloc/home_bloc/home_bloc.dart';
import 'package:music_player/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:music_player/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:music_player/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_player/features/profile/domain/usecases/get_achievements.dart';
import 'package:music_player/features/profile/domain/usecases/get_user_profile.dart';
import 'package:music_player/features/profile/domain/usecases/update_user_profile.dart';
import 'package:music_player/features/profile/domain/usecases/clear_cache.dart';
import 'package:music_player/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:music_player/features/favorites/data/datasources/favorites_local_datasource.dart';
import 'package:music_player/features/favorites/data/repositories/favorites_repository_impl.dart';
import 'package:music_player/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:music_player/features/favorites/domain/usecases/add_favorite.dart';
import 'package:music_player/features/favorites/domain/usecases/get_favorite_songs.dart';
import 'package:music_player/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/playlists/data/datasources/playlist_local_datasource.dart';
import 'package:music_player/features/playlists/data/repositories/playlist_repository_impl.dart';
import 'package:music_player/features/playlists/domain/repositories/playlist_repository.dart';
import 'package:music_player/features/playlists/domain/usecases/add_song_to_playlist.dart';
import 'package:music_player/features/playlists/domain/usecases/create_playlist.dart';
import 'package:music_player/features/playlists/domain/usecases/delete_playlist.dart';
import 'package:music_player/features/playlists/domain/usecases/edit_playlist.dart';
import 'package:music_player/features/playlists/domain/usecases/get_playlist_songs.dart';
import 'package:music_player/features/playlists/domain/usecases/get_playlists.dart';
import 'package:music_player/features/playlists/domain/usecases/remove_song_from_playlist.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_detail_bloc.dart';
import 'package:music_player/features/artists/data/datasources/artist_local_datasource.dart';
import 'package:music_player/features/artists/data/repositories/artist_repository_impl.dart';
import 'package:music_player/features/artists/domain/repositories/artist_repository.dart';
import 'package:music_player/features/artists/domain/usecases/get_artists.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_songs.dart';
import 'package:music_player/features/artists/domain/usecases/get_artist_analytics_stats.dart';
import 'package:music_player/features/artists/presentation/bloc/artists/artists_bloc.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Create the global instance
final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await serviceLocator.reset();
  // =========================================================
  // 1. External (Third Party Libraries)
  // =========================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  final appRouter = AppRouter();
  final mediaStore = MediaStore();
  serviceLocator.registerLazySingleton(() => mediaStore);

  serviceLocator.registerLazySingleton(() => sharedPreferences);

  serviceLocator.registerLazySingleton(() => OnAudioQuery());
  serviceLocator.registerLazySingleton(() => AudioPlayer());
  final audioHandler = await AudioService.init(
    builder: () => MusicPlayerHandler(player: serviceLocator()),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.music_player.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: false,
    ),
  );

  serviceLocator.registerSingleton<AudioHandler>(audioHandler);
  serviceLocator.registerSingleton<AppRouter>(appRouter);

  // =========================================================
  // 2. Data Layer
  // =========================================================

  // Data Source: We inject OnAudioQuery into it
  serviceLocator.registerLazySingleton<LocalMusicDatasource>(
    () => LocalMusicDatasourceImpl(serviceLocator(), serviceLocator()),
  );

  // Repository: We inject the DataSource into it
  serviceLocator.registerLazySingleton<MusicRepository>(
    () => MusicRepositoryImpl(serviceLocator()),
  );

  // =========================================================
  // 3. Domain Layer
  // =========================================================

  // Use Case: We inject the Repository into it
  serviceLocator.registerLazySingleton(
    () => GetLocalSongsUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetSongByIdUseCase(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => DeleteSong(serviceLocator(), serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => EditSongMetadata(serviceLocator()),
  );

  // =========================================================
  // 4. Presentation Layer (Bloc)
  // =========================================================
  serviceLocator.registerFactory(
    () => LocalMusicBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: MUSIC PLAYER
  // =========================================================
  // 2. Repository
  serviceLocator.registerLazySingleton<AudioPlayerRepository>(
    () => AudioPlayerRepositoryImpl(serviceLocator<AudioHandler>()),
  );

  serviceLocator.registerLazySingleton(
    () => MusicPlayerBloc(
      serviceLocator(),
      serviceLocator(),
      serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: ANALYTICS
  // =========================================================
  serviceLocator.registerLazySingleton(() => AnalyticsDatabase());

  serviceLocator.registerLazySingleton(
    () => AnalyticsRecorder(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => AnalyticsReader(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => AnalyticsAggregator(serviceLocator()),
  );

  serviceLocator.registerLazySingleton<AnalyticsRepository>(() {
    final repo = AnalyticsRepositoryImpl(
      recorder: serviceLocator(),
      reader: serviceLocator(),
      aggregator: serviceLocator(),
    );
    repo.performMaintenance();
    return repo;
  });

  serviceLocator.registerLazySingleton(() => LogPlayback(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => GetAllSongPlayCounts(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => GetTopSongs(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetTopArtists(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetTopAlbums(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetTopGenres(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetGeneralStats(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => GetPlaybackHistory(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => WatchPlaybackHistory(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => ClearAnalytics(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => MusicAnalyticsService(serviceLocator(), serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => AnalyticsBloc(
      logPlayback: serviceLocator(),
      getTopSongs: serviceLocator(),
      getTopArtists: serviceLocator(),
      getTopAlbums: serviceLocator(),
      getTopGenres: serviceLocator(),
      getGeneralStats: serviceLocator(),
      watchPlaybackHistory: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => HistoryBloc(
      getPlaybackHistory: serviceLocator(),
      watchPlaybackHistory: serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: ONBOARDING
  // =========================================================
  serviceLocator.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => CacheFirstTimer(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => CheckIfUserIsFirstTimer(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => LogOnboardingComplete(serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => OnboardingCubit(cacheFirstTimer: serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => UserRegistrationCubit(
      updateUserProfile: serviceLocator(),
      logOnboardingComplete: serviceLocator(),
      cacheFirstTimer: serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: HOME
  // =========================================================
  serviceLocator.registerFactory(
    () => HomeBloc(musicRepository: serviceLocator()),
  );

  // =========================================================
  // FEATURE: PROFILE
  // =========================================================
  serviceLocator.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => GetUserProfile(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => UpdateUserProfile(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => ClearCache(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetAchievements(serviceLocator()));

  serviceLocator.registerFactory(
    () => ProfileBloc(
      getUserProfile: serviceLocator(),
      updateUserProfile: serviceLocator(),
      clearCache: serviceLocator(),
      getAchievements: serviceLocator(),
      clearAnalytics: serviceLocator(),
      getGeneralStats: serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: PLAYLISTS
  // =========================================================
  serviceLocator.registerLazySingleton<PlaylistLocalDataSource>(
    () => PlaylistLocalDataSourceImpl(),
  );

  serviceLocator.registerLazySingleton<PlaylistRepository>(
    () => PlaylistRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => CreatePlaylist(serviceLocator()));
  serviceLocator.registerLazySingleton(() => DeletePlaylist(serviceLocator()));
  serviceLocator.registerLazySingleton(() => EditPlaylist(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetPlaylists(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => AddSongToPlaylist(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => RemoveSongFromPlaylist(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => GetPlaylistSongs(
      playlistRepository: serviceLocator(),
      musicRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => PlaylistBloc(
      getPlaylists: serviceLocator(),
      createPlaylist: serviceLocator(),
      deletePlaylist: serviceLocator(),
      addSongToPlaylist: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => PlaylistDetailBloc(
      getPlaylistSongs: serviceLocator(),
      addSongToPlaylist: serviceLocator(),
      removeSongFromPlaylist: serviceLocator(),
      editPlaylist: serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: FAVORITES
  // =========================================================
  serviceLocator.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(),
  );

  serviceLocator.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(serviceLocator()),
  );

  serviceLocator.registerLazySingleton(() => AddFavorite(serviceLocator()));
  serviceLocator.registerLazySingleton(() => RemoveFavorite(serviceLocator()));

  serviceLocator.registerLazySingleton(
    () => GetFavoriteSongs(
      favoritesRepository: serviceLocator(),
      musicRepository: serviceLocator(),
    ),
  );

  serviceLocator.registerFactory(
    () => FavoritesBloc(
      getFavoriteSongs: serviceLocator(),
      addFavorite: serviceLocator(),
      removeFavorite: serviceLocator(),
    ),
  );

  // =========================================================
  // FEATURE: ARTISTS
  // =========================================================
  serviceLocator.registerLazySingleton<ArtistLocalDataSource>(
    () => ArtistLocalDataSourceImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton<ArtistRepository>(
    () => ArtistRepositoryImpl(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(() => GetArtists(serviceLocator()));
  serviceLocator.registerLazySingleton(() => GetArtistSongs(serviceLocator()));
  serviceLocator.registerLazySingleton(
    () => GetArtistAnalyticsStats(serviceLocator()),
  );

  serviceLocator.registerFactory(
    () => ArtistsBloc(serviceLocator(), serviceLocator()),
  );
  serviceLocator.registerFactory(
    () => ArtistDetailBloc(serviceLocator(), serviceLocator()),
  );
}
