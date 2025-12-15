import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/features/music_player/presentation/widgets/mini_player.dart';
import 'package:music_player/features/profile/domain/entities/user_entity.dart';
import 'package:music_player/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:music_player/features/home/presentation/cubit/home_state.dart'; // Need HomeTab enum

// Import your widgets
import '../widgets/prism_knob_navigation.dart';
import '../widgets/neural_string_navigation.dart';
import '../widgets/simple_animated_nav_bar.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      // 1. Define the routes that map to your tabs
      routes: const [
        HomeDashboardRoute(),
        AnalyticsDashboardRoute(),
        ProfileRoute(),
      ],
      // 2. Optional: Animation between tabs
      transitionBuilder: (context, child, animation) =>
          FadeTransition(opacity: animation, child: child),
      builder: (context, child) {
        // 3. Get the controller
        final tabsRouter = AutoTabsRouter.of(context);

        return Scaffold(
          extendBody: true, // Content goes behind the nav/miniplayer
          body: Stack(
            children: [
              // LAYER 1: The Active Page (Replaces IndexedStack)
              child,

              // LAYER 2: Gradient Fade
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 160,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                          Colors.black,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // LAYER 3: Mini Player
              const Positioned(
                left: 0,
                right: 0,
                bottom: 80, // Sits on top of the NavBar
                child: MiniPlayer(),
              ),

              // LAYER 4: Navigation Deck
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, profileState) {
                    // Determine User's Preferred Style
                    NavBarStyle style = NavBarStyle.simple;
                    profileState.maybeWhen(
                      loaded: (user) {
                        style = user.preferredNavBar;
                      },
                      orElse: () {},
                    );

                    // Convert Router Index (int) to Your Enum (HomeTab)
                    final currentTab = HomeTab.values[tabsRouter.activeIndex];

                    Widget navBar;
                    switch (style) {
                      case NavBarStyle.prism:
                        navBar = PrismKnobNavigation(
                          selectedTab: currentTab,
                          onTabSelected: (tab) {
                            // Convert Enum back to int for Router
                            tabsRouter.setActiveIndex(tab.index);
                          },
                        );
                        break;
                      case NavBarStyle.neural:
                        navBar = NeuralStringNavigation(
                          selectedTab: currentTab,
                          onTabSelected: (tab) {
                            tabsRouter.setActiveIndex(tab.index);
                          },
                        );
                        break;
                      case NavBarStyle.simple:
                      default:
                        navBar = SimpleAnimatedNavBar(
                          selectedTab: currentTab,
                          onTabSelected: (tab) {
                            tabsRouter.setActiveIndex(tab.index);
                          },
                        );
                    }

                    return navBar;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
