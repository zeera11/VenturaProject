import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/app_state.dart';
import '../services/secure_storage_service.dart';
import 'auth/login.dart';

class LogoutPopup extends StatelessWidget {
  const LogoutPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final SecureStorageService secureStorage = SecureStorageService();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Transform.rotate(
              angle: 0.1,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.skyBlue,
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Transform.rotate(
              angle: -0.15,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEDF98),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
            Container(
              width: 290,
              height: 290,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
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
                    ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () async {
                      // Clear token and global state
                      await secureStorage.deleteToken();
                      AppState.clear();
                      
                      if (context.mounted) {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (c) => const LoginScreen()),
                          (r) => false,
                        );
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCA3537),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          "LOG OUT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Color(0xFFC83636),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
