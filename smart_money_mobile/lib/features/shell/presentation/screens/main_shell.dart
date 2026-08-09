import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../browsing/presentation/screens/offers_screen.dart';
import '../../../browsing/presentation/screens/search_screen.dart';
import '../../../browsing/presentation/screens/stores_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_setup_screen.dart';

/// Tabs hosted by [MainShell]. The order matches the bottom bar.
enum ShellTab { home, stores, offers, search, profile }

/// Persistent bottom-navigation shell around the main browsing sections.
///
/// Tabs are kept alive in an [IndexedStack] so scroll position and already
/// loaded data survive tab switches (which also avoids re-hitting the API on
/// every switch). Tabs are built lazily — a tab's screen is only constructed
/// the first time it is visited.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = ShellTab.home});

  final ShellTab initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex = widget.initialTab.index;
  late final Set<int> _visited = {widget.initialTab.index};

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _visited.add(index);
    });
  }

  /// Lets child screens (e.g. the dashboard's "see all" headers) switch tabs.
  void goToTab(ShellTab tab) => _selectTab(tab.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _lazyTab(0, () => DashboardScreen(onSelectTab: goToTab)),
          _lazyTab(1, () => const StoresScreen(showBackButton: false)),
          _lazyTab(2, () => const OffersScreen(showBackButton: false)),
          _lazyTab(3, () => const SearchScreen(autofocus: false)),
          _lazyTab(4, () => const ProfileSetupScreen()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _lazyTab(int index, Widget Function() builder) {
    if (!_visited.contains(index)) {
      return const SizedBox.shrink();
    }
    return builder();
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.12),
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected ? AppColors.primary : AppColors.textSoft,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                size: 22,
                color: selected ? AppColors.primary : AppColors.textSoft,
              );
            }),
          ),
          child: NavigationBar(
            height: 64,
            elevation: 0,
            selectedIndex: _currentIndex,
            onDestinationSelected: _selectTab,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'Stores',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon: Icon(Icons.local_offer_rounded),
                label: 'Offers',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_rounded),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
