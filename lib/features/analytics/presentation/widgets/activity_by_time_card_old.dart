// import 'dart:math' as math;
// import 'package:flutter/material.dart';

// class ActivityByTimeCard extends StatelessWidget {
//   const ActivityByTimeCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Mock data representing 24 hours of activity (0 to 23)
//     final List<double> hourlyData = [
//       2,
//       1,
//       0,
//       0,
//       1,
//       3,
//       8,
//       15,
//       22,
//       25,
//       20,
//       18,
//       22,
//       28,
//       35,
//       40,
//       42,
//       38,
//       30,
//       25,
//       18,
//       12,
//       8,
//       5,
//     ];

//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: const Color(0xFF16181D), // Deep dark background
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(
//                 Icons.access_time_rounded,
//                 color: Colors.blueAccent,
//                 size: 20,
//               ),
//               const SizedBox(width: 8),
//               const Text(
//                 'Activity by Time',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             'Peak listening: 16:00 - 17:00 (42 plays avg). Strong afternoon preference indicates focus/work sessions.',
//             style: TextStyle(
//               color: Colors.white.withValues(alpha: 0.6),
//               fontSize: 12,
//               height: 1.4,
//             ),
//           ),
//           const SizedBox(height: 32),
//           Center(
//             child: SizedBox(
//               width: 240,
//               height: 240,
//               child: CustomPaint(painter: _PolarChartPainter(data: hourlyData)),
//             ),
//           ),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
// }

// class _PolarChartPainter extends CustomPainter {
//   final List<double> data;
//   final double maxData;

//   _PolarChartPainter({required this.data}) : maxData = data.reduce(math.max);

//   @override
//   void paint(Canvas canvas, Size size) {
//     final center = Offset(size.width / 2, size.height / 2);
//     // Radius leaves room for labels on the outside
//     final radius = (math.min(size.width, size.height) / 2) - 24;

//     // 1. Draw concentric grid circles
//     final gridPaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.05)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1;

//     canvas.drawCircle(center, radius, gridPaint);
//     canvas.drawCircle(center, radius * 0.66, gridPaint);
//     canvas.drawCircle(center, radius * 0.33, gridPaint);

//     // 2. Draw the 24 wedges
//     final barPaint = Paint()..style = PaintingStyle.fill;
//     final strokePaint = Paint()
//       ..color =
//           const Color(0xFF16181D) // Match background to create gaps
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;

//     final sweepAngle = (2 * math.pi) / 24;
//     final innerRadius = radius * 0.25; // Hollow center

//     for (int i = 0; i < 24; i++) {
//       final normalizedValue = data[i] / maxData;
//       // Calculate how far out this bar should stretch
//       final barRadius =
//           innerRadius + (normalizedValue * (radius - innerRadius));
//       // Start at top (-90 degrees or -pi/2)
//       final startAngle = -math.pi / 2 + (i * sweepAngle);

//       // Create a slight gradient effect based on height
//       barPaint.color = const Color(
//         0xFF1976D2,
//       ).withValues(alpha: 0.6 + (0.4 * normalizedValue));

//       final path = Path();
//       path.moveTo(center.dx, center.dy);
//       path.arcTo(
//         Rect.fromCircle(center: center, radius: barRadius),
//         startAngle,
//         sweepAngle,
//         false,
//       );
//       path.close();

//       canvas.drawPath(path, barPaint);
//       canvas.drawPath(path, strokePaint); // Draws the gap between wedges
//     }

//     // 3. Draw Center Overlay Circle
//     final centerOverlayPaint = Paint()
//       ..color = const Color(0xFF1A1C23)
//       ..style = PaintingStyle.fill;
//     canvas.drawCircle(center, innerRadius + 4, centerOverlayPaint);
//     canvas.drawCircle(center, innerRadius + 4, gridPaint); // Inner border

//     // 4. Draw Center Text
//     _drawText(
//       canvas,
//       center,
//       "Activity\nby Hour",
//       fontSize: 10,
//       color: Colors.white70,
//     );

//     // 5. Draw Outer Axis Labels
//     _drawLabelAtAngle(canvas, center, radius, -math.pi / 2, "12am"); // Top
//     _drawLabelAtAngle(canvas, center, radius, 0, "6am"); // Right
//     _drawLabelAtAngle(canvas, center, radius, math.pi / 2, "12pm"); // Bottom
//     _drawLabelAtAngle(canvas, center, radius, math.pi, "6pm"); // Left
//   }

//   void _drawLabelAtAngle(
//     Canvas canvas,
//     Offset center,
//     double radius,
//     double angle,
//     String text,
//   ) {
//     final offset = Offset(
//       center.dx + (radius + 18) * math.cos(angle),
//       center.dy + (radius + 18) * math.sin(angle),
//     );
//     _drawText(canvas, offset, text, fontSize: 11, color: Colors.white54);
//   }

//   void _drawText(
//     Canvas canvas,
//     Offset position,
//     String text, {
//     required double fontSize,
//     required Color color,
//   }) {
//     final textPainter = TextPainter(
//       text: TextSpan(
//         text: text,
//         style: TextStyle(color: color, fontSize: fontSize, height: 1.2),
//       ),
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     )..layout();

//     textPainter.paint(
//       canvas,
//       position - Offset(textPainter.width / 2, textPainter.height / 2),
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }
