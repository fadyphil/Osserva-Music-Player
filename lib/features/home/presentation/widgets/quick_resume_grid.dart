import 'package:flutter/material.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';

class QuickResumeGrid extends StatelessWidget {
  final List<PlayLog> songs;
  final Function(PlayLog) onPlay;

  const QuickResumeGrid({
    super.key,
    required this.songs,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure we display up to 4 items
    final displaySongs = songs.take(4).toList();

    if (displaySongs.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.play_arrow_outlined, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Quick Resume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: displaySongs.length,
          itemBuilder: (context, index) {
            final song = displaySongs[index];
            return _QuickResumeCard(
              song: song,
              onTap: () => onPlay(song),
            );
          },
        ),
      ],
    );
  }
}

class _QuickResumeCard extends StatelessWidget {
  final PlayLog song;
  final VoidCallback onTap;

  const _QuickResumeCard({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark card background
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.play_arrow_outlined, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.songTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
