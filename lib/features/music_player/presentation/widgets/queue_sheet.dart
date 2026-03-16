import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osserva/core/theme/app_pallete.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_event.dart';
import 'package:osserva/features/music_player/presentation/bloc/music_player_state.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPallete.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                // Close button (Optional, but good UX)
                // GestureDetector(
                //   onTap: () => Navigator.pop(context),
                //   child: const Icon(Icons.close, color: AppPallete.grey),
                // ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
            buildWhen: (previous, current) =>
                previous.currentSong != current.currentSong,
            builder: (context, state) {
              if (state.currentSong != null) {
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 8,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Now Playing . ${state.currentSong!.title}",
                      style: const TextStyle(
                        color: AppPallete.accent,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const Divider(color: Colors.white12, height: 1),
          Expanded(
            child: BlocBuilder<MusicPlayerBloc, MusicPlayerState>(
              buildWhen: (previous, current) =>
                  previous.queue != current.queue ||
                  previous.currentSong != current.currentSong,
              builder: (context, state) {
                final queue = state.queue;
                final currentSong = state.currentSong;

                if (queue.isEmpty) {
                  return const Center(
                    child: Text(
                      'Queue is empty',
                      style: TextStyle(color: AppPallete.grey),
                    ),
                  );
                }

                return ReorderableListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: queue.length,
                  onReorder: (oldIndex, newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    context.read<MusicPlayerBloc>().add(
                      MusicPlayerEvent.reorderQueue(oldIndex, newIndex),
                    );
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppPallete.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: child,
                      ),
                    );
                  },
                  itemBuilder: (context, index) {
                    final song = queue[index];
                    // Compare by ID to find the playing song
                    final isPlaying =
                        currentSong != null && song.id == currentSong.id;

                    return Dismissible(
                      key: ValueKey(
                        song.uniqueId ?? '${song.id}_$index',
                      ), // Stable Key
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        context.read<MusicPlayerBloc>().add(
                          MusicPlayerEvent.removeFromQueue(index),
                        );
                      },
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            color: AppPallete.surface,
                          ),
                          child: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            keepOldArtwork: true,
                            artworkBorder: BorderRadius.zero,
                            artworkFit: BoxFit.cover,
                            nullArtworkWidget: const Icon(
                              Icons.music_note,
                              color: AppPallete.grey,
                            ),
                          ),
                        ),
                        title: Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isPlaying
                                ? AppPallete.accent
                                : AppPallete.white,
                            fontWeight: isPlaying
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppPallete.grey),
                        ),
                        trailing: ReorderableDragStartListener(
                          index: index,
                          child: isPlaying
                              ? const Icon(
                                  Icons.graphic_eq,
                                  color: AppPallete.accent,
                                )
                              : const Icon(
                                  Icons.drag_handle,
                                  color: AppPallete.grey,
                                ),
                        ),
                        onTap: () {
                          context.read<MusicPlayerBloc>().add(
                            MusicPlayerEvent.playQueueItem(index),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
