// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [AnalyticsDashboardPage]
class AnalyticsDashboardRoute extends PageRouteInfo<void> {
  const AnalyticsDashboardRoute({List<PageRouteInfo>? children})
    : super(AnalyticsDashboardRoute.name, initialChildren: children);

  static const String name = 'AnalyticsDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalyticsDashboardPage();
    },
  );
}

/// generated route for
/// [ArtistDetailPage]
class ArtistDetailRoute extends PageRouteInfo<ArtistDetailRouteArgs> {
  ArtistDetailRoute({
    Key? key,
    required int artistId,
    required String artistName,
    List<PageRouteInfo>? children,
  }) : super(
         ArtistDetailRoute.name,
         args: ArtistDetailRouteArgs(
           key: key,
           artistId: artistId,
           artistName: artistName,
         ),
         initialChildren: children,
       );

  static const String name = 'ArtistDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ArtistDetailRouteArgs>();
      return ArtistDetailPage(
        key: args.key,
        artistId: args.artistId,
        artistName: args.artistName,
      );
    },
  );
}

class ArtistDetailRouteArgs {
  const ArtistDetailRouteArgs({
    this.key,
    required this.artistId,
    required this.artistName,
  });

  final Key? key;

  final int artistId;

  final String artistName;

  @override
  String toString() {
    return 'ArtistDetailRouteArgs{key: $key, artistId: $artistId, artistName: $artistName}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ArtistDetailRouteArgs) return false;
    return key == other.key &&
        artistId == other.artistId &&
        artistName == other.artistName;
  }

  @override
  int get hashCode => key.hashCode ^ artistId.hashCode ^ artistName.hashCode;
}

/// generated route for
/// [ArtistsPage]
class ArtistsRoute extends PageRouteInfo<void> {
  const ArtistsRoute({List<PageRouteInfo>? children})
    : super(ArtistsRoute.name, initialChildren: children);

  static const String name = 'ArtistsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ArtistsPage();
    },
  );
}

/// generated route for
/// [ArtistsTabShellPage]
class ArtistsTabShellRoute extends PageRouteInfo<void> {
  const ArtistsTabShellRoute({List<PageRouteInfo>? children})
    : super(ArtistsTabShellRoute.name, initialChildren: children);

  static const String name = 'ArtistsTabShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ArtistsTabShellPage();
    },
  );
}

/// generated route for
/// [FavoritesPage]
class FavoritesRoute extends PageRouteInfo<void> {
  const FavoritesRoute({List<PageRouteInfo>? children})
    : super(FavoritesRoute.name, initialChildren: children);

  static const String name = 'FavoritesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const FavoritesPage();
    },
  );
}

/// generated route for
/// [HistoryPage]
class HistoryRoute extends PageRouteInfo<void> {
  const HistoryRoute({List<PageRouteInfo>? children})
    : super(HistoryRoute.name, initialChildren: children);

  static const String name = 'HistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HistoryPage();
    },
  );
}

/// generated route for
/// [HomeDashboardPage]
class HomeDashboardRoute extends PageRouteInfo<void> {
  const HomeDashboardRoute({List<PageRouteInfo>? children})
    : super(HomeDashboardRoute.name, initialChildren: children);

  static const String name = 'HomeDashboardRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeDashboardPage();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [HomeTabShellPage]
class HomeTabShellRoute extends PageRouteInfo<void> {
  const HomeTabShellRoute({List<PageRouteInfo>? children})
    : super(HomeTabShellRoute.name, initialChildren: children);

  static const String name = 'HomeTabShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeTabShellPage();
    },
  );
}

/// generated route for
/// [LibraryPage]
class LibraryRoute extends PageRouteInfo<void> {
  const LibraryRoute({List<PageRouteInfo>? children})
    : super(LibraryRoute.name, initialChildren: children);

  static const String name = 'LibraryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LibraryPage();
    },
  );
}

/// generated route for
/// [LibraryTabShellPage]
class LibraryTabShellRoute extends PageRouteInfo<void> {
  const LibraryTabShellRoute({List<PageRouteInfo>? children})
    : super(LibraryTabShellRoute.name, initialChildren: children);

  static const String name = 'LibraryTabShellRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LibraryTabShellPage();
    },
  );
}

/// generated route for
/// [OnboardingPage]
class OnboardingRoute extends PageRouteInfo<OnboardingRouteArgs> {
  OnboardingRoute({
    Key? key,
    VoidCallback? onDone,
    List<PageRouteInfo>? children,
  }) : super(
         OnboardingRoute.name,
         args: OnboardingRouteArgs(key: key, onDone: onDone),
         initialChildren: children,
       );

