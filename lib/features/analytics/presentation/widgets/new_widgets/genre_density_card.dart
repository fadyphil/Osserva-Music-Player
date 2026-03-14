import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:music_player/features/analytics/domain/entities/analytics_stats.dart';

class GenreDensityCard extends StatelessWidget {
  final List<TopItem> topGenres;

  const GenreDensityCard({super.key, required this.topGenres});

  static const _colors = [
    Color(0xFF1976D2),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFD4A017),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    final genres = topGenres.take(5).toList();

    if (genres.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2128),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(child: Text('No genre data yet', style: TextStyle(
          color: Colors.white.withValues(alpha: 0.4), fontSize: 14,
        ))),
      );
    }

    final total = genres.fold(0, (sum, g) => sum + g.count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Genre Density', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
          )),
          const SizedBox(height: 4),
          Text('Visual representation of genre dominance', style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5), fontSize: 12,
          )),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 200,
              height: 180,
              child: CustomPaint(
                painter: _BubblePainter(genres: genres, total: total, colors: _colors),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: genres.asMap().entries.map((entry) {
              final i = entry.key;
              final genre = entry.value;
              final pct = total > 0 ? (genre.count / total * 100) : 0.0;
              final color = _colors[i % _colors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 12),
                    Text(genre.title, style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500,
                    )),
                    const Spacer(),
                    Text('${genre.count} plays', style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45), fontSize: 12,
                    )),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${pct.toStringAsFixed(0)}%',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 12, fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  final List<TopItem> genres;
  final int total;
  final List<Color> colors;

  const _BubblePainter({required this.genres, required this.total, required this.colors});

  // Pre-computed offsets (relative to center) for up to 5 bubbles
  static const _offsets = [
    Offset(22, -8),
    Offset(5, 34),
    Offset(-38, 6),
    Offset(-22, -32),
    Offset(14, -44),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || genres.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    const maxRadius = 62.0;
    final maxCount = genres.first.count.toDouble();

    final paint = Paint()..style = PaintingStyle.fill;

    // Draw from largest to smallest so smaller bubbles appear on top
    for (int i = genres.length - 1; i >= 0; i--) {
      final genre = genres[i];
      // Scale radius by sqrt of ratio for visual balance
      final ratio = genre.count / maxCount;
      final radius = maxRadius * math.sqrt(ratio);
      final offset = i < _offsets.length ? _offsets[i] : Offset.zero;

      paint.color = colors[i % colors.length].withValues(alpha: 0.75);
      canvas.drawCircle(center + offset, radius, paint);
    }

    // Center dot accent
    paint.color = colors[0];
    canvas.drawCircle(center, 3, paint);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter old) => old.total != total;
}
