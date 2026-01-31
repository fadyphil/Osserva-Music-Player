import 'package:flutter/material.dart';
import 'package:music_player/core/theme/app_pallete.dart';

class LibraryStatsRow extends StatelessWidget {
  final int trackCount;
  final int artistCount;
  final int albumCount;

  const LibraryStatsRow({
    super.key,
    required this.trackCount,
    required this.artistCount,
    required this.albumCount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _StatCard(label: "Tracks", count: trackCount)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(label: "Artists", count: artistCount)),
          const SizedBox(width: 12),
          Expanded(child: _StatCard(label: "Albums", count: albumCount)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int count;

  const _StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppPallete.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              color: AppPallete.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppPallete.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
