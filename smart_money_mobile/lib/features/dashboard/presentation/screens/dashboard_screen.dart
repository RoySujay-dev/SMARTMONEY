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

  final List<Map<String, Object>> _featuredOffers = const [
    {
      'brand': 'Flipkart',
      'title': 'Big Save Days',
      'rate': 'Up to 8%',
      'badge': 'Hot',
      'icon': Icons.shopping_bag_outlined,
      'color': AppColors.primary,
    },
    {
      'brand': 'Myntra',
      'title': 'Fashion weekend',
      'rate': '12%',
      'badge': 'Best rate',
      'icon': Icons.checkroom_outlined,
      'color': Color(0xFFEC4899),
    },
    {
      'brand': 'Swiggy',
      'title': 'Food orders',
      'rate': '5%',
      'badge': 'Popular',
      'icon': Icons.restaurant_outlined,
      'color': AppColors.warning,
    },
  ];

  final List<Map<String, Object>> _stores = const [
    {
      'name': 'Flipkart',
      'code': 'FK',
      'category': 'Electronics',
      'rate': 'Up to 8%',
      'color': AppColors.primary,
    },
    {
      'name': 'Amazon',
      'code': 'AZ',
      'category': 'Marketplace',
      'rate': '6.5%',
      'color': AppColors.info,
    },
    {
      'name': 'Myntra',
      'code': 'MN',
      'category': 'Fashion',
      'rate': '12%',
      'color': Color(0xFFEC4899),
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
      body: LoginDemoBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopbar()),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildDiscoveryHero(),
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
    );
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
    return const SizedBox(
      width: 42,
      height: 42,
      child: Icon(Icons.menu_rounded, color: AppColors.textDark, size: 23),
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
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                _profileInitials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
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
                        'Cashback shopping',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    const Text(
                      'Find stores. Shop smarter. Earn cashback.',
                      style: TextStyle(
                        color: AppColors.textDark,
                        fontSize: 26,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Compare cashback rates before you shop through SmartMoney.',
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
          const SizedBox(height: 20),
          InkWell(
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
                'Explore Stores',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
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
    required this.onTap,
  });

  final String brand;
  final String title;
  final String rate;
  final String badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 238,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
          boxShadow: [AppColors.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: color,
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
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textMid,
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
                      color: color,
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
                    color: AppColors.textDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Shop',
                    style: TextStyle(
                      color: Colors.white,
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
    required this.onTap,
  });

  final String name;
  final String code;
  final String category;
  final String rate;
  final Color color;
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
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
