import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActivityByTimeCard extends StatelessWidget {
  final Map<String, int> distribution;

  const ActivityByTimeCard({super.key, required this.distribution});

  @override
  Widget build(BuildContext context) {
    final morning = distribution['morning'] ?? 0;
    final afternoon = distribution['afternoon'] ?? 0;
    final evening = distribution['evening'] ?? 0; // ADD
    final night = distribution['night'] ?? 0;
    final total = morning + afternoon + evening + night; // ADD evening

    if (total == 0) return _emptyState();

    final segments = [
      _Segment(
        'Morning',
        morning,
        const Color(0xFFFFB300),
        Icons.wb_sunny_outlined,
      ),
      _Segment('Afternoon', afternoon, const Color(0xFF1976D2), Icons.wb_sunny),
      _Segment(
        'Evening',
        evening,
        const Color(0xFFFF7043),
        Icons.wb_twilight,
      ), // ADD
      _Segment('Night', night, const Color(0xFF9C27B0), Icons.nightlight_round),
    ];

    final peak = segments.reduce((a, b) => a.count > b.count ? a : b);

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
                Icons.access_time_rounded,
                color: Colors.blueAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Activity by Time',
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
            'Peak: ${peak.label} · ${peak.count} plays · ${(peak.count / total * 100).toStringAsFixed(0)}% of total',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              // Donut chart
              SizedBox(
                width: 140,
                height: 140,
                child: CustomPaint(
                  painter: _DonutPainter(segments: segments, total: total),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(peak.icon, color: peak.color, size: 18),
                        const SizedBox(height: 4),
                        Text(
                          '${(peak.count / total * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          peak.label,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              // Legend with mini bars
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: segments.map((seg) {
                    final pct = total > 0 ? seg.count / total : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(seg.icon, color: seg.color, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                seg.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${seg.count}',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          LayoutBuilder(
                            builder: (context, constraints) => Stack(
                              children: [
                                Container(
                                  height: 4,
                                  width: constraints.maxWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.06),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                Container(
                                  height: 4,
                                  width: constraints.maxWidth * pct,
                                  decoration: BoxDecoration(
                                    color: seg.color,
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: seg.color.withValues(alpha: 0.4),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16181D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Center(
        child: Text(
          'No activity data yet',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _Segment {
  final String label;
  final int count;
  final Color color;
  final IconData icon;
  const _Segment(this.label, this.count, this.color, this.icon);
}

class _DonutPainter extends CustomPainter {
  final List<_Segment> segments;
  final int total;

  const _DonutPainter({required this.segments, required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const strokeWidth = 18.0;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white.withValues(alpha: 0.06);
    canvas.drawCircle(center, radius, bgPaint);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;
    const gap = 0.06;

    for (final seg in segments) {
      if (seg.count == 0) continue;
      final sweep = (seg.count / total) * 2 * math.pi;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle + gap,
        sweep - gap * 2,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) => old.total != total;
}
