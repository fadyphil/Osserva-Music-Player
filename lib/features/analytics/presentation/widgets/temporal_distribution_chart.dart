import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class TemporalDistributionChart extends StatelessWidget {
  const TemporalDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2128), // Dark card background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temporal Distribution',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Listening patterns across time periods',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withValues(alpha: 0.05),
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
                      reservedSize: 22,
                      interval: 6,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                minX: 0,
                maxX: 23,
                minY: 0,
                maxY:
                    15, // Adjusted based on the max value in spots (12) + some padding
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  // Tertiary (Back layer - Greenish)
                  _buildLineChartBarData(
                    color: const Color(0xFF2E7D32),
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(6, 5),
                      FlSpot(12, 3),
                      FlSpot(18, 8),
                      FlSpot(23, 4),
                    ],
                  ),
                  // Secondary (Middle layer - Purple)
                  _buildLineChartBarData(
                    color: const Color(0xFF673AB7),
                    spots: const [
                      FlSpot(0, 5),
                      FlSpot(6, 8),
                      FlSpot(12, 6),
                      FlSpot(18, 10),
                      FlSpot(23, 7),
                    ],
                  ),
                  // Primary (Front layer - Blue)
                  _buildLineChartBarData(
                    color: const Color(0xFF1976D2),
                    spots: const [
                      FlSpot(0, 7),
                      FlSpot(6, 10),
                      FlSpot(12, 8),
                      FlSpot(18, 12),
                      FlSpot(23, 9),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            children: [
              _buildLegendItem(const Color(0xFF1976D2), 'Pop'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFF673AB7), 'Rock'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFF2E7D32), 'Electronic'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartBarData _buildLineChartBarData({
    required Color color,
    required List<FlSpot> spots,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 0, // Set to 0 so only the filled area shows
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 
          0.7,
        ), // Transparency creates the overlap effect
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
        ),
      ],
    );
  }
}
