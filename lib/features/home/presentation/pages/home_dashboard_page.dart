import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:music_player/features/analytics/presentation/bloc/history_bloc/history_bloc.dart';

@RoutePage()
class HomeDashboardPage extends StatelessWidget {
  const HomeDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<HistoryBloc>()..add(const HistoryEvent.fetchRecentHistory()),
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Library',
                    style: TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _HomeTile(
                      title: 'Local Music',
                      icon: Icons.library_music,
                      color: Colors.blueAccent,
                      onTap: () => context.router.push(const SongListRoute()),
                    ),
                    _HomeTile(
                      title: 'Liked Songs',
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                      onTap: () => context.router.push(const FavoritesRoute()),
                    ),
                    _HomeTile(
                      title: 'Playlists',
                      icon: Icons.playlist_play,
                      color: Colors.greenAccent,
                      onTap: () => context.router.push(const PlaylistListRoute()),
                    ),
                    _HomeTile(
                      title: 'Stats',
                      icon: Icons.bar_chart,
                      color: Colors.purpleAccent,
                      onTap: () => context.router.push(const AnalyticsDashboardRoute()),
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recently Played',
                        style: TextStyle(
                          fontSize: 22, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.router.push(const HistoryRoute()),
                        child: const Text('See More'),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: BlocBuilder<HistoryBloc, HistoryState>(
                  builder: (context, state) {
                    return state.maybeMap(
                      loaded: (data) {
                        if (data.recentSongs.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text("No songs played yet.", style: TextStyle(color: Colors.white54)),
                          );
                        }
                        return SizedBox(
                          height: 140,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: data.recentSongs.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final log = data.recentSongs[index];
                              return _HistoryCard(log: log);
                            },
                          ),
                        );
                      },
                      orElse: () => const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _HomeTile({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.2),
               blurRadius: 8,
               offset: const Offset(0, 4),
             )
          ]
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PlayLog log;

  const _HistoryCard({required this.log});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Icon(Icons.music_note, color: Colors.white24, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.songTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                Text(
                  log.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
