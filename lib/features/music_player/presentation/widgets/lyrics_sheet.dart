import 'package:flutter/material.dart';
import '../../../../core/theme/app_pallete.dart';
import '../../../../features/local music/domain/entities/song_entity.dart';

class LyricsSheet extends StatelessWidget {
  final SongEntity song;

  const LyricsSheet({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppPallete.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 46),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lyrics',
                        style: TextStyle(
                          color: AppPallete.white.withValues(alpha: .6),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        song.title,
                        style: const TextStyle(
                          color: AppPallete.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: AppPallete.surface,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppPallete.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: AppPallete.surface, height: 40),

          // Content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lyrics_outlined,
                    size: 64,
                    color: AppPallete.grey.withValues(alpha: .3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No lyrics available",
                    style: TextStyle(
                      color: AppPallete.grey.withValues(alpha: .8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "We couldn't find lyrics for this song.",
                    style: TextStyle(
                      color: AppPallete.grey.withValues(alpha: .5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
