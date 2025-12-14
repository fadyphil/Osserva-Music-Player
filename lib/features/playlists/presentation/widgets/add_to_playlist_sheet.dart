import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';

class AddToPlaylistSheet extends StatelessWidget {
  final SongEntity song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlaylistBloc>()..add(const PlaylistEvent.loadPlaylists()),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppPallete.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add to Playlist",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, state) {
                  return state.map(
                    initial: (_) => const Center(child: CircularProgressIndicator()),
                    loading: (_) => const Center(child: CircularProgressIndicator()),
                    failure: (f) => Text("Error: ${f.message}", style: const TextStyle(color: Colors.redAccent)),
                    loaded: (data) {
                      if (data.playlists.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No playlists created yet.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: data.playlists.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white10),
                        itemBuilder: (context, index) {
                          final playlist = data.playlists[index];
                          return ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.grey[900],
                                borderRadius: BorderRadius.circular(8),
                                image: playlist.imagePath != null
                                    ? DecorationImage(
                                        image: NetworkImage(playlist.imagePath!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: playlist.imagePath == null
                                  ? const Icon(Icons.music_note, color: Colors.white24)
                                  : null,
                            ),
                            title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text("${playlist.totalSongs} songs", style: const TextStyle(color: Colors.white54)),
                            onTap: () {
                              context.read<PlaylistBloc>().add(
                                PlaylistEvent.addSongToPlaylist(
                                  playlistId: playlist.id,
                                  song: song,
                                ),
                              );
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Added to ${playlist.name}"),
                                  backgroundColor: AppPallete.primaryGreen,
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // "Create New" button
            ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              title: const Text("Create New Playlist", style: TextStyle(color: Colors.white)),
              onTap: () {
                // We could handle creation here or navigate.
                // For simplicity, just pop and tell user to go to playlists.
                Navigator.pop(context);
                // Ideally open Create Dialog.
              },
            ),
          ],
        ),
      ),
    );
  }
}
