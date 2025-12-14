import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_bloc.dart';

@RoutePage()
class PlaylistListPage extends StatelessWidget {
  const PlaylistListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlaylistBloc>()..add(const PlaylistEvent.loadPlaylists()),
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: AppPallete.backgroundColor,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text('Playlists'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _showCreatePlaylistDialog(context),
                ),
              ],
            ),
            body: BlocBuilder<PlaylistBloc, PlaylistState>(
              builder: (context, state) {
                return state.map(
                  initial: (_) => const SizedBox.shrink(),
                  loading: (_) => const Center(child: CircularProgressIndicator()),
                  failure: (f) => Center(child: Text('Error: ${f.message}')),
                  loaded: (data) {
                    if (data.playlists.isEmpty) {
                      return const Center(
                        child: Text(
                          'No playlists yet.\nTap + to create one.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: data.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = data.playlists[index];
                        return ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(8),
                              image: playlist.imagePath != null
                                  ? DecorationImage(
                                      image: NetworkImage(playlist.imagePath!), // Assuming URL or File
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: playlist.imagePath == null
                                ? const Icon(Icons.music_note, color: Colors.white54)
                                : null,
                          ),
                          title: Text(playlist.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            '${playlist.totalSongs} songs',
                            style: const TextStyle(color: Colors.white54),
                          ),
                          onTap: () {
                            context.router.push(PlaylistDetailRoute(playlist: playlist));
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          );
        }
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    // Use a Builder to get the context with BlocProvider
    // But showDialog creates a new context branch. 
    // We need to access the Bloc from the parent context.
    // However, the dialog context won't have the bloc provider if it's strictly below Scaffold.
    // We should capture the bloc instance before showing dialog.
    // Wait, `PlaylistListPage` creates the provider. 
    // But `showDialog` is pushed to the root navigator usually.
    // So we need to pass the bloc or use `serviceLocator` (bad for state sync, but we are using BlocProvider).
    // Better: Capture bloc context.
    
    // Actually, `PlaylistBloc` is created in `build`.
    // We can't easily access it inside `showDialog` unless we pass it.
    // Or we rely on `serviceLocator` if we registered it as Singleton (we registered Factory).
    // So we MUST pass the bloc or wrap the dialog in BlocProvider.value.
    
    // But wait, the context passed to `_showCreatePlaylistDialog` is from `build` (inside BlocProvider if we moved the method inside).
    // But `showCreatePlaylistDialog` is outside `build`.
    // The `context` passed to the method HAS the bloc.
    // But `showDialog` builds a new tree. 
    
    // Solution:
    final bloc = context.read<PlaylistBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
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
              ),
            ),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
