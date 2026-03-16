import 'package:flutter/material.dart';
import 'package:osserva/features/analytics/domain/entities/analytics_stats.dart';

class TopGenresCard extends StatelessWidget {
  final List<TopItem> genres;

  const TopGenresCard({super.key, required this.genres});

  static const _colors = [
    Color(0xFF1976D2),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFFFB300),
    Color(0xFFE53935),
  ];

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16181D),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Center(
          child: Text(
            'No genre data yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    final topGenres = genres.take(5).toList();
    final totalPlays = topGenres.fold(0, (sum, g) => sum + g.count);

    // Build a short insight string
    String insight = '';
    if (topGenres.length >= 2) {
      final top2Pct =
          ((topGenres[0].count + topGenres[1].count) / totalPlays * 100)
              .toStringAsFixed(0);
      insight =
          '${topGenres[0].title} & ${topGenres[1].title} dominate ($top2Pct% combined).';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16181D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bar_chart_rounded,
                color: Colors.purpleAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Top Genres',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (insight.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              insight,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 24),
          ...topGenres.asMap().entries.map((entry) {
            final i = entry.key;
            final genre = entry.value;
            final pct = totalPlays > 0 ? genre.count / totalPlays : 0.0;
            final color = _colors[i % _colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        genre.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${(pct * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${genre.count} plays',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
