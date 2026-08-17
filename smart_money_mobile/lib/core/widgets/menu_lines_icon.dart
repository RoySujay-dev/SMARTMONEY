import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// The app's hamburger glyph: two rounded bars of uneven length.
///
/// Used instead of [Icons.menu] so every screen that opens the drawer shows
/// the same mark the dashboard has always used.
class MenuLinesIcon extends StatelessWidget {
  const MenuLinesIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 18,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 18,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 13,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.textDark,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }
}

/// Button that opens the enclosing [Scaffold]'s drawer.
///
/// Wraps itself in a [Builder] so it can be handed straight to
/// `AppBar.leading`, where the surrounding context is the one that built the
/// Scaffold and therefore cannot find it.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (innerContext) => IconButton(
        tooltip: 'Open menu',
        icon: const MenuLinesIcon(),
        onPressed: () => Scaffold.of(innerContext).openDrawer(),
      ),
    );
  }
}
