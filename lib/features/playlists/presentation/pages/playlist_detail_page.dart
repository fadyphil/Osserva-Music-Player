import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/core/di/init_dependencies.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';
import 'package:music_player/features/playlists/presentation/bloc/playlist_detail_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart';

@RoutePage()
class PlaylistDetailPage extends StatelessWidget {
  final PlaylistEntity playlist;

  const PlaylistDetailPage({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<PlaylistDetailBloc>()..add(PlaylistDetailEvent.loadPlaylistDetail(playlist)),
      child: Scaffold(
        backgroundColor: AppPallete.backgroundColor,
        body: BlocBuilder<PlaylistDetailBloc, PlaylistDetailState>(
          builder: (context, state) {
            return state.map(
              initial: (_) => const SizedBox.shrink(),
              loading: (_) => const Center(child: CircularProgressIndicator()),
              failure: (f) => Center(child: Text('Error: ${f.message}')),
              loaded: (data) {
                final currentPlaylist = data.playlist;
                final songs = data.songs;
                
                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      backgroundColor: AppPallete.backgroundColor,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(currentPlaylist.name),
                        background: currentPlaylist.imagePath != null
                            ? Image.network(
                                currentPlaylist.imagePath!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[900],
                                child: const Center(
                                  child: Icon(Icons.music_note, size: 80, color: Colors.white24),
                                ),
                              ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                             // TODO: Implement Edit Dialog
                             _showEditDialog(context, currentPlaylist);
                          },
                        ),
                      ],
                    ),
                    if (songs.isEmpty)
                      const SliverFillRemaining(
                        child: Center(
                          child: Text(
                            'No songs in this playlist.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return ListTile(
                              leading: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                nullArtworkWidget: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.music_note, color: Colors.white54),
                                ),
                              ),
                              title: Text(
                                song.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                                onPressed: () {
                                  context.read<PlaylistDetailBloc>().add(
                                    PlaylistDetailEvent.removeSong(song.id),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: songs.length,
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, PlaylistEntity playlist) {
    final nameCtrl = TextEditingController(text: playlist.name);
    final descCtrl = TextEditingController(text: playlist.description);
    final bloc = context.read<PlaylistDetailBloc>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text('Edit Playlist', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Description'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              bloc.add(PlaylistDetailEvent.editPlaylist(
                name: nameCtrl.text,
                description: descCtrl.text,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
