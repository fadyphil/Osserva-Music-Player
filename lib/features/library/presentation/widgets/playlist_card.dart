import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/playlists/domain/entities/playlist_entity.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistEntity playlist;
  final String activityLabel; // e.g., "Morning", "Afternoon"
  final String timeLabel; // e.g., "7m", "9m"

  const PlaylistCard({
    super.key,
    required this.playlist,
    this.activityLabel = "Activity", // Placeholder default
    this.timeLabel = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppPallete.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.router.push(PlaylistDetailRoute(playlist: playlist));
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artwork Placeholder
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppPallete.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: playlist.imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                playlist.imagePath!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(
                                  Icons.music_note,
                                  color: Colors.white54,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.music_note_outlined,
                              color: Colors.white54,
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            playlist.name,
                            style: const TextStyle(
                              color: AppPallete.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            playlist.description,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppPallete.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${playlist.totalSongs} tracks",
                            style: TextStyle(
                              color: AppPallete.white.withValues(alpha: 0.5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Activity Section (Visual Mock per Design)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Activity",
                      style: TextStyle(color: AppPallete.grey, fontSize: 12),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.wb_sunny_outlined, // Dynamic based on time?
                          size: 14,
                          color: AppPallete.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          activityLabel.isEmpty ? "Recent" : activityLabel,
                          style: const TextStyle(
                            color: AppPallete.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (timeLabel.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppPallete.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeLabel,
                            style: const TextStyle(
                              color: AppPallete.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bar Chart Placeholder (Visualizer)
                // Using a simple Row of Containers for performance instead of a heavy chart lib for this list item
                SizedBox(
                  height: 24,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(30, (index) {
                      // Generate a pseudo-random height or pattern
                      // In a real app, this would be bound to analytics data
                      final height = (index % 5 + 1) * 4.0;
                      final isActive = index > 10 && index < 20;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          height: isActive ? height + 6 : 4,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppPallete.primaryColor
                                : const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "12am",
                      style: TextStyle(color: Color(0xFF404040), fontSize: 10),
                    ),
                    const Text(
                      "12pm",
                      style: TextStyle(color: Color(0xFF404040), fontSize: 10),
                    ),
                    const Text(
                      "12am",
                      style: TextStyle(color: Color(0xFF404040), fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
