import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:music_player/features/library/presentation/widgets/playlist_card.dart';

class LibraryPlaylistsSlivers extends StatelessWidget {
  const LibraryPlaylistsSlivers({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlaylistBloc>()
        ..add(const PlaylistEvent.loadPlaylists()),
      child: BlocBuilder<PlaylistBloc, PlaylistState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => const SliverToBoxAdapter(child: SizedBox.shrink()),
            loading: (_) => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            failure: (f) => SliverFillRemaining(
              child: Center(child: Text('Error: ${f.message}')),
            ),
            loaded: (data) {
              if (data.playlists.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyPlaylistsState(
                    onCreate: () => _showCreatePlaylistDialog(context),
                  ),
                );
              }

              return SliverMainAxisGroup(
                slivers: [
                  // Add Button Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: GestureDetector(
                        onTap: () => _showCreatePlaylistDialog(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                              color: AppPallete.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppPallete.primaryColor
                                      .withValues(alpha: 0.3),
                                  width: 1,
                                  style: BorderStyle.solid)),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_circle_outline,
                                  color: AppPallete.primaryColor),
                              SizedBox(width: 8),
                              Text(
                                "Create New Playlist",
                                style: TextStyle(
                                  color: AppPallete.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // List
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final playlist = data.playlists[index];
                          final isEven = index % 2 == 0;
                          return PlaylistCard(
                            playlist: playlist,
                            activityLabel: isEven ? "Morning" : "Afternoon",
                            timeLabel: isEven ? "7m" : "9m",
                          );
                        },
                        childCount: data.playlists.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final bloc = context.read<PlaylistBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('New Playlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppPallete.primaryColor)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                labelStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppPallete.primaryColor)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                bloc.add(PlaylistEvent.createPlaylist(
                  name: nameCtrl.text,
                  description: descCtrl.text,
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create',
                style: TextStyle(
                    color: AppPallete.primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaylistsState extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyPlaylistsState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppPallete.cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.queue_music, size: 48, color: Colors.white24),
          ),
          const SizedBox(height: 24),
          const Text(
            "No Playlists Yet",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Create your first playlist to get started.",
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: AppPallete.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text("Create Playlist"),
          )
        ],
      ),
    );
  }
}
