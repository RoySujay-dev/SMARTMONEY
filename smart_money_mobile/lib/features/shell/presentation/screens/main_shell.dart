import 'package:flutter/material.dart';

import '../../../browsing/presentation/screens/offers_screen.dart';
import '../../../browsing/presentation/screens/search_screen.dart';
import '../../../browsing/presentation/screens/stores_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_setup_screen.dart';

/// Tabs hosted by [MainShell]. The order matches [_MainShellState] children.
enum ShellTab { home, stores, offers, search, profile }

/// Shell around the main browsing sections.
///
/// There is no bottom bar: navigation runs through the dashboard's side drawer,
/// its search bar and the section "see all" headers, all of which call
/// [goToTab]. The shell is kept because tabs are held alive in an
/// [IndexedStack] so scroll position and already loaded data survive tab
/// switches (which also avoids re-hitting the API on every switch). Tabs are
/// built lazily — a tab's screen is only constructed the first time it is
/// visited.
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

  void _goHome() => goToTab(ShellTab.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _lazyTab(0, () => DashboardScreen(onSelectTab: goToTab)),
          _lazyTab(1, () => StoresScreen(onBack: _goHome)),
          _lazyTab(2, () => OffersScreen(onBack: _goHome)),
          _lazyTab(3, () => SearchScreen(autofocus: false, onBack: _goHome)),
          _lazyTab(4, () => const ProfileSetupScreen()),
        ],
      ),
    );
  }

  Widget _lazyTab(int index, Widget Function() builder) {
    if (!_visited.contains(index)) {
      return const SizedBox.shrink();
    }
    return builder();
  }
}
