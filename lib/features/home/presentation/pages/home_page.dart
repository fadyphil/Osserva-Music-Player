import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/router/app_router.dart';
import 'package:osserva/features/music_player/presentation/widgets/mini_player.dart';
import 'package:osserva/features/profile/domain/entities/user_entity.dart';
import 'package:osserva/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:osserva/features/home/domain/entities/home_tab.dart'; // Need HomeTab enum

// Import your widgets
import '../widgets/prism_knob_navigation.dart';
import '../widgets/neural_string_navigation.dart';
import '../widgets/pulse_bottom_nav_bar.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      // 1. Define the routes that map to your tabs
      routes: const [
        HomeTabShellRoute(),
        LibraryTabShellRoute(),
        ArtistsTabShellRoute(),
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
          extendBody: false, // Content goes behind the nav/miniplayer
          body: Stack(
            children: [
              // LAYER 1: The Active Page (Replaces IndexedStack)
              child,
            ],
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Mini Player sits on top of the Nav Bar
              const MiniPlayer(),

              // Navigation Deck
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  // Determine User's Preferred Style
                  NavBarStyle style = NavBarStyle.simple;
                  profileState.maybeWhen(
                    loaded: (user, achievements, stats) {
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
                      navBar = PulseBottomNavBar(
                        selectedTab: currentTab,
                        onTabSelected: (tab) {
                          tabsRouter.setActiveIndex(tab.index);
                        },
                      );
                  }

                  return navBar;
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
