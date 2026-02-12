import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_theme.dart';
import 'package:music_player/core/usecases/usecase.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/features/analytics/domain/services/music_analytics_service.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:music_player/features/onboarding/domain/usecases/check_if_user_is_first_timer.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart'; // Import this

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = "AudioGraphy";
  }

  JustAudioMediaKit.ensureInitialized();
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initDependencies();
  serviceLocator<MusicAnalyticsService>().init();

  final isFirstRunResult = await serviceLocator<CheckIfUserIsFirstTimer>()(
    NoParams(),
  );
  final isFirstRun = isFirstRunResult.fold(
    (l) => true, // Default to true on error
    (r) => r,
  );

  runApp(MyApp(isFirstRun: isFirstRun));
}

class MyApp extends StatefulWidget {
  final bool isFirstRun;
  const MyApp({super.key, required this.isFirstRun});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<MusicPlayerBloc>()),
        BlocProvider(
          create: (_) =>
              serviceLocator<ProfileBloc>()
                ..add(const ProfileEvent.loadProfile()),
        ),
        BlocProvider(
          create: (_) =>
              serviceLocator<FavoritesBloc>()
                ..add(const FavoritesEvent.loadFavorites()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'AudioGraphy',
        theme: AppTheme.darkThemeMode,
        routerConfig: serviceLocator<AppRouter>().config(
          deepLinkBuilder: (platformDeepLink) {
            if (platformDeepLink.path == '/') {
              return DeepLink([SplashRoute(isFirstRun: widget.isFirstRun)]);
            }
            return platformDeepLink;
          },
        ),
      ),
    );
  }
}
