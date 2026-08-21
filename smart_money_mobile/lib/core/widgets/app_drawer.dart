import 'package:flutter/material.dart';

import '../../app/routes/route_names.dart';
import '../../features/profile/data/profile_summary_store.dart';
import '../../features/shell/presentation/screens/main_shell.dart';
import '../constants/app_colors.dart';
import 'profile_avatar.dart';

/// Destinations in [AppDrawer]. Each hosting screen passes its own so the
/// matching row renders as active.
enum AppDrawerItem { dashboard, stores, offers, categories, withdraw, profile }

/// The app's side navigation.
///
/// Hosted through `Scaffold(drawer: ...)` rather than a hand-rolled overlay, so
/// every screen gets swipe-to-open, an animated close, back-button handling and
/// drawer semantics from the framework instead of reimplementing them.
///
/// Navigation always returns to [MainShell] first. Section destinations are
/// shell tabs, and a pushed route such as Categories sits *above* the shell on
/// the navigator — so without popping back, tapping "Stores" from Categories
/// would stack a second Stores on top of it.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.current});

  /// The destination the hosting screen represents.
  final AppDrawerItem current;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8FAFF),
      width: (MediaQuery.sizeOf(context).width * 0.80).clamp(0.0, 320.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(26),
          bottomRight: Radius.circular(26),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 14, 0),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildProfileRow(),
              const SizedBox(height: 22),
              Expanded(
                child: SingleChildScrollView(child: _buildMenuList(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            boxShadow: [AppColors.cardShadow],
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            'assets/images/smartmoney_mark.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Image.asset(
            'assets/images/smartmoney_wordmark.png',
            height: 24,
            fit: BoxFit.contain,
            alignment: Alignment.centerLeft,
          ),
        ),
        IconButton(
          tooltip: 'Close menu',
          icon: const Icon(Icons.close_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildProfileRow() {
    return ValueListenableBuilder<ProfileSummary>(
      valueListenable: ProfileSummaryStore.instance.summary,
      builder: (context, profile, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.82)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
                child: ProfileAvatar(
                  initials: profile.initials,
                  imageUrl: profile.imageUrl,
                  size: 42,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      profile.email.isEmpty ? 'No email found' : profile.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textSoft,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            profile.isVerified
                                ? Icons.verified_rounded
                                : Icons.shield_outlined,
                            color: AppColors.primary,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            profile.isVerified ? 'Verified' : 'Active',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuList(BuildContext context) {
    const items = [
      (AppDrawerItem.dashboard, 'Dashboard', Icons.dashboard_outlined),
      (AppDrawerItem.stores, 'Stores', Icons.storefront_outlined),
      (AppDrawerItem.offers, 'Offers', Icons.local_offer_outlined),
      (AppDrawerItem.categories, 'Categories', Icons.grid_view_rounded),
      (
        AppDrawerItem.withdraw,
        'Withdraw',
        Icons.account_balance_wallet_outlined,
      ),
      (AppDrawerItem.profile, 'Profile', Icons.person_outline_rounded),
    ];

    return Column(
      children: [
        for (final (item, label, icon) in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _DrawerMenuRow(
              label: label,
              icon: icon,
              isActive: item == current,
              onTap: () => _select(context, item),
            ),
          ),
      ],
    );
  }

  void _select(BuildContext context, AppDrawerItem item) {
    final navigator = Navigator.of(context);
    navigator.pop(); // Close the drawer.

    if (item == current) return;

    switch (item) {
      case AppDrawerItem.dashboard:
        _toShellTab(navigator, ShellTab.home);
      case AppDrawerItem.stores:
        _toShellTab(navigator, ShellTab.stores);
      case AppDrawerItem.offers:
        _toShellTab(navigator, ShellTab.offers);
      case AppDrawerItem.categories:
        _toPushedRoute(navigator, RouteNames.categories);
      case AppDrawerItem.profile:
        _toPushedRoute(navigator, RouteNames.profile).then((_) {
          // The profile screen can change the name or photo.
          ProfileSummaryStore.instance.refresh();
        });
      case AppDrawerItem.withdraw:
        // No destination exists yet; the row is a placeholder.
        break;
    }
  }

  /// Unwinds to the shell before switching, so tabs never stack.
  void _toShellTab(NavigatorState navigator, ShellTab tab) {
    navigator.popUntil((route) => route.isFirst);
    MainShell.shellKey.currentState?.goToTab(tab);
  }

  /// Unwinds to the shell first as well, so repeatedly hopping between
  /// Categories and Profile cannot grow the back stack without bound.
  Future<void> _toPushedRoute(NavigatorState navigator, String routeName) {
    navigator.popUntil((route) => route.isFirst);
    return navigator.pushNamed(routeName);
  }
}

class _DrawerMenuRow extends StatelessWidget {
  const _DrawerMenuRow({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isActive ? AppColors.primary : AppColors.textMid;
    final backgroundColor = isActive
        ? AppColors.primary.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.34);
    final iconBackgroundColor = isActive
        ? AppColors.primary.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.70);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.only(left: 8, right: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.44),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: isActive ? 24 : 0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 9),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: foregroundColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isActive ? AppColors.textDark : AppColors.textMid,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: foregroundColor.withValues(alpha: isActive ? 0.75 : 0.45),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
