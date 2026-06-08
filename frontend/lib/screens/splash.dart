import 'package:flutter/material.dart';
import '../utils/colors.dart'; // Import color tokens
import 'auth/landing.dart'; // Import tujuan navigasi terakhir

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data Konten Onboarding (Splash 11 & Splash 22)
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "WHERE YOUR NEXT STORY BEGINS",
      "subtitle":
          "Built to help you discover Indonesia with better vibes and less stress",
      "image": "assets/images/Splash1.png",
    },
    {
      "title": "PLAN LESS. FEEL MORE",
      "subtitle": "Your next unforgettable Indonesia trip starts right here ✨",
      "image": "assets/images/Splash2.png",
    },
  ];

  void _handleNavigation() {
    if (_currentPage < _onboardingData.length - 1) {
      // Pindah ke Splash 22
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    } else {
      // Pindah ke Landing Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LandingScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Background Image PageView
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  _onboardingData[index]['image']!,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          // 2. Gradient Overlay (Agar teks putih/krem selalu terbaca)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.6, 1.0],
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),
          ),

          // 3. UI Content (Text, Indicators, & Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- INDIKATOR TITIK (DI TENGAH) ---
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 10,
                            width: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? AppColors.clouds
                                  : Colors.transparent,
                              border: Border.all(
                                color: AppColors.clouds,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- JUDUL (Pakai FittedBox agar satu baris) ---
                    SizedBox(
                      width: double.infinity,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _onboardingData[_currentPage]['title']!,
                          style: const TextStyle(
                            fontFamily: 'Chango', // Pastikan sudah di pubspec
                            fontSize: 28,
                            color: AppColors.clouds, // Pakai Color Token
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // --- SUBTITLE & TOMBOL LANJUT ---
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            _onboardingData[_currentPage]['subtitle']!,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.clouds,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),

                        // Tombol Navigasi
                        GestureDetector(
                          onTap: _handleNavigation,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.clouds,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/Arrow.png',
                              width: 24,
                              height: 24,
                              color:
                                  AppColors.deepOcean, // Icon warna navy gelap
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
