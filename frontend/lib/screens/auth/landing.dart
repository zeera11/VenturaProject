import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../main_navigation.dart';
import 'signup.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Warna dasar bawah (Krem #FCFAEB)
      backgroundColor: AppColors.clouds,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER: AREA BIRU DENGAN OVAL & LOGO ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Container Biru (#ABE1E1) dengan lengkungan bawah
                Container(
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.brandBlue,
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(250, 80), // Lengkungan landai
                    ),
                  ),
                ),
                // 2. Logo Maskot (Ukuran 320, duduk tepat di tengah garis puncak)
                Positioned(
                  top:
                      MediaQuery.of(context).size.height * 0.28 -
                      160, // Setengah dari tinggi logo (320/2)
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 320,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // --- KONTEN BAWAH ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  const SizedBox(
                    height: 180,
                  ), // Spasi agar teks tidak menabrak logo
                  // Teks Judul
                  const Text(
                    'ventura',
                    style: TextStyle(
                      fontFamily: 'Chango',
                      fontSize: 54,
                      color: AppColors.deepOcean,
                      letterSpacing: -2.0,
                      height: 1.0,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Tombol-tombol Sosial
                  _buildSocialBtn(
                    context,
                    'Continue with Google',
                    'google.png',
                  ),
                  const SizedBox(height: 14),
                  _buildSocialBtn(context, 'Continue with Apple', 'apple.png'),
                  const SizedBox(height: 14),
                  _buildSocialBtn(context, 'Continue with Phone', 'phone.png'),

                  const SizedBox(height: 50),

                  // Footer: Link Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Didn't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const SignupScreen(),
                          ),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepOcean,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk Button Sosial
  Widget _buildSocialBtn(BuildContext context, String text, String iconName) {
    return GestureDetector(
      onTap: () => Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (c) => const MainNavigation()),
        (route) => false,
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Image.asset('assets/images/$iconName', width: 22),
              Expanded(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 22), // Penyeimbang posisi teks agar tengah
            ],
          ),
        ),
      ),
    );
  }
}
