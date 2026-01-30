import 'package:flutter/material.dart';
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
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recently Played',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: const Text(
                  'See all',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
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
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final song = songs[index];
            return _RecentlyPlayedTile(
              song: song,
              onTap: () => onPlay(song),
            );
          },
        ),
      ],
    );
  }
}

class _RecentlyPlayedTile extends StatelessWidget {
  final PlayLog song;
  final VoidCallback onTap;

  const _RecentlyPlayedTile({
    required this.song,
    required this.onTap,
  });

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final min = duration.inMinutes;
    final sec = duration.inSeconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Hit test
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: QueryArtworkWidget(
                id: song.songId,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: const Icon(
                  Icons.play_arrow_outlined,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 4),
                  Text(
                    '${song.artist} • ${song.album}',
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
            Text(
              _formatDuration(song.durationListenedSeconds), // Assuming this is duration of song, but PlayLog has 'durationListened'.
              // Ideally PlayLog should have total duration of song too, but let's use what we have or placeholder
               // If playlog doesn't have total duration, we might need to fetch it or just not show it.
               // For now using durationListened as a placeholder or 0:00
               style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
