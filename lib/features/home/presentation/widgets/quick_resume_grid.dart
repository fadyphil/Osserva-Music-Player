import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QuickResumeGrid extends StatelessWidget {
  final List<PlayLog> songs;
  final Function(PlayLog) onPlay;

  const QuickResumeGrid({super.key, required this.songs, required this.onPlay});

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
              Icon(
                Icons.play_arrow_outlined,
                color: AppPallete.foreground,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Quick Resume',
                style: TextStyle(
                  color: AppPallete.foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.8,
          ),
          itemCount: displaySongs.length,
          itemBuilder: (context, index) {
            final song = displaySongs[index];
            return _QuickResumeCard(song: song, onTap: () => onPlay(song));
          },
        ),
      ],
    );
  }
}

class _QuickResumeCard extends StatelessWidget {
  final PlayLog song;
  final VoidCallback onTap;

  const _QuickResumeCard({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppPallete.surface, // bg-secondary
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppPallete.border),
        ),
        child: Row(
          children: [
            QueryArtworkWidget(
              artworkBorder: BorderRadius.circular(4),
              artworkFit: BoxFit.cover,
              artworkWidth: 32,
              artworkHeight: 32,
              id: song.songId,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppPallete.background, // bg-muted
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: AppPallete.grey,
                  size: 16,
                ),
              ),
            ),
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
                      color: AppPallete.foreground,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPallete.grey, // text-muted-foreground
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
