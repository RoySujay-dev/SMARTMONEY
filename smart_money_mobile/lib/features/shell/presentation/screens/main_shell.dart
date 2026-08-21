import 'package:flutter/material.dart';

import '../../../browsing/presentation/screens/offers_screen.dart';
import '../../../browsing/presentation/screens/stores_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../profile/presentation/screens/profile_setup_screen.dart';

/// Tabs hosted by [MainShell]. The order matches [MainShellState] children.
enum ShellTab { home, stores, offers, profile }

/// Shell around the main browsing sections.
///
/// There is no bottom bar: navigation runs through the side drawer and the
/// dashboard's section "see all" headers, both of which call [MainShellState
/// .goToTab]. Search is not a tab — it happens inline on the dashboard. The
/// shell is kept because tabs are held alive in an [IndexedStack] so scroll
/// position and already loaded data survive tab switches (which also avoids
/// re-hitting the API on every switch). Tabs are built lazily — a tab's screen
/// is only constructed the first time it is visited.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = ShellTab.home});

  /// Identifies the single shell instance so the drawer can switch tabs from
  /// anywhere — including pushed routes such as Categories, which sit above
  /// the shell on the navigator rather than inside its widget subtree, so no
  /// ancestor lookup could reach it.
  static final GlobalKey<MainShellState> shellKey =
      GlobalKey<MainShellState>();

  final ShellTab initialTab;

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  late int _currentIndex = widget.initialTab.index;
  late final Set<int> _visited = {widget.initialTab.index};

  void _selectTab(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _currentIndex = index;
      _visited.add(index);
    });
  }

  /// Lets the drawer and the dashboard's "see all" headers switch tabs.
  void goToTab(ShellTab tab) => _selectTab(tab.index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _lazyTab(0, () => DashboardScreen(onSelectTab: goToTab)),
          _lazyTab(1, () => const StoresScreen()),
          _lazyTab(2, () => const OffersScreen()),
          _lazyTab(3, () => const ProfileSetupScreen()),
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
