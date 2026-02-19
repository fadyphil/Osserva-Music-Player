import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_player/core/router/app_router.dart';
import 'package:music_player/core/theme/app_pallete.dart';
import 'package:music_player/features/artists/domain/entities/artist_entity.dart';
import 'package:on_audio_query/on_audio_query.dart';

class ArtistCard extends StatelessWidget {
  final ArtistEntity artist;

  const ArtistCard({super.key, required this.artist});
  @override
  Widget build(BuildContext context) {
    final analytics = artist.analytics;
    final int? topSongId = analytics?['top_song_id'] as int?;
    final int totalSeconds = analytics?['total_duration'] as int? ?? 0;
    final int hours = totalSeconds ~/ 3600;
    final int sessions = analytics?['sessions'] as int? ?? 0;
    final String? dominantTime = analytics?['dominant_time'] as String?;

    String description = "Collection of listening memories";
    if (hours > 0) {
      description =
          "Over $hours hours across $sessions sessions—a sustained, evolving relationship.";
    } else if (sessions > 0) {
      if (dominantTime != null) {
        description =
            "$sessions sessions, mostly in the $dominantTime—steady engagement with this voice.";
      } else {
        description = "$sessions sessions with this voice—steady engagement.";
      }
    }

    return InkWell(
      onTap: () {
        context.router.push(
          ArtistDetailRoute(artistId: artist.id, artistName: artist.name),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Block
            RepaintBoundary(
              child: AspectRatio(
                aspectRatio: 1.2, // Slightly taller than square or square
                child: Container(
                  width: double.infinity,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: AppPallete.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: QueryArtworkWidget(
                    id: topSongId ?? artist.id,
                    size: 800,
                    quality: 100,
                    type: topSongId != null
                        ? ArtworkType.AUDIO
                        : ArtworkType.ARTIST,
                    artworkFit: BoxFit.cover,
                    nullArtworkWidget: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          size: 64,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                    ),
                    keepOldArtwork: true,
                    artworkBorder: BorderRadius.zero,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Artist Name
            Text(
              artist.name,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Poetic Description
            Text(
              description,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
