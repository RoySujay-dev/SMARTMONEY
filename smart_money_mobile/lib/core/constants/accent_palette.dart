import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Deterministic accent colours for data-driven tiles (categories, avatars).
///
/// Colours are derived from a stable key (e.g. a slug) so the same category
/// always renders in the same colour across screens and app launches, without
/// hardcoding any category names.
class AccentPalette {
  AccentPalette._();

  static const List<Color> colors = [
    AppColors.primary,
    Color(0xFFEC4899), // pink
    AppColors.info,
    AppColors.success,
    AppColors.warning,
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
    Color(0xFFF97316), // orange
  ];

  static Color forKey(String key) {
    if (key.isEmpty) return AppColors.primary;

    var hash = 0;
    for (final unit in key.codeUnits) {
      hash = (hash + unit) % colors.length;
    }

    return colors[hash];
  }
}
