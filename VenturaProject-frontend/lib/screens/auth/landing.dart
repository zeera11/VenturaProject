import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'signup.dart'; // Import halaman Register
import 'login.dart'; // Import halaman Login

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil ukuran layar untuk kalkulasi posisi
    final double screenHeight = MediaQuery.of(context).size.height;

    // Tinggi area biru atas (Header)
    final double headerHeight = screenHeight * 0.35;
    // Setengah dari tinggi logo agar duduk di puncak (asumsi logo h=270, jadi 135)
    final double logoOffset = 135;

    return Scaffold(
      // Warna dasar bawah adalah krem sesuai gambar
      backgroundColor: AppColors.clouds,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- BAGIAN HEADER: BIRU DENGAN OVAL & LOGO ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Container Biru Atas
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(250, 100), // Lengkungan landai
                    ),
                  ),
                ),
                // 2. Logo Maskot (Duduk tepat di tengah garis puncak)
                Positioned(
                  top: headerHeight - logoOffset,
                  child: Image.asset(
                    'assets/images/logo.png', // Sesuaikan nama asset maskotmu
                    height: 270,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // --- BAGIAN KONTEN BAWAH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  const SizedBox(
                    height: 150,
                  ), // Spasi agar teks tidak menabrak logo
                  // Teks Ventura
                  const Text(
                    'ventura',
                    style: TextStyle(
                      fontFamily: 'Chango',
                      fontSize: 54,
                      color: AppColors.deepOcean,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),

                  // Gunakan SizedBox besar untuk mendorong tombol ke bawah seperti di gambar
                  SizedBox(height: screenHeight * 0.2),

                  // TOMBOL START NOW (Navigasi ke Sign Up)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Start Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // FOOTER: Teks Log In (Navigasi ke Login)
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.black,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Log In",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: AppColors.deepOcean,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 50), // Padding bawah
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
