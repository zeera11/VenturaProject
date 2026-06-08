import 'package:flutter/material.dart';
import '../utils/colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clouds, // Krem gading #FCFAEB
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Stack(
                children: [
                  // --- GARIS PENGHUBUNG (Hanging Lines) ---
                  Positioned(
                    top: 50,
                    left: 30,
                    bottom: 50,
                    child: Container(width: 4, color: Colors.black),
                  ),
                  Positioned(
                    top: 50,
                    right: 30,
                    bottom: 50,
                    child: Container(width: 4, color: Colors.black),
                  ),

                  // --- DAFTAR KARTU ---
                  Column(
                    children: [
                      // 1. Our Story (Miring ke Kanan)
                      Transform.rotate(
                        angle: 0.05,
                        child: _buildStoryCard(
                          title: "Our Story",
                          content:
                              "Ventura was created from a simple idea: traveling should feel exciting, not exhausting. Many travelers spend too much time switching between apps just to organize destinations, budgets, routes, and itineraries. Ventura combines planning, budgeting, and discovery into one seamless travel companion.",
                          bgColor: const Color(0xFFE35C5E),
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 2. Our Mission (Lurus)
                      _buildStoryCard(
                        title: "Our Mission",
                        content:
                            "Our mission is to make traveling across Indonesia more accessible, organized, and meaningful through smart technology and personalized experiences. Ventura helps travelers plan trips based on their budget, preferences, and travel style while encouraging them to discover beauty.",
                        bgColor: const Color(0xFFFFDE97),
                        textColor: Colors.black,
                        titleOnLeft: true,
                      ),
                      const SizedBox(height: 40),

                      // 3. Our Vision (Miring ke Kiri)
                      Transform.rotate(
                        angle: -0.05,
                        child: _buildStoryCard(
                          title: "Our Vision",
                          content:
                              "We envision Ventura becoming a trusted digital travel companion that inspires more people to explore Indonesia confidently and effortlessly. By blending smart planning tools with immersive travel experiences, Ventura aims to redefine modern travel.",
                          bgColor: const Color(0xFFF78C64),
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header melengkung biru dengan maskot
  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      clipBehavior: Clip.none,
      children: [
        // Background Biru Atas
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(250, 50),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // Tombol Back
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.deepOcean,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              // Maskot Logo Ventura
              Container(
                height: 130,
                width: 130,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "ventura",
                style: TextStyle(
                  fontFamily: 'Chango',
                  fontSize: 36,
                  color: AppColors.deepOcean,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Pembuat Kartu Konten
  Widget _buildStoryCard({
    required String title,
    required String content,
    required Color bgColor,
    required Color textColor,
    bool titleOnLeft = false,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Label Judul di Pojok Atas
          Positioned(
            top: 0,
            right: titleOnLeft ? null : 20,
            left: titleOnLeft ? 20 : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: textColor,
                ),
              ),
            ),
          ),
          // Isi Teks Deskripsi
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 30),
            child: Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: textColor,
                height: 1.6,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
