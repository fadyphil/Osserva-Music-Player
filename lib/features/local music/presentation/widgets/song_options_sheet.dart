// features/local music/presentation/widgets/song_options_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_player/features/local%20music/domain/entities/song_entity.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_bloc.dart';
import 'package:music_player/features/music_player/presentation/bloc/music_player_event.dart';

void showSongOptions(BuildContext context, SongEntity song) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1E1E1E), // Dark theme color
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Song Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(color: Colors.white24),

            // Option 1: Play Next (Insert after current)
            ListTile(
              leading: const Icon(Icons.playlist_play, color: Colors.white),
              title: const Text(
                'Play Next',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.read<MusicPlayerBloc>().add(
                  MusicPlayerEvent.playNextinQueue(song),
                );
                Navigator.pop(context); // Close sheet
              },
            ),

            // Option 2: Add to Queue (Append to end)
            ListTile(
              leading: const Icon(Icons.queue_music, color: Colors.white),
              title: const Text(
                'Add to Queue',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                context.read<MusicPlayerBloc>().add(
                  MusicPlayerEvent.addToQueue(song),
                );
                Navigator.pop(context); // Close sheet
              },
            ),

            // Option 3: Add to Favorites (Existing logic if you have it)
            ListTile(
              leading: const Icon(Icons.favorite_border, color: Colors.white),
              title: const Text(
                'Add to Favorites',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Add your FavoritesBloc logic here
                Navigator.pop(context);
              },
            ),
            
            // Spacer for MiniPlayer/NavBar
            Builder(
              builder: (context) {
                final isPlaying =
                    context.select((MusicPlayerBloc bloc) => bloc.state.currentSong != null);
                if (isPlaying) {
                  return const SizedBox(height: 150);
                }
                return const SizedBox(height: 20);
              },
            ),
          ],
        ),
      );
    },
  );
}
