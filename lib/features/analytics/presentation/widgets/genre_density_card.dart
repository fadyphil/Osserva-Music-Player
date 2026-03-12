import 'package:flutter/material.dart';

class GenreDensityCard extends StatelessWidget {
  const GenreDensityCard({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Genre Density',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Visual representation of genre dominance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              width: 200,
              height: 180,
              child: CustomPaint(painter: _GenreDensityPainter()),
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              _buildGenreLegendRow(Colors.blue, 'Electronic', '1,240', '35%'),
              _buildGenreLegendRow(
                Colors.purpleAccent,
                'Ambient',
                '850',
                '24%',
              ),
              _buildGenreLegendRow(Colors.green, 'Indie', '620', '18%'),
              _buildGenreLegendRow(
                const Color(0xFFD4A017),
                'Jazz',
                '450',
                '13%',
              ),
              _buildGenreLegendRow(Colors.redAccent, 'Classical', '350', '10%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreLegendRow(
    Color color,
    String name,
    String plays,
    String percentage,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            '$plays plays',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            percentage,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _GenreDensityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Using BlendMode.screen or adjusting alpha creates the nice overlapping color effect
    final paint = Paint()..style = PaintingStyle.fill;

    // These offsets and radii would ideally be calculated by your AnalyticsBloc
    // based on percentages, but here is the geometric layout matching your UI.

    // Electronic (Blue - Largest, Right)
    paint.color = Colors.blue.withValues(alpha: 0.75);
    canvas.drawCircle(center + const Offset(30, 0), 65, paint);

    // Ambient (Purple - Bottom)
    paint.color = Colors.purpleAccent.withValues(alpha: 0.75);
    canvas.drawCircle(center + const Offset(10, 40), 55, paint);

    // Indie (Green - Left)
    paint.color = Colors.green.withValues(alpha: 0.75);
    canvas.drawCircle(center + const Offset(-40, 10), 45, paint);

    // Jazz (Yellow/Orange - Top Left)
    paint.color = const Color(0xFFD4A017).withValues(alpha: 0.8);
    canvas.drawCircle(center + const Offset(-25, -30), 40, paint);

    // Classical (Red - Top)
    paint.color = Colors.redAccent.withValues(alpha: 0.8);
    canvas.drawCircle(center + const Offset(15, -45), 30, paint);

    // Tiny blue dot in center
    paint.color = Colors.blue;
    canvas.drawCircle(center + const Offset(0, 0), 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
