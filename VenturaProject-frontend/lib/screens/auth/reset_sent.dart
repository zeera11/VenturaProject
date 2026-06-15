import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import 'login.dart';

class ResetSentScreen extends StatelessWidget {
  final String email;
  const ResetSentScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ikon centang animasi
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  size: 60,
                  color: AppColors.deepOcean,
                ),
              ),

              const SizedBox(height: 40),

              const Text(
                'Check Your\nEmail!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Chango',
                  fontSize: 40,
                  color: AppColors.deepOcean,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "We've sent a password reset link to",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.deepOcean.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppColors.deepOcean,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Please check your inbox and follow the link to reset your password.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: AppColors.deepOcean.withOpacity(0.6),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              // Tombol kembali ke login
              GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (c) => const LoginScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Back to Login',
                      style: TextStyle(
                        fontFamily: 'Chango',
                        fontSize: 20,
                        color: AppColors.deepOcean,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Link kirim ulang
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: AppColors.deepOcean,
                    ),
                    children: [
                      TextSpan(
                        text: "Didn't receive it? ",
                        style: TextStyle(
                          color: AppColors.deepOcean.withOpacity(0.6),
                        ),
                      ),
                      const TextSpan(
                        text: 'Resend',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
