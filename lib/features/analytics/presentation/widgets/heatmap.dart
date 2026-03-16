import 'package:flutter/material.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';

class HeatmapCard extends StatelessWidget {
  final List<PlayLog> logs;

  const HeatmapCard({super.key, required this.logs});

  Map<String, int> _buildDateMap() {
    final map = <String, int>{};
    for (final log in logs) {
      final t = log.timestamp;
      final key =
          '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  /// Returns a 28-week (196 day) list of (dateKey, count) from oldest to newest,
  /// aligned so each column of 7 is Mon→Sun.
  List<int> _buildGrid(Map<String, int> dateMap) {
    final today = DateTime.now();
    // Step back to the most recent Sunday (start of the last full week shown)
    // We want 28 full columns (weeks), leftmost = oldest, rightmost = most recent
    // Start aligned so today's column ends at position [27][today.weekday % 7]
    const totalDays = 28 * 7; // 196
    // final end = today;
    // align so the last row in the last column is today (weekday 7=Sun, 1=Mon)
    // GridView with crossAxisCount=7 fills top-to-bottom per column
    // We want Mon at top, Sun at bottom → row index = weekday - 1 (1=Mon→0)
    // Start from totalDays - 1 days ago, but adjust so col 0 row 0 is a Monday
    final daysBack =
        totalDays - 1 + (today.weekday - 1); // how far the grid start is
    final gridStart = today.subtract(Duration(days: daysBack));

    return List.generate(totalDays, (i) {
      final date = gridStart.add(Duration(days: i));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return dateMap[key] ?? 0;
    });
  }

  int _toIntensity(int count, int max) {
    if (count == 0 || max == 0) return 0;
    final ratio = count / max;
    if (ratio < 0.25) return 1;
    if (ratio < 0.5) return 2;
    if (ratio < 0.75) return 3;
    return 4;
  }

  Color _cellColor(int intensity) {
    switch (intensity) {
      case 1:
        return const Color(0xFF0D47A1).withValues(alpha: 0.45);
      case 2:
        return const Color(0xFF1565C0).withValues(alpha: 0.7);
      case 3:
        return const Color(0xFF1976D2);
      case 4:
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFF1E2128);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateMap = _buildDateMap();
    final maxCount = dateMap.values.isEmpty
        ? 1
        : dateMap.values.reduce((a, b) => a > b ? a : b);
    final rawGrid = _buildGrid(dateMap);
    final intensityGrid = rawGrid
        .map((c) => _toIntensity(c, maxCount))
        .toList();

    final totalActiveDays = dateMap.values.where((v) => v > 0).length;
    final totalPlays = dateMap.values.fold(0, (a, b) => a + b);

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
              const Icon(Icons.grid_on_rounded, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Listening Heatmap',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalActiveDays active days · $totalPlays total plays in the last 28 weeks',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 116,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1.0,
              ),
              itemCount: intensityGrid.length,
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  color: _cellColor(intensityGrid[index]),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Less',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 6),
              for (int i = 0; i <= 4; i++) ...[
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: _cellColor(i),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              Text(
                'More',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
