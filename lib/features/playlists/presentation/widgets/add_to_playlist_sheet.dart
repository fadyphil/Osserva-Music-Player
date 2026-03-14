import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local_music/domain/entities/song_entity.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local_music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local_music/presentation/widgets/edit_song_metadata_sheet.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';

// --- SHEET 1: Song Actions Menu ---
class SongActionsSheet extends StatelessWidget {
  final SongEntity song;

  const SongActionsSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    // We need to capture the BLoCs because showModalBottomSheet might lose context if not careful
    final localMusicBloc = context.read<LocalMusicBloc>();
    final favoritesBloc = context.read<FavoritesBloc>();
    final musicPlayerBloc = context.read<MusicPlayerBloc>();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppPallete.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Song Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10),

          // 1. Play Next
          _ActionTile(
            icon: Icons.playlist_play_rounded,
            label: "Play Next",
            onTap: () {
              musicPlayerBloc.add(MusicPlayerEvent.playNextinQueue(song));
              Navigator.pop(context);
            },
          ),

          // 2. Add to Queue
          _ActionTile(
            icon: Icons.queue_music_rounded,
            label: "Add to Queue",
            onTap: () {
              musicPlayerBloc.add(MusicPlayerEvent.addToQueue(song));
              Navigator.pop(context);
            },
          ),

          // 3. Add to Playlist (The Refactored Trigger)
          _ActionTile(
            icon: Icons.playlist_add_rounded,
            label: "Add to Playlist",
            onTap: () {
              Navigator.pop(context); // Close actions sheet
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: localMusicBloc),
                    BlocProvider.value(value: favoritesBloc),
                  ],
                  child: AddToPlaylistSheet(song: song),
                ),
              );
            },
          ),

          // 4. Favorites Toggle
          BlocBuilder<FavoritesBloc, FavoritesState>(
            bloc: favoritesBloc,
            builder: (context, state) {
              bool isFav = false;
              state.maybeWhen(
                loaded: (ids, _) => isFav = ids.contains(song.id),
                orElse: () {},
              );
              return _ActionTile(
                icon: isFav ? Icons.favorite : Icons.favorite_border,
                iconColor: isFav ? AppPallete.primaryColor : Colors.white,
                label: isFav ? "Remove from Favorites" : "Add to Favorites",
                onTap: () {
                  favoritesBloc.add(FavoritesEvent.toggleFavorite(song));
                  Navigator.pop(context);
                },
              );
            },
          ),

          const Divider(color: Colors.white10),

          // 5. Edit Info
          _ActionTile(
            icon: Icons.edit_rounded,
            label: "Edit Song Info",
            onTap: () {
              Navigator.pop(context);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => BlocProvider.value(
                  value: localMusicBloc,
                  child: EditSongMetadataSheet(song: song),
                ),
              );
            },
          ),

          // 6. Delete
          _ActionTile(
            icon: Icons.delete_outline_rounded,
            label: "Delete from Device",
            iconColor: AppPallete.destructive,
            textColor: AppPallete.destructive,
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, localMusicBloc, song);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    LocalMusicBloc bloc,
    SongEntity song,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppPallete.cardColor,
        title: const Text(
          "Delete Song?",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "This will permanently delete the file from your device.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              bloc.add(LocalMusicEvent.deleteSong(song));
              Navigator.pop(ctx);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: AppPallete.destructive),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? Colors.white),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}

// --- SHEET 2: Add to Playlist (Selection Only) ---
class AddToPlaylistSheet extends StatelessWidget {
  final SongEntity song;

  const AddToPlaylistSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          serviceLocator<PlaylistBloc>()
            ..add(const PlaylistEvent.loadPlaylists()),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: const BoxDecoration(
          color: AppPallete.backgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Add to Playlist",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Create Button
            FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                foregroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppPallete.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                "Create New Playlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Lists
            Expanded(
              child: BlocBuilder<PlaylistBloc, PlaylistState>(
                builder: (context, state) {
                  return state.map(
                    initial: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    loading: (_) =>
                        const Center(child: CircularProgressIndicator()),
                    failure: (f) => Center(child: Text("Error: ${f.message}")),
                    loaded: (data) {
                      final allPlaylists = data.playlists;

                      // Split playlists
                      final addedPlaylists = allPlaylists
                          .where((p) => p.songIds.contains(song.id))
                          .toList();
                      final availablePlaylists = allPlaylists
                          .where((p) => !p.songIds.contains(song.id))
                          .toList();

                      if (allPlaylists.isEmpty) {
                        return const Center(
                          child: Text(
                            "No playlists found.",
                            style: TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      return ListView(
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (availablePlaylists.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                "Select Playlist",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            ...availablePlaylists.map(
                              (playlist) => _PlaylistTile(
                                playlist: playlist,
                                song: song,
                                isAdded: false,
                              ),
                            ),
                          ],

                          if (addedPlaylists.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Already In",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            ...addedPlaylists.map(
                              (playlist) => _PlaylistTile(
                                playlist: playlist,
                                song: song,
                                isAdded: true,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final bloc = context.read<PlaylistBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'New Playlist',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppPallete.primaryColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                bloc.add(
                  PlaylistEvent.createPlaylist(
                    name: nameCtrl.text,
                    description: '',
                  ),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text(
              'Create',
              style: TextStyle(
                color: AppPallete.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final PlaylistEntity playlist;
  final SongEntity song;
  final bool isAdded;

  const _PlaylistTile({
    required this.playlist,
    required this.song,
    required this.isAdded,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.playlist_play_rounded, color: Colors.white24),
      ),
      title: Text(
        playlist.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "${playlist.totalSongs} tracks",
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isAdded
          ? const Icon(Icons.check_circle, color: AppPallete.primaryColor)
          : const Icon(Icons.add_circle_outline, color: Colors.white24),
      onTap: () {
        if (!isAdded) {
          context.read<PlaylistBloc>().add(
            PlaylistEvent.addSongToPlaylist(
              playlistId: playlist.id,
              song: song,
            ),
          );
        } else {
          // You could add "Remove from Playlist" logic here if needed
        }
      },
    );
  }
}
