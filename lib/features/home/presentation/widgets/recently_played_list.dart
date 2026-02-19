import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';
import 'package:on_audio_query/on_audio_query.dart';

class RecentlyPlayedList extends StatelessWidget {
  final List<PlayLog> songs;
  final Function(PlayLog) onPlay;
  final VoidCallback onSeeAll;

  const RecentlyPlayedList({
    super.key,
    required this.songs,
    required this.onPlay,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color: AppPallete.foreground,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Recently Played',
                    style: TextStyle(
                      color: AppPallete.foreground,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See all',
                  style: TextStyle(color: AppPallete.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: songs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 4),
          itemBuilder: (context, index) {
            final song = songs[index];
            return _RecentlyPlayedTile(song: song, onTap: () => onPlay(song));
          },
        ),
      ],
    );
  }
}

class _RecentlyPlayedTile extends StatelessWidget {
  final PlayLog song;
  final VoidCallback onTap;

  const _RecentlyPlayedTile({required this.song, required this.onTap});

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final min = duration.inMinutes;
    final sec = duration.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      hoverColor: AppPallete.surface,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppPallete.surface,
                borderRadius: BorderRadius.circular(6),
              ),
              child: QueryArtworkWidget(
                artworkBorder: BorderRadius.circular(4),
                id: song.songId,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: const Icon(
                  Icons.play_arrow,
                  color: AppPallete.grey,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.songTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPallete.foreground,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${song.artist} • ${song.album}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPallete.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatDuration(song.durationListenedSeconds),
              style: const TextStyle(color: AppPallete.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
