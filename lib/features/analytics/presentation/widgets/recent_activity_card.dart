import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:music_player/features/analytics/domain/entities/play_log.dart';

class RecentActivityCard extends StatelessWidget {
  final List<PlayLog> logs;

  const RecentActivityCard({super.key, required this.logs});

  List<_DayActivity> _buildLast7Days() {
    // Group logs by date key
    final Map<String, int> dateMap = {};
    for (final log in logs) {
      final t = log.timestamp;
      final key = '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
      dateMap[key] = (dateMap[key] ?? 0) + 1;
    }

    final today = DateTime.now();
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (i) {
      final date = today.subtract(Duration(days: 6 - i));
      final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      return _DayActivity(
        dateLabel: date.day.toString(),
        dayName: dayNames[date.weekday - 1],
        plays: dateMap[key] ?? 0,
        isToday: i == 6,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _buildLast7Days();
    final maxPlays = days.map((d) => d.plays).reduce(math.max);

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
              const Icon(Icons.calendar_today_rounded, color: Colors.orangeAccent, size: 20),
              const SizedBox(width: 8),
              const Text('Recent Activity', style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold,
              )),
              const Spacer(),
              Text('Last 7 days', style: TextStyle(
                color: Colors.white.withValues(alpha: 0.4), fontSize: 11,
              )),
            ],
          ),
          const SizedBox(height: 20),
          if (maxPlays == 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text('No plays in the last 7 days', style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4), fontSize: 13,
                )),
              ),
            )
          else
            ...days.map((day) => _buildDayRow(day, maxPlays)),
        ],
      ),
    );
  }

  Widget _buildDayRow(_DayActivity day, int maxPlays) {
    final pct = maxPlays > 0 ? day.plays / maxPlays : 0.0;
    final barColor = day.isToday ? Colors.orangeAccent : Colors.orangeAccent.withValues(alpha: 0.6);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(day.dayName, style: TextStyle(
                  color: day.isToday
                      ? Colors.orangeAccent
                      : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                )),
                Text(day.dateLabel, style: TextStyle(
                  color: day.isToday ? Colors.white : Colors.white.withValues(alpha: 0.8),
                  fontSize: 13, fontWeight: FontWeight.bold,
                )),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 7,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (day.plays > 0)
                  FractionallySizedBox(
                    widthFactor: pct,
                    child: Container(
                      height: 7,
                      decoration: BoxDecoration(
                        color: barColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [BoxShadow(
                          color: barColor.withValues(alpha: 0.35),
                          blurRadius: 6, offset: const Offset(0, 2),
                        )],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 52,
            child: Text(
              day.plays > 0 ? '${day.plays} plays' : '—',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: day.plays > 0
                    ? Colors.white.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.2),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayActivity {
  final String dateLabel;
  final String dayName;
  final int plays;
  final bool isToday;

  const _DayActivity({
    required this.dateLabel,
    required this.dayName,
    required this.plays,
    required this.isToday,
  });
}
