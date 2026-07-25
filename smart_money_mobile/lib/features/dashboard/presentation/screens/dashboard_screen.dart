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
  String _profileName = 'Profile';
  String _profileInitials = 'SM';

  final List<Map<String, Object>> _stats = const [
    {
      'label': 'Available',
      'value': 'Rs 3,450',
      'icon': Icons.account_balance_wallet_outlined,
      'color': AppColors.primary,
      'background': Color(0x1F6366F1),
    },
    {
      'label': 'Pending',
      'value': 'Rs 780',
      'icon': Icons.schedule_rounded,
      'color': AppColors.warning,
      'background': Color(0x1FF59E0B),
    },
    {
      'label': 'Lifetime',
      'value': 'Rs 12,840',
      'icon': Icons.trending_up_rounded,
      'color': AppColors.success,
      'background': Color(0x1F10B981),
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
        _profileName = profile.fullName.isEmpty
            ? 'Profile'
            : profile.fullName.split(RegExp(r'\s+')).first;
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

  final List<Map<String, String>> _offers = const [
    {'brand': 'Flipkart Sale', 'rate': 'Up to 8%'},
    {'brand': 'Amazon Great Deal', 'rate': '6.5%'},
    {'brand': 'Myntra Fashion', 'rate': '12%'},
    {'brand': 'Swiggy Eats', 'rate': '5%'},
    {'brand': 'MakeMyTrip', 'rate': '9%'},
  ];

  final List<Map<String, Object>> _stores = const [
    {'name': 'Flipkart', 'code': 'FK', 'amount': 'Rs 920', 'progress': 0.85},
    {'name': 'Amazon', 'code': 'AZ', 'amount': 'Rs 740', 'progress': 0.65},
    {'name': 'Myntra', 'code': 'MN', 'amount': 'Rs 540', 'progress': 0.50},
    {'name': 'Ajio', 'code': 'AJ', 'amount': 'Rs 320', 'progress': 0.32},
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
                    _buildWalletBanner(),
                    const SizedBox(height: 16),
                    _buildOfferStrip(),
                    const SizedBox(height: 16),
                    _buildStatsGrid(),
                    const SizedBox(height: 16),
                    _buildCashbackOverview(),
                    const SizedBox(height: 16),
                    _buildTopStores(),
                    const SizedBox(height: 16),
                    _buildWithdrawCard(),
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 390;

          return Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                  boxShadow: [AppColors.cardShadow],
                ),
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.all(3),
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
                _buildTopbarIcon(Icons.notifications_none_rounded),
                const SizedBox(width: 10),
              ],
              _buildProfileSection(isCompact: isCompact),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopbarIcon(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
      ),
      child: Icon(icon, color: AppColors.textMid),
    );
  }

  Widget _buildProfileSection({required bool isCompact}) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.pushNamed(context, RouteNames.profile).then((_) {
          _loadProfileSummary();
        });
      },
      child: Container(
        height: 46,
        padding: EdgeInsets.fromLTRB(8, 6, isCompact ? 8 : 10, 6),
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
            if (!isCompact) ...[
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 82),
                child: Text(
                  _profileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 2),
            ],
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

  Widget _buildWalletBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradientExtended,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [AppColors.buttonShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Available Cashback Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '+12.4%',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Rs 3,450.00',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '+ Rs 780 pending confirmation',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.78),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildWalletButton(
                  label: 'Withdraw',
                  icon: Icons.arrow_upward_rounded,
                  isSolid: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWalletButton(
                  label: 'History',
                  icon: Icons.history_rounded,
                  isSolid: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletButton({
    required String label,
    required IconData icon,
    required bool isSolid,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isSolid ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSolid ? AppColors.primary : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isSolid ? AppColors.primary : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferStrip() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _offers.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final offer = _offers[index];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.74),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.70)),
              boxShadow: [AppColors.cardShadow],
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.warning,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  offer['brand']!,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  offer['rate']!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: List.generate(_stats.length, (index) {
        final stat = _stats[index];

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: index == 0 ? 0 : 10),
            child: LoginDemoGlassCard(
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              child: Column(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: stat['background']! as Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      stat['icon']! as IconData,
                      color: stat['color']! as Color,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stat['value']! as String,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stat['label']! as String,
                    style: const TextStyle(
                      color: AppColors.textMid,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCashbackOverview() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Cashback Overview',
            subtitle: 'Monthly earnings across stores',
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 126,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                _Bar(label: 'Jan', value: 0.50),
                _Bar(label: 'Feb', value: 0.33),
                _Bar(label: 'Mar', value: 0.65),
                _Bar(label: 'Apr', value: 0.57),
                _Bar(label: 'May', value: 0.82),
                _Bar(label: 'Jun', value: 1.00, isActive: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStores() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Top Stores',
            subtitle: 'By cashback this month',
          ),
          const SizedBox(height: 16),
          ..._stores.map(_buildStoreItem),
        ],
      ),
    );
  }

  Widget _buildStoreItem(Map<String, Object> store) {
    final progress = store['progress']! as double;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Text(
              store['code']! as String,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  store['name']! as String,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.10),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            store['amount']! as String,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawCard() {
    return LoginDemoGlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            title: 'Withdraw Cashback',
            subtitle: 'Choose your payout method',
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _PayoutOption(icon: Icons.payments_outlined, label: 'UPI'),
              SizedBox(width: 10),
              _PayoutOption(
                icon: Icons.account_balance_outlined,
                label: 'Bank',
              ),
              SizedBox(width: 10),
              _PayoutOption(icon: Icons.card_giftcard_outlined, label: 'Gift'),
            ],
          ),
          const SizedBox(height: 16),
          LoginDemoGradientButton(
            label: 'Withdraw Now',
            icon: Icons.arrow_upward_rounded,
            onPressed: () {},
          ),
          const SizedBox(height: 10),
          const Text(
            'Min. Rs 200. Processed in 2-4 business days.',
            style: TextStyle(color: AppColors.textSoft, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
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
        const Icon(Icons.arrow_forward_rounded, color: AppColors.primary),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.label, required this.value, this.isActive = false});

  final String label;
  final double value;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: value,
                child: Container(
                  width: 16,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? AppColors.primaryGradient
                        : LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withValues(alpha: 0.55),
                              AppColors.primaryEnd.withValues(alpha: 0.20),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.textSoft, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _PayoutOption extends StatelessWidget {
  const _PayoutOption({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
