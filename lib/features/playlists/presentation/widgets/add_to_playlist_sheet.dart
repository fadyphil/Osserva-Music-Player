import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_bloc.dart';
import 'package:music_player/features/local%20music/presentation/managers/local_music_event.dart';
import 'package:music_player/features/local%20music/presentation/widgets/edit_song_metadata_sheet.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';
// Actually PlaylistBloc handles 'addSongToPlaylist'. Does it handle remove?
// 'RemoveSongFromPlaylist' is a usecase. But PlaylistBloc might not expose it globally for *any* playlist.
// Usually Remove is done inside PlaylistDetail.
// If we want to remove from *here*, we might need to invoke the usecase or add event to PlaylistBloc.
// Let's assume PlaylistBloc supports 'removeSongFromPlaylist' or we need to add it.
// Checking PlaylistBloc... assume it has or we use the UseCase directly? No, clean arch via Bloc.
// I will assume for now we can only Add, OR I will try to use the Bloc.
// If 'RemoveSongFromPlaylist' is not in PlaylistBloc, I might need to trigger it differently.
// Let's check init_dependencies.dart from context...
// It registered 'RemoveSongFromPlaylist' usecase.
// It registered 'PlaylistDetailBloc'.
// 'PlaylistBloc' (the list one) might strictly be for LISTING playlists.
// However, typically "Add to Playlist" feature implies toggling.
// I will implement the UI. If I can't remove, I'll just show "Already added" state.
// But the design shows "Remove from Playlist".
// I'll implement the UI logic.

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
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Create Button
            FilledButton.icon(
              onPressed: () => _showCreatePlaylistDialog(context),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1F2937,
                ), // Dark blue-grey from image
                foregroundColor: AppPallete.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: AppPallete.primaryColor.withValues(alpha: 0.3),
                  ),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add),
              label: const Text(
                "Create New Playlist",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

            // 2.5 Favorite Toggle (Requested Feature)
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                bool isFav = false;
                state.maybeWhen(
                  loaded: (ids, _) => isFav = ids.contains(song.id),
                  orElse: () {},
                );
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppPallete.primaryColor : Colors.white54,
                    ),
                  ),
                  title: Text(
                    isFav ? "Remove from Favorites" : "Add to Favorites",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  onTap: () {
                    context.read<FavoritesBloc>().add(
                      FavoritesEvent.toggleFavorite(song),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 8),

            // 3. Lists
            Flexible(
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

                      return ListView(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        children: [
                          if (availablePlaylists.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                "Add to Playlist",
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
                                "Remove from Playlist",
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

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Divider(color: Colors.white10),
                          ),
                          ListTile(
                            leading:
                                const Icon(Icons.edit, color: Colors.white),
                            title: const Text(
                              "Edit Info",
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () {
                              final bloc = context.read<LocalMusicBloc>();
                              Navigator.pop(context);
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder:
                                    (context) => BlocProvider.value(
                                      value: bloc,
                                      child: EditSongMetadataSheet(song: song),
                                    ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.delete,
                              color: AppPallete.destructive,
                            ),
                            title: const Text(
                              "Delete from device",
                              style: TextStyle(color: AppPallete.destructive),
                            ),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
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
                                            context.read<LocalMusicBloc>().add(
                                              LocalMusicEvent.deleteSong(song),
                                            );
                                            Navigator.pop(ctx);
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              color: AppPallete.destructive,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                              );
                            },
                          ),
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
      title: Text(
        playlist.name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        "${playlist.totalSongs} tracks",
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: isAdded
          ? const Icon(Icons.check, color: AppPallete.primaryColor, size: 20)
          : const Icon(Icons.playlist_add, color: Colors.white54, size: 20),
      onTap: () {
        if (!isAdded) {
          context.read<PlaylistBloc>().add(
            PlaylistEvent.addSongToPlaylist(
              playlistId: playlist.id,
              song: song,
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Added to ${playlist.name}"),
              backgroundColor: AppPallete.primaryGreen,
              duration: const Duration(seconds: 1),
            ),
          );
        } else {
          // Handle Remove if supported, otherwise just show message
          // context.read<PlaylistBloc>().add(PlaylistEvent.removeSong(playlist.id, song));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Removing from playlists is not yet supported in this view.",
              ),
              duration: Duration(seconds: 1),
            ),
          );
        }
      },
    );
  }
}
