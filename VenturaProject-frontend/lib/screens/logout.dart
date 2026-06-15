import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import '../services/api_service.dart';
import 'auth/landing.dart';

class LogoutPopup extends StatelessWidget {
  const LogoutPopup({super.key});

  @override
  Widget build(BuildContext context) {
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
                      await ApiService.clearToken();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.remove('profile_name');
                      await prefs.remove('profile_email');
                      await prefs.remove('profile_phone');
                      await prefs.remove('profile_picture');
                      
                      await prefs.remove('user_budget');
                      await prefs.remove('local_expenses');
                      await prefs.remove('saved_plans');
                      await prefs.remove('favorite_places');

                      if (!context.mounted) return;
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You have successfully logged out"),
                          backgroundColor: Colors.green,
                        ),
                      );

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (c) => const LandingScreen()),
                        (route) => false,
                      );
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
