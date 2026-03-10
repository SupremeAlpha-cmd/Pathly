import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary - Pathly Green
  static const Color primary = Color(0xFF1A7F5A);
  static const Color primaryLight = Color(0xFF25A876);
  static const Color primaryDark = Color(0xFF135F43);
  static const Color primarySurface = Color(0xFFE8F5F0);

  // Accent
  static const Color accent = Color(0xFFFFB830);
  static const Color accentSurface = Color(0xFFFFF3D6);

  // Neutrals
  static const Color dark = Color(0xFF0F1A14);
  static const Color grey900 = Color(0xFF1C2B22);
  static const Color grey700 = Color(0xFF3D5247);
  static const Color grey500 = Color(0xFF6B8F7E);
  static const Color grey300 = Color(0xFFB0CBBF);
  static const Color grey100 = Color(0xFFEDF4F1);
  static const Color white = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Background
  static const Color background = Color(0xFFF7FBF9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F7F4);

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A7F5A), Color(0xFF0D5C3E)],
  );
}