import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedNavigationIndex = 0;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = const [
    'Trending Now',
    'Fashion',
    'Electronics',
    'Travel',
    'Food',
    'More',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF3ECFF),
                    Color(0xFFF3ECFF),
                    Color(0xFFF1FBF5),
                    Color(0xFFF1FBF5),
                  ],
                  stops: [0.0, 0.25, 0.50, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildCashbackOverview(),
                        const SizedBox(height: 20),
                        _buildBonusBoosters(),
                        const SizedBox(height: 20),
                        _buildCategoryTabs(),
                        const SizedBox(height: 18),
                        _buildOfferGrid(),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildCashbackOverview() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cashback Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111833),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _buildCashbackItem(
                    label: 'Available',
                    amount: '\$11.45',
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF7137F0),
                    iconBackground: const Color(0xFFF0E8FF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCashbackItem(
                    label: 'Pending',
                    amount: '\$24.30',
                    icon: Icons.pie_chart_outline_rounded,
                    iconColor: const Color(0xFFFF7A00),
                    iconBackground: const Color(0xFFFFF0E2),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildCashbackItem(
                    label: 'Lifetime',
                    amount: '\$331.02',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF35B84B),
                    iconBackground: const Color(0xFFE9F9E9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 26),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;

          return InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _categories[index],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF111833)
                        : const Color(0xFF747A8B),
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isSelected ? 54 : 0,
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111833),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBonusBoosters() {
    final boosters = <Map<String, Object>>[
      {'name': 'Flipkart', 'cashback': '7%', 'color': const Color(0xFFFFE46B)},
      {'name': 'Myntra', 'cashback': '8%', 'color': const Color(0xFFFFE5F0)},
      {'name': 'AJIO', 'cashback': '5%', 'color': const Color(0xFFE9F3FF)},
      {'name': 'cult.fit', 'cashback': '4%', 'color': const Color(0xFFEAF9EE)},
      {'name': 'Nykaa', 'cashback': '8%', 'color': const Color(0xFFFFE5EC)},
      {'name': 'Tata 1mg', 'cashback': '6%', 'color': const Color(0xFFFFE5D5)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Bonus Boosters',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111833),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Cashback boost up every 7 days',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Color(0xFF747A8B)),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF6334D8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 104,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: boosters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final booster = boosters[index];

                  return _buildBoosterItem(
                    name: booster['name']! as String,
                    cashback: booster['cashback']! as String,
                    backgroundColor: booster['color']! as Color,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoosterItem({
    required String name,
    required String cashback,
    required Color backgroundColor,
  }) {
    return SizedBox(
      width: 68,
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFB24A), width: 1.5),
            ),
            child: Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF172033),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFA72F)),
            ),
            child: Text(
              cashback,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF8B4B00),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferGrid() {
    final offers = <Map<String, Object>>[
      {
        'brand': 'Amazon',
        'cashback': 'Up to 6% Cashback',
        'description': 'Shopping, electronics and more',
        'background': const Color(0xFFFFF2D8),
        'accent': const Color(0xFFFFA928),
      },
      {
        'brand': 'Myntra',
        'cashback': 'Up to 8% Cashback',
        'description': 'Top fashion and lifestyle brands',
        'background': const Color(0xFFFFE9F1),
        'accent': const Color(0xFFE93B78),
      },
      {
        'brand': 'MakeMyTrip',
        'cashback': 'Up to 7% Cashback',
        'description': 'Flights, hotels and holiday bookings',
        'background': const Color(0xFFE9F2FF),
        'accent': const Color(0xFF3978E8),
      },
      {
        'brand': 'Swiggy',
        'cashback': 'Up to 5% Cashback',
        'description': 'Food delivery and dining offers',
        'background': const Color(0xFFFFEEE2),
        'accent': const Color(0xFFF57C24),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: offers.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 0.76,
        ),
        itemBuilder: (context, index) {
          final offer = offers[index];

          return _buildOfferCard(
            brand: offer['brand']! as String,
            cashback: offer['cashback']! as String,
            description: offer['description']! as String,
            backgroundColor: offer['background']! as Color,
            accentColor: offer['accent']! as Color,
          );
        },
      ),
    );
  }

  Widget _buildOfferCard({
    required String brand,
    required String cashback,
    required String description,
    required Color backgroundColor,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: backgroundColor,
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 74,
                        height: 74,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x12000000),
                              blurRadius: 12,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Text(
                          brand.substring(0, 1),
                          style: TextStyle(
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.favorite_border_rounded,
                        size: 23,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111833),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cashback,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF747A8B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6334D8),
                        side: const BorderSide(color: Color(0xFFDDD1FA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Shop Now',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashbackItem({
    required String label,
    required String amount,
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE8E9EF)),
      ),
      child: Column(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF555B6D),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111833),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4ECFF), Color(0xFFF5F6FF), Color(0xFFF8F4FF)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(34)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hi Tushar 👋',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111833),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Total saving \$331.02',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: Color(0xFF31384E),
            ),
          ),
          const SizedBox(height: 26),
          Container(
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x11000000),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search from over 500 top brands',
                hintStyle: TextStyle(fontSize: 16, color: Color(0xFF7A8091)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 29,
                  color: Color(0xFF707789),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedNavigationIndex,
        onTap: (index) {
          setState(() {
            _selectedNavigationIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF141A3A),
        unselectedItemColor: const Color(0xFF747A8B),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
