import 'dart:math' as math;
import 'package:flutter/material.dart';

// Simple data model to hold our mock activity data
class DailyActivity {
  final String date;
  final String day;
  final int plays;

  DailyActivity(this.date, this.day, this.plays);
}

class MockRecentActivityCard extends StatelessWidget {
  const MockRecentActivityCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on Image 2
    final List<DailyActivity> activityData = [
      DailyActivity('12', 'Mon', 45),
      DailyActivity('13', 'Tue', 32),
      DailyActivity('14', 'Wed', 58),
      DailyActivity('15', 'Thu', 41),
      DailyActivity('16', 'Fri', 65),
      DailyActivity('17', 'Sat', 82),
      DailyActivity('18', 'Sun', 74),
    ];

    // Find the maximum plays to calculate the 100% width of the bars
    final int maxPlays = activityData.map((e) => e.plays).reduce(math.max);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF16181D), // Dark card background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Recent Activity (Mock)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Activity List
          ...activityData.map((data) => _buildActivityRow(data, maxPlays)),
        ],
      ),
    );
  }

  Widget _buildActivityRow(DailyActivity data, int maxPlays) {
    // Prevent division by zero; if maxPlays is 0, percentage is 0.
    final double percentage = maxPlays > 0 ? (data.plays / maxPlays) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Date & Day column (Fixed width for alignment)
          SizedBox(
            width: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  data.day,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
                Text(
                  data.date,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Bar Graph Track
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background track
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                // Filled bar
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.orangeAccent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Play Count column (Fixed width for alignment)
          SizedBox(
            width: 55,
            child: Text(
              '${data.plays} plays',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
