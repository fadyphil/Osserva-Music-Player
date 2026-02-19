import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:music_player/features/home/presentation/bloc/home_bloc/home_bloc.dart';
import 'package:music_player/features/home/presentation/widgets/home_header.dart';
import 'package:music_player/features/home/presentation/widgets/quick_resume_grid.dart';
import 'package:music_player/features/home/presentation/widgets/recently_played_list.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';

@RoutePage()
class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => serviceLocator<HomeBloc>()..add(const HomeEvent.loadHomeData()),
        ),
        BlocProvider(
          create: (_) => serviceLocator<HistoryBloc>()..add(const HistoryEvent.fetchRecentHistory()),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 1. Header Section (Greeting + Stats)
              SliverToBoxAdapter(
                child: BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loaded: (data) => HomeHeader(
                        greeting: data.greeting,
                        trackCount: data.trackCount,
                      ),
                      orElse: () => const HomeHeader(greeting: 'Loading...', trackCount: 0),
                    );
                  },
                ),
              ),

              // 2. Quick Resume & Recently Played
              SliverToBoxAdapter(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loaded: (data) {
                        final history = data.recentSongs;
                        // Use first 4 for Quick Resume
                        final quickResume = history.take(4).toList();
                        // Use the rest (or all) for list, excluding duplicates if desired,
                        // but for now let's show items from index 0 or same list.
                        // Design implies a list below. Let's show up to 10 recent items.
                        final recentList = history.take(10).toList();

                        return Column(
                          children: [
                            if (quickResume.isNotEmpty)
                              QuickResumeGrid(
                                songs: quickResume,
                                onPlay: (song) {
                                  context.read<MusicPlayerBloc>().add(
                                    MusicPlayerEvent.playSongById(songId: song.songId),
                                  );
                                },
                              ),
                             if (recentList.isNotEmpty)
                               RecentlyPlayedList(
                                 songs: recentList,
                                 onPlay: (song) {
                                   context.read<MusicPlayerBloc>().add(
                                     MusicPlayerEvent.playSongById(songId: song.songId),
                                   );
                                 },
                                 onSeeAll: () {
                                    context.router.push(const HistoryRoute());
                                 },
                               ),
                          ],
                        );
                      },
                      loading: (_) => const Center(child: CircularProgressIndicator()),
                      orElse: () => const SizedBox.shrink(),
                    );
                  },
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

