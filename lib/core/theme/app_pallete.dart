import 'package:flutter/material.dart';

class AppPallete {
  // Design 2.0 "Pulse" Theme (Dark Mode)
  
  // Base
  static const Color background = Color(0xFF0D1117); // GitHub Dark Dimmed-ish
  static const Color foreground = Color(0xFFE6EDF3); 
  static const Color surface = Color(0xFF161B22); // Secondary/Card
  static const Color border = Color(0xFF30363D);
  
  // Accents
  static const Color accent = Color(0xFF1F6FEB); // Blue
  static const Color destructive = Color(0xFFF85149); // Red
  
  // Charts / Analytics
  static const Color chart1 = Color(0xFF1F6FEB); // Blue
  static const Color chart2 = Color(0xFFA371F7); // Purple
  static const Color chart3 = Color(0xFF3FB950); // Green
  static const Color chart4 = Color(0xFFD29922); // Yellow/Orange
  static const Color chart5 = Color(0xFFF85149); // Red

  // Legacy mappings (for backward compatibility during migration)
  static const Color backgroundColor = background;
  static const Color primaryGreen = chart3; // Approximate replacement
  static const Color primaryColor = accent;
  static const Color cardColor = surface;
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF7D8590); // Muted foreground
  static const Color transparent = Colors.transparent;
}