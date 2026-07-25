import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const primary = Color(0xFF6366F1);
  static const primaryEnd = Color(0xFF8B5CF6);
  static const primarySoft = Color(0x1F6366F1);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  static const textDark = Color(0xFF1E293B);
  static const textMid = Color(0xFF475569);
  static const textSoft = Color(0xFF94A3B8);
  static const inputFill = Color(0xFFF1F5F9);
  static const inputBorder = Color(0xFFE2E8F0);

  static const backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFDBEAFE), Color(0xFFE0E7FF), Color(0xFFF3E8FF)],
    stops: [0.0, 0.45, 1.0],
  );

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryEnd],
  );

  static const primaryGradientExtended = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryEnd, Color(0xFFA78BFA)],
    stops: [0.0, 0.6, 1.0],
  );

  static BoxShadow get cardShadow {
    return BoxShadow(
      color: primary.withValues(alpha: 0.10),
      blurRadius: 32,
      offset: const Offset(0, 10),
    );
  }

  static BoxShadow get buttonShadow {
    return BoxShadow(
      color: primary.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    );
  }
}
