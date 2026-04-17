import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color brandGreen = Color(0xFF0F766E);
  static const Color brandBlue = Color(0xFF1D4ED8);
  static const Color accent = Color(0xFF14B8A6);

  static const Color lightBackground = Color(0xFFF6F8FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceMuted = Color(0xFFF0F4F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightBorder = Color(0xFFD9E2EC);

  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF121C2E);
  static const Color darkSurfaceMuted = Color(0xFF1C2A3F);
  static const Color darkTextPrimary = Color(0xFFE2E8F0);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF2A3B56);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // Compatibility aliases used by existing screens.
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color primary = brandGreen;
  static const Color primaryDark = Color(0xFF0A5B55);
  static const Color secondary = brandBlue;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color border = lightBorder;
  static const Color tint = Color(0xFFE3F8F4);
  static const Color highlight = Color(0xFFEAF2FF);
}
