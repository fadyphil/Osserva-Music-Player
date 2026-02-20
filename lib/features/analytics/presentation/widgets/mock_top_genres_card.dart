import 'package:flutter/material.dart';

class MockTopGenresCard extends StatelessWidget {
  const MockTopGenresCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Total plays used to calculate percentages
    const int totalPlays = 1040;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16181D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                'Top Genres (Mock)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Electronic and Ambient dominate (62% combined). Suggests preference for background/focus music during extended listening.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Data Rows
          _buildGenreRow(
            "Electronic",
            342,
            "19h 0m",
            const Color(0xFF1976D2),
            totalPlays,
          ),
          _buildGenreRow(
            "Ambient",
            298,
            "19h 52m",
            const Color(0xFF9C27B0),
            totalPlays,
          ),
          _buildGenreRow(
            "Indie",
            187,
            "12h 28m",
            const Color(0xFF4CAF50),
            totalPlays,
          ),
          _buildGenreRow(
            "Jazz",
            124,
            "10h 20m",
            const Color(0xFFFFB300),
            totalPlays,
          ),
          _buildGenreRow(
            "Classical",
            89,
            "7h 25m",
            const Color(0xFFE53935),
            totalPlays,
          ),
        ],
      ),
    );
  }

  Widget _buildGenreRow(
    String title,
    int plays,
    String time,
    Color color,
    int totalPlays,
  ) {
    final percentage = plays / totalPlays;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        children: [
          // Text Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$plays plays ($time)',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress Bar
          Stack(
            children: [
              // Background track
              Container(
                height: 6,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              // Colored filled track
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.4),
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
  }
}
