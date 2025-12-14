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
/// [MusicPlayerPage]
class MusicPlayerRoute extends PageRouteInfo<void> {
  const MusicPlayerRoute({List<PageRouteInfo>? children})
    : super(MusicPlayerRoute.name, initialChildren: children);

  static const String name = 'MusicPlayerRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const MusicPlayerPage();
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
