import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'home.dart';
import 'explore.dart';
import 'profile.dart';
import 'filter.dart';
import 'plan.dart';
import 'tracker.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const PlanScreen(),
    const ExpenseTrackerScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clouds,
      // KUNCI: Agar Navbar dan FAB tidak melompat ke atas saat keyboard muncul
      resizeToAvoidBottomInset: false,

      body: IndexedStack(index: _currentIndex, children: _pages),

      // TOMBOL PLUS TENGAH
      floatingActionButton: GestureDetector(
        onTap: () async {
          // Membuka Filter dan menunggu hasil (await)
          final bool? isGenerated = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FilterScreen()),
          );

          // Jika isGenerated bernilai true, pindah ke tab Plan (index 1)
          if (isGenerated == true) {
            setState(() {
              _currentIndex = 1; // Index 1 adalah PlanScreen
            });
          }
        },
        child: Container(
          height: 70,
          width: 70,
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 35),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        height: 75,
        notchMargin: 12,
        color: Colors.white,
        elevation: 10,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, "Home"),
            _buildNavItem(1, "Plan"),
            const SizedBox(width: 40), // Ruang FAB
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

    // Logika perubahan icon Aktif (Filled) vs Tidak Aktif (Stroke)
    if (index == 0) {
      iconAsset = isActive ? 'home.png' : 'home(2).png';
    } else if (index == 1) {
      iconAsset = isActive ? 'compass-icon.png' : 'compass.png';
    } else if (index == 2) {
      iconAsset = isActive ? 'wallet.png' : 'wallet (1).png';
    } else if (index == 3) {
      iconAsset = isActive ? 'user (1).png' : 'user (2).png';
    }

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/$iconAsset',
            width: 22,
            height: 22,
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
