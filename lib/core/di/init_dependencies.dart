import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:just_audio/just_audio.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:osserva/core/di/modules/analytics_module.dart';
import 'package:osserva/core/di/modules/artists_module.dart';
import 'package:osserva/core/di/modules/favorites_module.dart';
import 'package:osserva/core/di/modules/local_music_module.dart';
import 'package:osserva/core/di/modules/music_player_module.dart';
import 'package:osserva/core/di/modules/onboarding_module.dart';
import 'package:osserva/core/di/modules/playlists_module.dart';
import 'package:osserva/core/di/modules/profile_module.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/features/analytics/data/datasources/audio_analytics_tracker.dart';
import 'package:osserva/features/background_notification/data/datasources/audio_handler.dart';
import 'package:osserva/features/home/presentation/bloc/home_bloc/home_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:shared_preferences/shared_preferences.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  // =========================================================
  // 1. External / Infrastructure
  // =========================================================
  final sharedPreferences = await SharedPreferences.getInstance();
  final audioPlayer = AudioPlayer();

  serviceLocator.registerLazySingleton(() => MediaStore());
  serviceLocator.registerLazySingleton(() => sharedPreferences);
  serviceLocator.registerLazySingleton(() => OnAudioQuery());
  serviceLocator.registerSingleton<AudioPlayer>(audioPlayer);
  serviceLocator.registerSingleton<AppRouter>(AppRouter());

  final audioHandler = await AudioService.init(
    builder: () => MusicPlayerHandler(player: audioPlayer),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.osserva.app.channel.audio',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: false,
    ),
  );
  serviceLocator.registerSingleton<AudioHandler>(audioHandler);

  // =========================================================
  // 2. Features
  // =========================================================
  registerLocalMusicDependencies(serviceLocator);
  registerMusicPlayerDependencies(serviceLocator);
  registerAnalyticsDependencies(serviceLocator);
  registerOnboardingDependencies(serviceLocator);
  registerProfileDependencies(serviceLocator);
  registerPlaylistsDependencies(serviceLocator);
  registerFavoritesDependencies(serviceLocator);
  registerArtistsDependencies(serviceLocator);

  // Home has no repository — registered inline, no module needed
  serviceLocator.registerFactory(
    () => HomeBloc(musicRepository: serviceLocator()),
  );

  // =========================================================
  // 3. Post-registration init
  // =========================================================
  serviceLocator<AudioAnalyticsTracker>().init();
}
