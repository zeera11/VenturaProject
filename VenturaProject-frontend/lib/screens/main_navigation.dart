import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'home.dart';
import 'saved_plans.dart';
import 'profile.dart';
import 'tracker.dart';
import 'filter.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    MainNavigation.tabNotifier.value = 0;
    MainNavigation.tabNotifier.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    MainNavigation.tabNotifier.removeListener(_handleTabChange);
    super.dispose();
  }

  void _handleTabChange() {
    if (mounted) {
      setState(() {
        _currentIndex = MainNavigation.tabNotifier.value;
      });
    }
  }

  // Fungsi untuk mengubah tab dari widget anak (misal dari Home)
  void changeTab(int index) {
    MainNavigation.tabNotifier.value = index;
  }

  @override
  Widget build(BuildContext context) {
    // List halaman sekarang menerima fungsi changeTab
    final List<Widget> _pages = [
      HomeScreen(onFundTap: () => changeTab(2)), // Tab 2 adalah Tracker
      const SavedPlansScreen(),
      const ExpenseTrackerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.clouds,
      resizeToAvoidBottomInset: false,
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: GestureDetector(
        onTap: () async {
          final bool? isGenerated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FilterScreen()),
          );
          if (isGenerated == true) changeTab(1); // Pindah ke Plan/Explore
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: 75,
        notchMargin: 12,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, "Home"),
            _buildNavItem(1, "Plan"),
            const SizedBox(width: 40),
            _buildNavItem(2, "Tracker"),
            _buildNavItem(3, "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label) {
    bool isActive = _currentIndex == index;
    String iconAsset = "";
    if (index == 0)
      iconAsset = isActive ? 'home.png' : 'home(2).png';
    else if (index == 1)
      iconAsset = isActive ? 'compass-icon.png' : 'compass.png';
    else if (index == 2)
      iconAsset = isActive ? 'wallet.png' : 'wallet (1).png';
    else if (index == 3)
      iconAsset = isActive ? 'user (1).png' : 'user (2).png';

    return GestureDetector(
      onTap: () => changeTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$iconAsset',
            width: 22,
            color: isActive ? Colors.black : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
