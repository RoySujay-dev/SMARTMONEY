import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/login_demo_widgets.dart';
import '../../../profile/data/services/profile_api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileApiService = ProfileApiService();
  String _profileInitials = 'SM';
  String _profileName = 'SmartMoney User';
  String _profileEmail = '';
  String _profileImageUrl = '';
  bool _isProfileVerified = false;
  bool _isDrawerOpen = false;
  String _selectedDrawerItem = 'Dashboard';

  final List<Map<String, Object>> _categories = const [
    {
      'label': 'Fashion',
      'icon': Icons.checkroom_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'label': 'Food',
      'icon': Icons.restaurant_outlined,
      'color': AppColors.warning,
    },
    {
      'label': 'Travel',
      'icon': Icons.flight_takeoff_outlined,
      'color': AppColors.info,
    },
    {
      'label': 'Grocery',
      'icon': Icons.local_grocery_store_outlined,
      'color': AppColors.success,
    },
    {
      'label': 'Electronics',
      'icon': Icons.devices_outlined,
      'color': AppColors.primary,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileSummary();
  }

  @override
  void dispose() {
    _profileApiService.dispose();
    super.dispose();
  }

  Future<void> _loadProfileSummary() async {
    try {
      final profile = await _profileApiService.getProfile();

      if (!mounted) return;

      setState(() {
        _profileInitials = _initials(profile.fullName);
        _profileName = profile.fullName;
        _profileEmail = profile.email;
        _profileImageUrl = _profileImageUrlFor(profile.profileImageUrl);
        _isProfileVerified = profile.isEmailVerified;
      });
    } catch (_) {
      // Keep the default profile chip if the session is missing or expired.
    }
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'SM';
    }

    return parts.take(2).map((part) => part[0]).join().toUpperCase();
  }

  String _profileImageUrlFor(String value) {
    final imageUrl = value.trim();

    if (imageUrl.isEmpty) {
      return '';
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return '${_profileApiService.baseUrl}$imageUrl';
  }

  final List<Map<String, Object>> _featuredOffers = const [
    {
      'brand': 'Flipkart',
      'title': 'Big Save Days',
      'rate': 'Up to 8%',
      'badge': 'Hot',
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.primary,
      'logoPath': 'assets/images/brands/flipkart.png',
      'themeColor': Color(0xFF2874F0),
    },
    {
      'brand': 'Myntra',
      'title': 'Fashion weekend',
      'rate': '12%',
      'badge': 'Best rate',
      'icon': Icons.checkroom_outlined,
      'color': Color(0xFFEC4899),
      'logoPath': 'assets/images/brands/myntra.png',
      'themeColor': Color(0xFFEC4899),
    },
    {
      'brand': 'Swiggy',
      'title': 'Food orders',
      'rate': '5%',
      'badge': 'Popular',
      'icon': Icons.restaurant_outlined,
      'color': AppColors.warning,
      'logoPath': 'assets/images/brands/swiggy.png',
      'themeColor': Color(0xFFFC8019),
    },
  ];

  final List<Map<String, Object>> _stores = const [
    {
      'name': 'Flipkart',
      'code': 'FK',
      'category': 'Electronics',
      'rate': 'Up to 8%',
      'color': AppColors.primary,
      'logoPath': 'assets/images/brands/flipkart.png',
    },
    {
      'name': 'Amazon',
      'code': 'AZ',
      'category': 'Marketplace',
      'rate': '6.5%',
      'color': AppColors.info,
      'logoPath': 'assets/images/brands/amazon.webp',
    },
    {
      'name': 'Myntra',
      'code': 'MN',
      'category': 'Fashion',
      'rate': '12%',
      'color': Color(0xFFEC4899),
      'logoPath': 'assets/images/brands/myntra.png',
    },
    {
      'name': 'MakeMyTrip',
      'code': 'MT',
      'category': 'Travel',
      'rate': '9%',
      'color': AppColors.success,
    },
  ];

  final List<Map<String, Object>> _recommendations = const [
    {
      'title': 'Highest cashback today',
      'store': 'Myntra',
      'rate': '12%',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFFEC4899),
    },
    {
      'title': 'Trending with shoppers',
      'store': 'Flipkart',
      'rate': 'Up to 8%',
      'icon': Icons.local_fire_department_rounded,
      'color': AppColors.warning,
    },
    {
      'title': 'Travel pick',
      'store': 'MakeMyTrip',
      'rate': '9%',
      'icon': Icons.flight_takeoff_rounded,
      'color': AppColors.info,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LoginDemoBackground(
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildTopbar()),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildDiscoveryHero(),
                        const SizedBox(height: 12),
                        _buildSearchBar(),
                        const SizedBox(height: 16),
                        _buildCategoryStrip(),
                        const SizedBox(height: 16),
                        _buildFeaturedOffers(),
                        const SizedBox(height: 16),
                        _buildPopularStores(),
                        const SizedBox(height: 16),
                        _buildRecommendedDeals(),
                        const SizedBox(height: 16),
                        _buildHowItWorks(),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isDrawerOpen) _buildDrawerOverlay(),
        ],
      ),
    );
  }

  Widget _buildDrawerOverlay() {
    return Positioned.fill(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: _isDrawerOpen ? 1 : 0,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _closeDrawer,
          child: Container(
            color: Colors.black.withValues(alpha: 0.32),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                tween: Tween(begin: -24, end: 0),
                builder: (context, offset, child) {
                  return Transform.translate(
                    offset: Offset(offset, 0),
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.80,
                    constraints: const BoxConstraints(maxWidth: 320),
                    height: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(26),
                        bottomRight: Radius.circular(26),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withValues(alpha: 0.22),
                          blurRadius: 28,
                          offset: const Offset(10, 0),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 14, 0),
                        child: Column(
                          children: [
                            Row(
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
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    color: AppColors.textDark,
                                  ),
                                  onPressed: _closeDrawer,
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            _buildDrawerProfileRow(),
                            const SizedBox(height: 22),
                            _buildDrawerMenuList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerProfileRow() {
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
            child: _ProfileImageOrInitials(
              initials: _profileInitials,
              imageUrl: _profileImageUrl,
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
                  _profileName,
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
                  _profileEmail.isEmpty ? 'No email found' : _profileEmail,
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
                        _isProfileVerified
                            ? Icons.verified_rounded
                            : Icons.shield_outlined,
                        color: AppColors.primary,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _isProfileVerified ? 'Verified' : 'Active',
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
  }

  Widget _buildDrawerMenuList() {
    final items = [
      _DrawerMenuItemData(
        label: 'Dashboard',
        icon: Icons.dashboard_outlined,
        isActive: _selectedDrawerItem == 'Dashboard',
        onTap: () => _selectDrawerItem('Dashboard'),
      ),
      _DrawerMenuItemData(
        label: 'Stores',
        icon: Icons.storefront_outlined,
        isActive: _selectedDrawerItem == 'Stores',
        onTap: () => _selectDrawerItem('Stores'),
      ),
      _DrawerMenuItemData(
        label: 'Offers',
        icon: Icons.local_offer_outlined,
        isActive: _selectedDrawerItem == 'Offers',
        onTap: () => _selectDrawerItem('Offers'),
      ),
      _DrawerMenuItemData(
        label: 'Categories',
        icon: Icons.grid_view_rounded,
        isActive: _selectedDrawerItem == 'Categories',
        onTap: () => _selectDrawerItem('Categories'),
      ),
      _DrawerMenuItemData(
        label: 'Withdraw',
        icon: Icons.account_balance_wallet_outlined,
        isActive: _selectedDrawerItem == 'Withdraw',
        onTap: () => _selectDrawerItem('Withdraw'),
      ),
      _DrawerMenuItemData(
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        isActive: _selectedDrawerItem == 'Profile',
        onTap: () => _selectDrawerItem('Profile', openProfile: true),
      ),
    ];

    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _DrawerMenuRow(item: item),
            ),
          )
          .toList(),
    );
  }

  void _openDrawer() {
    setState(() {
      _isDrawerOpen = true;
    });
  }

  void _closeDrawer() {
    setState(() {
      _isDrawerOpen = false;
    });
  }

  Future<void> _selectDrawerItem(
    String label, {
    bool openProfile = false,
  }) async {
    setState(() {
      _selectedDrawerItem = label;
    });

    if (!openProfile) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 160));

    if (!mounted) return;

    _openProfileFromDrawer();
  }

  void _openProfileFromDrawer() {
    _closeDrawer();

    Navigator.pushNamed(context, RouteNames.profile).then((_) {
      _loadProfileSummary();
    });
  }

  Widget _buildTopbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 20, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 390;

          return Row(
            children: [
              _buildMenuButton(),
              const SizedBox(width: 8),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [AppColors.cardShadow],
                ),
                clipBehavior: Clip.antiAlias,
                child: Transform.scale(
                  scale: 1.16,
                  child: Image.asset(
                    'assets/images/smartmoney_mark.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isCompact ? 154 : 190,
                    ),
                    child: Image.asset(
                      'assets/images/smartmoney_wordmark.png',
                      height: isCompact ? 24 : 27,
                      fit: BoxFit.contain,
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ),
              ),
              if (!isCompact) ...[
                // _buildTopbarIcon(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
              ],
              _buildProfileSection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMenuButton() {
    return SizedBox(
      width: 42,
      height: 42,
      child: IconButton(
        tooltip: 'Open menu',
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        splashRadius: 22,
        icon: const _ModernMenuIcon(),
        onPressed: _openDrawer,
      ),
    );
  }

  // Widget _buildTopbarIcon(IconData icon) {
  //   return Container(
  //     width: 42,
  //     height: 42,
  //     decoration: BoxDecoration(
  //       color: Colors.white.withValues(alpha: 0.70),
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
  //     ),
  //     child: Icon(icon, color: AppColors.textMid),
  //   );
  // }

  Widget _buildProfileSection() {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, RouteNames.profile).then((_) {
          _loadProfileSummary();
        });
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.68)),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProfileImageOrInitials(
              initials: _profileInitials,
              imageUrl: _profileImageUrl,
              size: 34,
              fontSize: 12,
            ),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSoft,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  void _showDashboardMessage(String label) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$label will be available soon')));
  }

  Widget _buildDiscoveryHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Top cashback today',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Earn up to 12% cashback',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 26,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Myntra fashion deals are live. Shop through SmartMoney to earn rewards.',
                      style: TextStyle(
                        color: AppColors.textMid,
                        fontSize: 13,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [AppColors.buttonShadow],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showDashboardMessage('Store browsing'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.explore_outlined, size: 18),
              label: const Text(
                'View Top Offers',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _showDashboardMessage('Store search'),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.inputFill.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.inputBorder),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textSoft),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Search stores, brands, offers',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.textSoft,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryStrip() {
    return SizedBox(
      height: 74,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final color = category['color']! as Color;

          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => _showDashboardMessage(category['label']! as String),
            child: Container(
              width: 118,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.76),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
                boxShadow: [AppColors.cardShadow],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      category['icon']! as IconData,
                      color: color,
                      size: 19,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      category['label']! as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Featured Offers',
          subtitle: 'High-value deals to start earning',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _featuredOffers.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final offer = _featuredOffers[index];

              return _FeaturedOfferCard(
                brand: offer['brand']! as String,
                title: offer['title']! as String,
                rate: offer['rate']! as String,
                badge: offer['badge']! as String,
                icon: offer['icon']! as IconData,
                color: offer['color']! as Color,
                logoPath: offer['logoPath'] as String?,
                themeColor: offer['themeColor'] as Color?,
                onTap: () =>
                    _showDashboardMessage('${offer['brand']! as String} offer'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPopularStores() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Popular Stores',
            subtitle: 'Browse brands with active cashback',
            showArrow: false,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 560;
              final itemWidth = isWide
                  ? (constraints.maxWidth - 12) / 2
                  : constraints.maxWidth;

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _stores.map((store) {
                  return SizedBox(
                    width: itemWidth,
                    child: _StoreCard(
                      name: store['name']! as String,
                      code: store['code']! as String,
                      category: store['category']! as String,
                      rate: store['rate']! as String,
                      color: store['color']! as Color,
                      logoPath: store['logoPath'] as String?,
                      onTap: () => _showDashboardMessage(
                        '${store['name']! as String} store',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedDeals() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Recommended Deals',
            subtitle: 'Useful picks for today',
            showArrow: false,
          ),
          const SizedBox(height: 14),
          ..._recommendations.map((deal) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _RecommendationRow(
                title: deal['title']! as String,
                store: deal['store']! as String,
                rate: deal['rate']! as String,
                icon: deal['icon']! as IconData,
                color: deal['color']! as Color,
                onTap: () => _showDashboardMessage(deal['store']! as String),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'How Cashback Works',
            subtitle: 'Three simple steps before every purchase',
            showArrow: false,
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(
                child: _StepTile(
                  number: '1',
                  title: 'Choose',
                  icon: Icons.storefront_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StepTile(
                  number: '2',
                  title: 'Shop',
                  icon: Icons.shopping_cart_outlined,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StepTile(
                  number: '3',
                  title: 'Earn',
                  icon: Icons.savings_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    bool showArrow = true,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSoft, fontSize: 12),
              ),
            ],
          ),
        ),
        if (showArrow)
          const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
      ],
    );
  }
}

class _FeaturedOfferCard extends StatelessWidget {
  const _FeaturedOfferCard({
    required this.brand,
    required this.title,
    required this.rate,
    required this.badge,
    required this.icon,
    required this.color,
    this.logoPath,
    this.themeColor,
    required this.onTap,
  });

  final String brand;
  final String title;
  final String rate;
  final String badge;
  final IconData icon;
  final Color color;
  final String? logoPath;
  final Color? themeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isThemed = themeColor != null;
    final foregroundColor = isThemed ? Colors.white : AppColors.textDark;
    final subtitleColor = isThemed
        ? Colors.white.withValues(alpha: 0.78)
        : AppColors.textMid;
    final rateColor = isThemed ? Colors.white : color;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 238,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: themeColor ?? Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isThemed
                ? Colors.white.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.72),
          ),
          boxShadow: isThemed
              ? [AppColors.buttonShadow]
              : [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 35,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: logoPath == null
                        ? color.withValues(alpha: 0.12)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: logoPath == null
                      ? Icon(icon, color: color, size: 22)
                      : Padding(
                          padding: const EdgeInsets.all(5),
                          child: Image.asset(logoPath!, fit: BoxFit.contain),
                        ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isThemed
                        ? Colors.white.withValues(alpha: 0.18)
                        : color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: isThemed ? Colors.white : color,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foregroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subtitleColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$rate cashback',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: rateColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isThemed ? Colors.white : AppColors.textDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Shop',
                    style: TextStyle(
                      color: isThemed ? themeColor : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.name,
    required this.code,
    required this.category,
    required this.rate,
    required this.color,
    this.logoPath,
    required this.onTap,
  });

  final String name;
  final String code;
  final String category;
  final String rate;
  final Color color;
  final String? logoPath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.inputFill.withValues(alpha: 0.58),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.inputBorder.withValues(alpha: 0.70),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: logoPath == null
                    ? color.withValues(alpha: 0.12)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoPath == null
                  ? Text(
                      code,
                      style: TextStyle(
                        color: color,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset(logoPath!, fit: BoxFit.contain),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSoft,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  rate,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textSoft,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationRow extends StatelessWidget {
  const _RecommendationRow({
    required this.title,
    required this.store,
    required this.rate,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String store;
  final String rate;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    store,
                    style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              rate,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({
    required this.number,
    required this.title,
    required this.icon,
  });

  final String number;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: AppColors.primary, size: 25),
              Positioned(
                right: -10,
                top: -10,
                child: Container(
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItemData {
  const _DrawerMenuItemData({
    required this.label,
    required this.icon,
    this.isActive = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback? onTap;
}

class _ProfileImageOrInitials extends StatelessWidget {
  const _ProfileImageOrInitials({
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
                return _ProfileInitialsLabel(
                  initials: initials,
                  fontSize: fontSize,
                );
              },
            )
          : _ProfileInitialsLabel(initials: initials, fontSize: fontSize),
    );
  }
}

class _ProfileInitialsLabel extends StatelessWidget {
  const _ProfileInitialsLabel({
    required this.initials,
    required this.fontSize,
  });

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

class _DrawerMenuRow extends StatelessWidget {
  const _DrawerMenuRow({required this.item});

  final _DrawerMenuItemData item;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = item.isActive
        ? AppColors.primary
        : AppColors.textMid;
    final backgroundColor = item.isActive
        ? AppColors.primary.withValues(alpha: 0.12)
        : Colors.white.withValues(alpha: 0.34);
    final iconBackgroundColor = item.isActive
        ? AppColors.primary.withValues(alpha: 0.16)
        : Colors.white.withValues(alpha: 0.70);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: item.onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.only(left: 8, right: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.isActive
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.white.withValues(alpha: 0.44),
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 4,
              height: item.isActive ? 24 : 0,
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
              child: Icon(item.icon, color: foregroundColor, size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: item.isActive ? AppColors.textDark : AppColors.textMid,
                  fontSize: 14,
                  fontWeight: item.isActive ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: foregroundColor.withValues(
                alpha: item.isActive ? 0.75 : 0.45,
              ),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModernMenuIcon extends StatelessWidget {
  const _ModernMenuIcon();

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
