import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_player/features/favorites/presentation/pages/favorites_page.dart';
import 'package:music_player/features/home/presentation/pages/home_page.dart';
import 'package:music_player/features/local%20music/presentation/pages/song_list_page.dart';
import 'package:music_player/features/music_player/presentation/pages/music_player_page.dart';
import 'package:music_player/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:music_player/features/onboarding/presentation/pages/user_registration_page.dart';
import 'package:music_player/features/playlists/presentation/pages/playlist_detail_page.dart';
import 'package:music_player/features/playlists/presentation/pages/playlist_list_page.dart';
import 'package:music_player/features/profile/presentation/pages/profile_page.dart';
import 'package:music_player/features/splash/presentation/pages/splash_page.dart';

// You will need to import your page widgets here.
// Since I don't know your exact package name, I'm assuming relative imports or you will auto-import them.// Note: "local music" folder has a space, double check folder name
import '../../features/analytics/presentation/pages/analytics_dashboard_page.dart';
import 'package:music_player/core/router/guards/onboarding_guard.dart'; // Import the guard
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart'; // Import Entity

part 'app_router.gr.dart'; // This file will be generated

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    // 1. Splash
    AutoRoute(page: SplashRoute.page, initial: true),

    // 2. Onboarding Flow
    AutoRoute(page: OnboardingRoute.page),
    AutoRoute(page: UserRegistrationRoute.page),

    // 3. Main Dashboard (Shell Route)
    // HomePage will contain the BottomNavBar and an AutoTabsRouter
    AutoRoute(
      page: HomeRoute.page,
      guards: [OnboardingGuard()], // Add the guard here
      children: [
        AutoRoute(page: SongListRoute.page),
        AutoRoute(page: AnalyticsDashboardRoute.page),
        AutoRoute(page: ProfileRoute.page),
      ],
    ),

    AutoRoute(page: MusicPlayerRoute.page),

    // Playlists
    AutoRoute(page: PlaylistListRoute.page),
    AutoRoute(page: PlaylistDetailRoute.page),

    // Favorites
    AutoRoute(page: FavoritesRoute.page),
  ];
}
