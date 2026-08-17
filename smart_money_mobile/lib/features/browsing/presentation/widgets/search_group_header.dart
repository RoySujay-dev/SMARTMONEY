import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Section heading above a group of search results ("Stores (3)").
///
/// Shared rather than private to the dashboard so it stays beside the
/// [StoreCard] / [OfferCard] rows it labels.
class SearchGroupHeader extends StatelessWidget {
  const SearchGroupHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
  });

  final IconData icon;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '($count)',
          style: const TextStyle(
            color: AppColors.textSoft,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
