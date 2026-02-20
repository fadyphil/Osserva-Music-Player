import 'dart:math' as math;
import 'package:flutter/material.dart';

class MockHeatmapCard extends StatelessWidget {
  const MockHeatmapCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Generate deterministic pseudo-random data to match the UI's varied heatmap look
    // 0 = no activity, 4 = max activity
    final math.Random random = math.Random(42);
    final List<int> heatmapData = List.generate(14 * 16, (index) {
      // Create some "gaps" to simulate the spacing seen in Image 4
      if (index > 100 && index < 120) return 0;
      // Bias towards lower numbers to make the bright blue pop out more
      int value = random.nextInt(10);
      if (value > 4) value = (value / 3).floor();
      return value.clamp(0, 4);
    });

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
          // Header
          Row(
            children: [
              const Icon(Icons.grid_on_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Listening Heatmap (Mock)',
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
            'Most active period: Weekday afternoons (2-6 PM). Consistent engagement with occasional breaks during holidays.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // The Grid
          GridView.builder(
            shrinkWrap: true,
            physics:
                const NeverScrollableScrollPhysics(), // Disable scrolling inside the card
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 14, // Number of columns wide
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: heatmapData.length,
            itemBuilder: (context, index) {
              final intensity = heatmapData[index];
              return Container(
                decoration: BoxDecoration(
                  color: _getHeatmapColor(intensity),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Legend Footer (Less -> More)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
              Row(
                children: [
                  _buildLegendBox(const Color(0xFF1E2128)),
                  const SizedBox(width: 2),
                  _buildLegendBox(const Color(0xFF0D47A1).withOpacity(0.4)),
                  const SizedBox(width: 2),
                  _buildLegendBox(const Color(0xFF1565C0).withOpacity(0.7)),
                  const SizedBox(width: 2),
                  _buildLegendBox(const Color(0xFF1976D2)),
                  const SizedBox(width: 2),
                  _buildLegendBox(const Color(0xFF42A5F5)),
                ],
              ),
              Text(
                'More',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // Helper method to map intensity levels (0-4) to colors matching the screenshot
  Color _getHeatmapColor(int intensity) {
    switch (intensity) {
      case 1:
        return const Color(0xFF0D47A1).withOpacity(0.4); // Faint Blue
      case 2:
        return const Color(0xFF1565C0).withOpacity(0.7); // Medium Blue
      case 3:
        return const Color(0xFF1976D2); // Bright Blue
      case 4:
        return const Color(0xFF42A5F5); // Brightest Blue/Highlight
      case 0:
      default:
        return const Color(0xFF1E2128); // Dark Grey (Empty)
    }
  }
}
