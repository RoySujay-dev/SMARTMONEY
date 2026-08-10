import 'package:flutter/material.dart';

import '../constants/accent_palette.dart';
import 'network_image_with_fallback.dart';

/// Small square brand mark for a store.
///
/// Shows the store's logo when one is available and degrades to the
/// accent-tinted initial that the app used before any media existed, so a store
/// without artwork still reads as a distinct brand rather than a grey box.
class BrandLogoMark extends StatelessWidget {
  const BrandLogoMark({
    super.key,
    required this.name,
    required this.slug,
    this.logoUrl,
    this.size = 28,
    this.radius = 8,
  });

  final String name;
  final String slug;
  final String? logoUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final accent = AccentPalette.forKey(slug.isNotEmpty ? slug : name);
    final hasLogo = (logoUrl?.trim().isNotEmpty) ?? false;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: hasLogo ? Colors.white : accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasLogo
          ? Padding(
              padding: EdgeInsets.all(size * 0.12),
              child: NetworkImageWithFallback(
                url: logoUrl,
                fit: BoxFit.contain,
                fallbackIcon: Icons.storefront_outlined,
                backgroundColor: Colors.transparent,
                iconColor: accent,
                iconSize: size * 0.55,
              ),
            )
          : Center(
              child: Text(
                _initial,
                style: TextStyle(
                  color: accent,
                  fontSize: size * 0.46,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
    );
  }

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '#' : trimmed[0].toUpperCase();
  }
}
