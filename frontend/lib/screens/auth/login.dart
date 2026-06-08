import 'dart:convert';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';
import '../../services/auth_service.dart';
import '../../services/secure_storage_service.dart';
import '../../utils/app_state.dart';
import '../main_navigation.dart';
import 'signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final AuthService _authService = AuthService();
  final SecureStorageService _secureStorage = SecureStorageService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Decodes JWT payload using base64Url without external dependencies
  Map<String, dynamic> _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return {};
      final payload = parts[1];
      
      // Normalize base64Url padding
      var normalized = base64Url.normalize(payload);
      final decodedStr = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decodedStr);
    } catch (e) {
      debugPrint("JWT Decode Error: $e");
      return {};
    }
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.login(email: email, password: password);
      
      if (response.containsKey('access_token')) {
        final token = response['access_token'] as String;
        await _secureStorage.saveToken(token);
        
        final decoded = _decodeJwt(token);
        AppState.isLoggedIn = true;
        AppState.token = token;
        AppState.userId = decoded['sub']?.toString() ?? 'unknown_user';
        AppState.userEmail = decoded['email']?.toString() ?? email;
        AppState.username = email.split('@')[0]; // Simple fallback name
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Success!')),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (c) => const MainNavigation()),
            (r) => false,
          );
        }
      } else {
        final msg = response['message'] ?? 'Login failed';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg is List ? msg.join(', ') : msg.toString())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Offer bypass if backend is down
        _showBypassDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _bypassLogin() {
    AppState.isLoggedIn = true;
    AppState.token = "mock_token";
    AppState.userId = "mock_user_id";
    AppState.userEmail = "demo@ventura.com";
    AppState.username = "Christian";
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged in via Demo Mode')),
    );
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (c) => const MainNavigation()),
      (r) => false,
    );
  }

  void _showBypassDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Connection Offline'),
        content: Text(
          'Could not connect to the backend server. Make sure the backend services are running.\n\nError: $error\n\nWould you like to bypass and enter Demo Mode?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _bypassLogin();
            },
            child: const Text('Yes, Enter Demo Mode'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.25;
    const double logoOffset = 135;

    return Scaffold(
      backgroundColor: AppColors.brandBlue,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: headerHeight,
                decoration: const BoxDecoration(
                  color: AppColors.clouds,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(250, 80),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Column(
                children: [
                  SizedBox(height: headerHeight - logoOffset),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hello',
                          style: TextStyle(
                            fontFamily: 'Chango',
                            fontSize: 44,
                            color: AppColors.deepOcean,
                            height: 1.0,
                          ),
                        ),
                        const Text(
                          "We're glad you came back!",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: AppColors.deepOcean,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildInput('Enter Email', controller: _emailController),
                        const SizedBox(height: 12),
                        _buildInput('Password', controller: _passwordController, isPass: true),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Forgot your password? Click here',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.deepOcean,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        _buildBtn(),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            onPressed: _bypassLogin,
                            child: const Text(
                              'Bypass (Demo Mode)',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.deepOcean,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        _buildDivider(),
                        const SizedBox(height: 10),
                        _socialRow(),
                        const Spacer(),
                        Center(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => const SignupScreen(),
                              ),
                            ),
                            child: const Text(
                              "Not a member? Sign Up",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                color: AppColors.deepOcean,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String hint, {required TextEditingController controller, bool isPass = false}) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.bluebird,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPass,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
            fontFamily: 'Poppins',
            fontSize: 13,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildBtn() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
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
                    fontSize: 22,
                    color: AppColors.deepOcean,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.deepOcean, thickness: 1),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            "Or continue with",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.deepOcean, thickness: 1),
        ),
      ],
    );
  }

  Widget _socialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['google.png', 'apple.png', 'phone.png']
          .map(
            (img) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Image.asset('assets/images/$img', width: 22),
            ),
          )
          .toList(),
    );
  }
}
