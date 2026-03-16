import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:osserva/features/analytics/domain/entities/play_log.dart';

class TemporalDistributionChart extends StatelessWidget {
  final List<PlayLog> logs;

  const TemporalDistributionChart({super.key, required this.logs});

  /// Group logs into daily play counts for the last 14 days.
  /// Returns a list of 14 integers (index 0 = 14 days ago, 13 = today).
  List<int> _buildDailyCounts() {
    final today = DateTime.now();
    final today0 = DateTime(today.year, today.month, today.day);

    final Map<int, int> dayIndexMap = {};
    for (final log in logs) {
      final logDay = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      final daysAgo = today0.difference(logDay).inDays;
      if (daysAgo >= 0 && daysAgo < 14) {
        final index = 13 - daysAgo; // 0 = oldest, 13 = today
        dayIndexMap[index] = (dayIndexMap[index] ?? 0) + 1;
      }
    }

    return List.generate(14, (i) => dayIndexMap[i] ?? 0);
  }

  List<String> _buildDayLabels() {
    final today = DateTime.now();
    const dayLetters = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return List.generate(14, (i) {
      final date = today.subtract(Duration(days: 13 - i));
      return dayLetters[date.weekday - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    final counts = _buildDailyCounts();
    final labels = _buildDayLabels();
    final maxCount = counts.reduce((a, b) => a > b ? a : b);
    final totalPlays = counts.fold(0, (a, b) => a + b);

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
          Row(
            children: [
              const Text(
                'Listening Trend',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$totalPlays plays',
                  style: const TextStyle(
                    color: Color(0xFF64B5F6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Daily play count — last 14 days',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: maxCount == 0
                ? Center(
                    child: Text(
                      'No plays in the last 14 days',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 13,
                      ),
                    ),
                  )
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.white.withValues(alpha: 0.04),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 20,
                            interval: 2,
                            getTitlesWidget: (value, meta) {
                              final i = value.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  labels[i],
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.4),
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      minX: 0,
                      maxX: 13,
                      minY: 0,
                      maxY: (maxCount * 1.25).ceilToDouble(),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF1E2128),
                          getTooltipItems: (spots) => spots
                              .map(
                                (spot) => LineTooltipItem(
                                  '${spot.y.toInt()} plays',
                                  const TextStyle(
                                    color: Color(0xFF64B5F6),
                                    fontSize: 11,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: counts
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(
                                  e.key.toDouble(),
                                  e.value.toDouble(),
                                ),
                              )
                              .toList(),
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: const Color(0xFF1976D2),
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(
                            show: true,
                            checkToShowDot: (spot, _) => spot.y > 0,
                            getDotPainter: (spot, _, _, _) =>
                                FlDotCirclePainter(
                                  radius: 3,
                                  color: const Color(0xFF42A5F5),
                                  strokeWidth: 0,
                                  strokeColor: Colors.transparent,
                                ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF1976D2).withValues(alpha: 0.35),
                                const Color(0xFF1976D2).withValues(alpha: 0.0),
                              ],
                            ),
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
