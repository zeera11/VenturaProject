import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/colors.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      // Efek Blur Background
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // 1. Kartu Paling Belakang (Biru) - Miring
            Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF61C4DB),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            // 2. Kartu Tengah (Kuning/Peach) - Miring ke arah lain
            Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEDF98),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            // 3. Kartu Utama (Putih)
            Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(
                    "Log out from\nVentura?",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Chango',
                      fontSize: 22,
                      color: AppColors.deepOcean,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 25),
                  // Tombol Log Out Merah
                  GestureDetector(
                    onTap: () {
                      // Logic Logout di sini (misal balik ke splash)
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCA3537),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          "LOG OUT",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Tombol Cancel
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC83636),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 4. Logo Maskot di Paling Atas
            Positioned(
              top: 0,
              child: Container(
                height: 100,
                width: 100,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Image.asset('assets/images/logo.png'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
