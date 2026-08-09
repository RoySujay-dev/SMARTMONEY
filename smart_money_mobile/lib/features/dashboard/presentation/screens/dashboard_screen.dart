import 'package:flutter/material.dart';

import '../../../../app/routes/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/login_demo_widgets.dart';
import '../../../../core/widgets/network_image_with_fallback.dart';
import '../../../../core/widgets/view_state.dart';
import '../../../browsing/data/models/category.dart';
import '../../../browsing/data/models/offer_list_item.dart';
import '../../../browsing/data/models/store_list_item.dart';
import '../../../browsing/data/services/browsing_api_service.dart';
import '../../../browsing/presentation/widgets/category_circle_tile.dart';
import '../../../browsing/presentation/widgets/promo_carousel.dart';
import '../../../browsing/presentation/widgets/store_card.dart';
import '../../../profile/data/services/profile_api_service.dart';
import '../../../shell/presentation/screens/main_shell.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSelectTab});

  /// Provided by [MainShell] so "see all" actions switch bottom-nav tabs
  /// instead of pushing a duplicate screen on top of the shell.
  final void Function(ShellTab tab)? onSelectTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _profileApiService = ProfileApiService();
  final BrowsingApiService _browsingApiService = BrowsingApiService();

  String _profileInitials = 'SM';
  String _profileName = 'SmartMoney User';
  String _profileEmail = '';
  String _profileImageUrl = '';
  bool _isProfileVerified = false;
  bool _isDrawerOpen = false;
  String _selectedDrawerItem = 'Dashboard';

  // Browsing data (real backend data — no hardcoded brands).
  ViewState _categoriesState = ViewState.initial;
  List<Category> _categories = const [];
  String _categoriesError = '';
  bool _isLoadingCategories = false;

  ViewState _offersState = ViewState.initial;
  List<OfferListItem> _offers = const [];
  String _offersError = '';
  bool _isLoadingOffers = false;

  ViewState _storesState = ViewState.initial;
  List<StoreListItem> _stores = const [];
  String _storesError = '';
  bool _isLoadingStores = false;

  static const int _dashboardItemLimit = 10;

  @override
  void initState() {
    super.initState();
    _loadProfileSummary();
    _loadCategories();
    _loadOffers();
    _loadStores();
  }

  @override
  void dispose() {
    _profileApiService.dispose();
    _browsingApiService.dispose();
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

  Future<void> _loadCategories() async {
    if (_isLoadingCategories) return;
    _isLoadingCategories = true;
    setState(() => _categoriesState = ViewState.loading);

    try {
      final categories = await _browsingApiService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _categoriesState =
            categories.isEmpty ? ViewState.empty : ViewState.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _categoriesError = e.message;
        _categoriesState = ViewState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'Could not load categories.';
        _categoriesState = ViewState.error;
      });
    } finally {
      _isLoadingCategories = false;
    }
  }

  Future<void> _loadOffers() async {
    if (_isLoadingOffers) return;
    _isLoadingOffers = true;
    setState(() => _offersState = ViewState.loading);

    try {
      final offers = await _browsingApiService.getOffers();
      if (!mounted) return;
      setState(() {
        _offers = offers;
        _offersState = offers.isEmpty ? ViewState.empty : ViewState.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _offersError = e.message;
        _offersState = ViewState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offersError = 'Could not load offers.';
        _offersState = ViewState.error;
      });
    } finally {
      _isLoadingOffers = false;
    }
  }

  Future<void> _loadStores() async {
    if (_isLoadingStores) return;
    _isLoadingStores = true;
    setState(() => _storesState = ViewState.loading);

    try {
      final stores = await _browsingApiService.getStores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _storesState = stores.isEmpty ? ViewState.empty : ViewState.success;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _storesError = e.message;
        _storesState = ViewState.error;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _storesError = 'Could not load stores.';
        _storesState = ViewState.error;
      });
    } finally {
      _isLoadingStores = false;
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadProfileSummary(),
      _loadCategories(),
      _loadOffers(),
      _loadStores(),
    ]);
  }

  /// Offers to feature: prioritize `isFeatured`, then fall back to the rest.
  List<OfferListItem> get _featuredOffers {
    final featured = _offers.where((o) => o.isFeatured).toList();
    final ordered = [
      ...featured,
      ..._offers.where((o) => !o.isFeatured),
    ];
    return ordered.take(_dashboardItemLimit).toList();
  }

  /// Stores to surface: prioritize `isFeatured`, then fall back to the rest.
  List<StoreListItem> get _popularStores {
    final featured = _stores.where((s) => s.isFeatured).toList();
    final ordered = [
      ...featured,
      ..._stores.where((s) => !s.isFeatured),
    ];
    return ordered.take(_dashboardItemLimit).toList();
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

  void _openCategories() {
    Navigator.pushNamed(context, RouteNames.categories);
  }

  void _openStores() {
    final selectTab = widget.onSelectTab;
    if (selectTab != null) {
      selectTab(ShellTab.stores);
      return;
    }
    Navigator.pushNamed(context, RouteNames.stores);
  }

  void _openOffers() {
    final selectTab = widget.onSelectTab;
    if (selectTab != null) {
      selectTab(ShellTab.offers);
      return;
    }
    Navigator.pushNamed(context, RouteNames.offers);
  }

  void _openSearch() {
    final selectTab = widget.onSelectTab;
    if (selectTab != null) {
      selectTab(ShellTab.search);
      return;
    }
    Navigator.pushNamed(context, RouteNames.search);
  }

  void _openCategory(Category category) {
    Navigator.pushNamed(
      context,
      RouteNames.categoryStores,
      arguments: category,
    );
  }

  void _openStore(StoreListItem store) {
    Navigator.pushNamed(context, RouteNames.storeDetails, arguments: store.slug);
  }

  void _openOffer(OfferListItem offer) {
    Navigator.pushNamed(context, RouteNames.offerDetails, arguments: offer.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          LoginDemoBackground(
            child: SafeArea(
              child: RefreshIndicator(
                onRefresh: _refreshAll,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildTopbar()),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildSearchBar(),
                          const SizedBox(height: 16),
                          _buildHeroSection(),
                          const SizedBox(height: 18),
                          _buildCategoryStrip(),
                          const SizedBox(height: 16),
                          _buildFeaturedOffersSection(),
                          const SizedBox(height: 16),
                          _buildPopularStoresSection(),
                          const SizedBox(height: 16),
                          _buildHowItWorks(),
                        ]),
                      ),
                    ),
                  ],
                ),
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
        onTap: () => _selectDrawerItem('Stores', destination: _openStores),
      ),
      _DrawerMenuItemData(
        label: 'Offers',
        icon: Icons.local_offer_outlined,
        isActive: _selectedDrawerItem == 'Offers',
        onTap: () => _selectDrawerItem('Offers', destination: _openOffers),
      ),
      _DrawerMenuItemData(
        label: 'Categories',
        icon: Icons.grid_view_rounded,
        isActive: _selectedDrawerItem == 'Categories',
        onTap: () =>
            _selectDrawerItem('Categories', destination: _openCategories),
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
    VoidCallback? destination,
  }) async {
    setState(() {
      _selectedDrawerItem = label;
    });

    if (openProfile) {
      await Future<void>.delayed(const Duration(milliseconds: 160));
      if (!mounted) return;
      _openProfileFromDrawer();
      return;
    }

    if (destination != null) {
      _closeDrawer();
      await Future<void>.delayed(const Duration(milliseconds: 160));
      if (!mounted) return;
      destination();
    }
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

  Widget _buildHeroSection() {
    switch (_offersState) {
      case ViewState.initial:
      case ViewState.loading:
        return const SizedBox(height: 172, child: _SectionLoading());
      case ViewState.error:
        return SizedBox(
          height: 172,
          child: _SectionInlineError(
            message: _offersError,
            onRetry: _loadOffers,
          ),
        );
      case ViewState.empty:
        return _buildWelcomeBanner();
      case ViewState.success:
        return PromoCarousel(
          offers: _featuredOffers,
          onOfferTap: _openOffer,
        );
    }
  }

  /// Shown instead of the carousel when the catalogue has no offers yet.
  Widget _buildWelcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome to SmartMoney',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse stores and start earning cashback on every purchase.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 13,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _openStores,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.storefront_outlined, size: 18),
            label: const Text(
              'Browse Stores',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: _openSearch,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Top Categories',
          subtitle: 'Browse by what you love',
          onTap: _openCategories,
        ),
        const SizedBox(height: 14),
        SizedBox(height: 108, child: _buildCategoryStripBody()),
      ],
    );
  }

  Widget _buildCategoryStripBody() {
    switch (_categoriesState) {
      case ViewState.initial:
      case ViewState.loading:
        return const _SectionLoading();
      case ViewState.error:
        return _SectionInlineError(
          message: _categoriesError,
          onRetry: _loadCategories,
        );
      case ViewState.empty:
        return const _SectionInlineEmpty(message: 'No categories yet');
      case ViewState.success:
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return CategoryCircleTile(
              category: category,
              onTap: () => _openCategory(category),
            );
          },
        );
    }
  }

  Widget _buildFeaturedOffersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: 'Featured Offers',
          subtitle: 'High-value deals to start earning',
          onTap: _openOffers,
        ),
        const SizedBox(height: 12),
        SizedBox(height: 190, child: _buildFeaturedOffersBody()),
      ],
    );
  }

  Widget _buildFeaturedOffersBody() {
    switch (_offersState) {
      case ViewState.initial:
      case ViewState.loading:
        return const _SectionLoading();
      case ViewState.error:
        return _SectionInlineError(
          message: _offersError,
          onRetry: _loadOffers,
        );
      case ViewState.empty:
        return const _SectionInlineEmpty(message: 'No offers yet');
      case ViewState.success:
        final offers = _featuredOffers;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: offers.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final offer = offers[index];
            return _DashboardOfferCard(
              offer: offer,
              onTap: () => _openOffer(offer),
            );
          },
        );
    }
  }

  Widget _buildPopularStoresSection() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      // Blur disabled: this card lives inside the scroll view.
      enableBlur: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Popular Stores',
            subtitle: 'Browse brands with active cashback',
            showArrow: false,
          ),
          const SizedBox(height: 16),
          _buildPopularStoresBody(),
        ],
      ),
    );
  }

  Widget _buildPopularStoresBody() {
    switch (_storesState) {
      case ViewState.initial:
      case ViewState.loading:
        return const SizedBox(height: 90, child: _SectionLoading());
      case ViewState.error:
        return SizedBox(
          height: 90,
          child: _SectionInlineError(
            message: _storesError,
            onRetry: _loadStores,
          ),
        );
      case ViewState.empty:
        return const SizedBox(
          height: 90,
          child: _SectionInlineEmpty(message: 'No stores yet'),
        );
      case ViewState.success:
        final stores = _popularStores;
        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 560;
            final itemWidth = isWide
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: stores.map((store) {
                return SizedBox(
                  width: itemWidth,
                  child: StoreCard(
                    store: store,
                    onTap: () => _openStore(store),
                  ),
                );
              }).toList(),
            );
          },
        );
    }
  }

  Widget _buildHowItWorks() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      // Blur disabled: this card lives inside the scroll view.
      enableBlur: false,
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
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: showArrow ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Row(
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
                  style: const TextStyle(
                    color: AppColors.textSoft,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _DashboardOfferCard extends StatelessWidget {
  const _DashboardOfferCard({required this.offer, required this.onTap});

  final OfferListItem offer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final storeName = offer.storeName.trim();
    final cashback = offer.cashbackText?.trim() ?? '';
    final hasCashback = cashback.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(14),
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
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: NetworkImageWithFallback(
                    url: offer.imageUrl,
                    width: 60,
                    height: 40,
                    fallbackIcon: Icons.local_offer_outlined,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    iconColor: AppColors.primary,
                    iconSize: 20,
                  ),
                ),
                const Spacer(),
                if (offer.isFeatured)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Featured',
                      style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 13),
            if (storeName.isNotEmpty)
              Text(
                storeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                offer.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textMid,
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasCashback ? cashback : 'View offer',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: hasCashback ? AppColors.success : AppColors.primary,
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

class _SectionLoading extends StatelessWidget {
  const _SectionLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SectionInlineError extends StatelessWidget {
  const _SectionInlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.textSoft, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSoft,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _SectionInlineEmpty extends StatelessWidget {
  const _SectionInlineEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textSoft,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
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
