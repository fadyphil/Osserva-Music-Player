import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_bloc.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_event.dart';
import 'package:music_player/features/artists/presentation/bloc/artist-details/artist_detail_state.dart';
import 'package:music_player/features/local%20music/presentation/widgets/song_list_tile.dart';

@RoutePage()
class ArtistDetailPage extends StatelessWidget {
  final int artistId;
  final String artistName;

  const ArtistDetailPage({
    super.key,
    required this.artistId,
    required this.artistName,
  });

  Color _generateColor(String name) {
    final int hash = name.hashCode;
    final int r = (hash & 0xFF0000) >> 16;
    final int g = (hash & 0x00FF00) >> 8;
    final int b = (hash & 0x0000FF);
    return Color.fromARGB(255, r, g, b);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<ArtistDetailBloc>()
            ..add(ArtistDetailEvent.loadArtistSongs(artistId, artistName)),
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 300,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(artistName),
                background: Container(
                  color: _generateColor(artistName),
                  child: Center(
                    child: Icon(
                      Icons.music_note,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
            BlocBuilder<ArtistDetailBloc, ArtistDetailState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SliverFillRemaining(child: SizedBox()),
                  loading: () => const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (msg) => SliverFillRemaining(
                    child: Center(child: Text('Error: $msg')),
                  ),
                  loaded: (songs, analytics) {
                    final int totalSeconds =
                        analytics?['total_duration'] as int? ?? 0;
                    final int hours = totalSeconds ~/ 3600;
                    final int sessions = analytics?['sessions'] as int? ?? 0;
                    final String? dominantTime =
                        analytics?['dominant_time'] as String?;
                    final int songCount = songs.length;

                    String description = "Collection of listening memories";
                    if (hours > 0) {
                      description =
                          "Over $hours hours across $sessions sessions—a sustained relationship.";
                    } else if (sessions > 0) {
                      if (dominantTime != null) {
                        description =
                            "$sessions sessions, mostly in the $dominantTime—an evolving relationship.";
                      } else {
                        description =
                            "$sessions sessions with this voice—an evolving relationship.";
                      }
                    }

                    return SliverMainAxisGroup(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artistName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  description,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(color: Colors.grey[400]),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    _StatItem(
                                      label: "${hours}h",
                                      subLabel: "listening",
                                    ),
                                    const _Dot(),
                                    _StatItem(
                                      label: "$sessions",
                                      subLabel: "sessions",
                                    ),
                                    const _Dot(),
                                    _StatItem(
                                      label: "$songCount",
                                      subLabel: "songs",
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  "Songs",
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverFixedExtentList(
                          itemExtent: 72.0,
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return SongListTile(
                              song: songs[index],
                              index: index,
                              songList: songs,
                            );
                          }, childCount: songs.length),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String subLabel;

  const _StatItem({required this.label, required this.subLabel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(subLabel, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        shape: BoxShape.circle,
      ),
    );
  }
}
