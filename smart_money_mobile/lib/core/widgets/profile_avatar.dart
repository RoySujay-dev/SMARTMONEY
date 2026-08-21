import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Circular profile picture that degrades to gradient-backed initials.
///
/// Shared because the drawer and the dashboard topbar both show it, and the
/// drawer is now hosted by several screens.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.initials,
    required this.imageUrl,
    required this.size,
    required this.fontSize,
  });

  final String initials;
  final String imageUrl;
  final double size;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? Image.network(
              imageUrl,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _InitialsLabel(initials: initials, fontSize: fontSize);
              },
            )
          : _InitialsLabel(initials: initials, fontSize: fontSize),
    );
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.initials, required this.fontSize});

  final String initials;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