  static const String name = 'OnboardingRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OnboardingRouteArgs>(
        orElse: () => const OnboardingRouteArgs(),
      );
      return OnboardingPage(key: args.key, onDone: args.onDone);
    },
  );
}

class OnboardingRouteArgs {
  const OnboardingRouteArgs({this.key, this.onDone});

  final Key? key;

  final VoidCallback? onDone;

  @override
  String toString() {
    return 'OnboardingRouteArgs{key: $key, onDone: $onDone}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OnboardingRouteArgs) return false;
    return key == other.key && onDone == other.onDone;
  }

  @override
  int get hashCode => key.hashCode ^ onDone.hashCode;
}

/// generated route for
/// [PlaylistDetailPage]
class PlaylistDetailRoute extends PageRouteInfo<PlaylistDetailRouteArgs> {
  PlaylistDetailRoute({
    Key? key,
    required PlaylistEntity playlist,
    List<PageRouteInfo>? children,
  }) : super(
         PlaylistDetailRoute.name,
         args: PlaylistDetailRouteArgs(key: key, playlist: playlist),
         initialChildren: children,
       );

  static const String name = 'PlaylistDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PlaylistDetailRouteArgs>();
      return PlaylistDetailPage(key: args.key, playlist: args.playlist);
    },
  );
}

class PlaylistDetailRouteArgs {
  const PlaylistDetailRouteArgs({this.key, required this.playlist});

  final Key? key;

  final PlaylistEntity playlist;

  @override
  String toString() {
    return 'PlaylistDetailRouteArgs{key: $key, playlist: $playlist}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PlaylistDetailRouteArgs) return false;
    return key == other.key && playlist == other.playlist;
  }

  @override
  int get hashCode => key.hashCode ^ playlist.hashCode;
}

/// generated route for
/// [PlaylistListPage]
class PlaylistListRoute extends PageRouteInfo<void> {
  const PlaylistListRoute({List<PageRouteInfo>? children})
    : super(PlaylistListRoute.name, initialChildren: children);

  static const String name = 'PlaylistListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PlaylistListPage();
    },
  );
}

/// generated route for
/// [ProfilePage]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfilePage();
    },
  );
}

/// generated route for
/// [SongListPage]
class SongListRoute extends PageRouteInfo<void> {
  const SongListRoute({List<PageRouteInfo>? children})
    : super(SongListRoute.name, initialChildren: children);

  static const String name = 'SongListRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SongListPage();
    },
  );
}

/// generated route for
/// [SplashPage]
class SplashRoute extends PageRouteInfo<SplashRouteArgs> {
  SplashRoute({
    Key? key,
    required bool isFirstRun,
    List<PageRouteInfo>? children,
  }) : super(
         SplashRoute.name,
         args: SplashRouteArgs(key: key, isFirstRun: isFirstRun),
         initialChildren: children,
       );

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SplashRouteArgs>();
      return SplashPage(key: args.key, isFirstRun: args.isFirstRun);
    },
  );
}

class SplashRouteArgs {
  const SplashRouteArgs({this.key, required this.isFirstRun});

  final Key? key;

  final bool isFirstRun;

  @override
  String toString() {
    return 'SplashRouteArgs{key: $key, isFirstRun: $isFirstRun}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SplashRouteArgs) return false;
    return key == other.key && isFirstRun == other.isFirstRun;
  }

  @override
  int get hashCode => key.hashCode ^ isFirstRun.hashCode;
}

/// generated route for
/// [UserRegistrationPage]
class UserRegistrationRoute extends PageRouteInfo<UserRegistrationRouteArgs> {
  UserRegistrationRoute({
    Key? key,
    required VoidCallback onRegistrationComplete,
    List<PageRouteInfo>? children,
  }) : super(
         UserRegistrationRoute.name,
         args: UserRegistrationRouteArgs(
           key: key,
           onRegistrationComplete: onRegistrationComplete,
         ),
         initialChildren: children,
       );

  static const String name = 'UserRegistrationRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<UserRegistrationRouteArgs>();
      return UserRegistrationPage(
        key: args.key,
        onRegistrationComplete: args.onRegistrationComplete,
      );
    },
  );
}

class UserRegistrationRouteArgs {
  const UserRegistrationRouteArgs({
    this.key,
    required this.onRegistrationComplete,
  });

  final Key? key;

  final VoidCallback onRegistrationComplete;

  @override
  String toString() {
    return 'UserRegistrationRouteArgs{key: $key, onRegistrationComplete: $onRegistrationComplete}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UserRegistrationRouteArgs) return false;
    return key == other.key &&
        onRegistrationComplete == other.onRegistrationComplete;
  }

  @override
  int get hashCode => key.hashCode ^ onRegistrationComplete.hashCode;
}
