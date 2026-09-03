import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces (Dark-mode first)
  static const Color background = Color(0xFF0B0F19);
  static const Color surface = Color(0xFF131B2E);
  static const Color surfaceElevated = Color(0xFF1C2740);
  static const Color card = Color(0xFF172036);
  static const Color border = Color(0xFF263554);
  static const Color divider = Color(0xFF1E2C48);

  // Light Mode Fallback Surfaces
  static const Color backgroundLight = Color(0xFFF4F6FB);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Brand & Primary
  static const Color primary = Color(0xFF00E5FF); // Neon Cyber Cyan
  static const Color primaryDark = Color(0xFF00B0FF);
  static const Color primaryLight = Color(0xFF80F0FF);
  static const Color primaryGlow = Color(0x3300E5FF);

  // Radar & Hazard Colors
  static const Color radarRed = Color(0xFFFF3366);      // Speed Cameras, Violations
  static const Color radarRedGlow = Color(0x40FF3366);
  static const Color cautionAmber = Color(0xFFFFB703);   // Mobile Patrol, Caution
  static const Color cautionAmberGlow = Color(0x40FFB703);
  static const Color safeGreen = Color(0xFF06D6A0);      // Safe Speed, Verified Clear
  static const Color safeGreenGlow = Color(0x4006D6A0);
  static const Color speedTrapPurple = Color(0xFFA855F7); // Section control / Trap
  static const Color hazardOrange = Color(0xFFFB8500);   // Accident, Roadwork
  static const Color policeBlue = Color(0xFF3B82F6);     // Police radar

  // Text Colors
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF3366), Color(0xFFFF6584)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient safeGradient = LinearGradient(
    colors: [Color(0xFF06D6A0), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF162035), Color(0xFF0F1728)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
