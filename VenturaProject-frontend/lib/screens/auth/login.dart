import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../main_navigation.dart';
import 'signup.dart';
import 'forgot_password.dart';
import '../../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    // Tinggi area krem atas (Header)
    final double headerHeight = screenHeight * 0.3;
    // Setengah tinggi logo agar pas di tengah garis (Logo h=270, offset=135)
    final double logoOffset = 135;

    return Scaffold(
      backgroundColor: AppColors.brandBlue, // Dasar bawah biru #ABE1E1
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER: KREM DENGAN OVAL BAWAH & LOGO ---
            Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: headerHeight,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.clouds, // Krem #FCFAEB
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(250, 80),
                    ),
                  ),
                ),
                Positioned(
                  top: headerHeight - logoOffset,
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 270,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            // --- KONTEN FORM ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 140), // Jarak agar tidak tertutup logo

                  const Text(
                    'Hello',
                    style: TextStyle(
                      fontFamily: 'Chango',
                      fontSize: 56,
                      color: AppColors.deepOcean,
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    "We're glad you came back!",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.deepOcean,
                    ),
                  ),

                  const SizedBox(height: 40),

                  _buildInput('Enter Email', _emailController),
                  const SizedBox(height: 15),
                  _buildInput('Password', _passwordController, isPass: true),

                  const SizedBox(height: 12),

                  // TOMBOL FORGOT PASSWORD
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => const ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            color: AppColors.deepOcean,
                          ),
                          children: [
                            TextSpan(text: 'Forgot your password? '),
                            TextSpan(
                              text: 'Click here',
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // TOMBOL LOGIN
                  _buildLoginBtn(context),

                  const SizedBox(height: 35),

                  // FOOTER
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (c) => const SignupScreen()),
                      ),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: AppColors.deepOcean,
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(text: "Not a member? "),
                            TextSpan(
                              text: "Sign Up",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildInput(String hint, TextEditingController controller, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bluebird, // Biru teal #7CB6D1
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 25,
            vertical: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginBtn(BuildContext context) {
    return GestureDetector(
      onTap: _isLoading
          ? null
          : () async {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();

              if (email.isEmpty || password.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please fill all fields")),
                );
                return;
              }

              setState(() => _isLoading = true);
              final result = await ApiService.login(email, password);
              setState(() => _isLoading = false);

              if (result['success'] == true) {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_budget');
                await prefs.remove('local_expenses');
                await prefs.remove('saved_plans');
                await prefs.setBool('is_first_login_empty', true);
                await prefs.setString('profile_email', email);

                try {
                  await ApiService.getProfile();
                } catch (_) {}

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const MainNavigation()),
                  (route) => false,
                );
              } else {
                final errorMsg = result['message'] ?? 'Login failed';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(errorMsg),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
      child: Container(
        width: double.infinity,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: AppColors.deepOcean)
              : const Text(
                  'Log in',
                  style: TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 24,
                    color: AppColors.deepOcean,
                  ),
                ),
        ),
      ),
    );
  }
}
