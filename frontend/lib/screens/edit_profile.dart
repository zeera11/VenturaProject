import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/auth_service.dart';
import '../utils/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _authService = AuthService();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = AppState.username ?? '';
    _emailController.text = AppState.userEmail ?? '';
    _phoneController.text = ''; // Placeholder for phone
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    if (AppState.token == 'mock_token' || !AppState.isLoggedIn) {
      setState(() {
        _phoneController.text = "81234567891";
      });
      return;
    }
    setState(() => _isLoading = true);
    try {
      final profile = await _authService.getProfile();
      if (profile != null && profile.containsKey('username')) {
        setState(() {
          _nameController.text = profile['username'] ?? '';
          _emailController.text = profile['email'] ?? '';
          _phoneController.text = profile['phoneNumber'] ?? '';
        });
      }
    } catch (e) {
      debugPrint("Failed to load profile from backend: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Email cannot be empty')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (AppState.token == 'mock_token' || !AppState.isLoggedIn) {
        // Mock Mode: update locally
        AppState.username = name;
        AppState.userEmail = email;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated locally')),
        );
        Navigator.pop(context, true);
      } else {
        // Backend Mode
        final res = await _authService.updateProfile(
          username: name,
          email: email,
          phoneNumber: phone,
        );
        if (res.containsKey('data')) {
          final data = res['data'];
          AppState.username = data['username'];
          AppState.userEmail = data['email'];
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(res['message'] ?? 'Failed to update profile')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double headerHeight = 220;
    double avatarSize = 180;

    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: Stack(
        children: [
          // 1. Background Oval Orange
          Container(
            height: headerHeight,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.coralGlow,
              borderRadius: BorderRadius.vertical(
                bottom: Radius.elliptical(250, 60),
              ),
            ),
          ),

          // 2. Navigasi Atas
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context), // Back ke Profile
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.deepOcean,
                        size: 24,
                      ),
                    ),
                  ),
                  _isLoading
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : GestureDetector(
                          onTap: _saveProfile,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                )
                              ],
                            ),
                            child: const Text(
                              "Save",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                color: AppColors.deepOcean,
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),

          // 3. Konten (Avatar di Puncak)
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: headerHeight - (avatarSize / 2)),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      height: avatarSize,
                      width: avatarSize,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 15),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6E6E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Profile Image",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF10537D),
                  ),
                ),
                const SizedBox(height: 40),
                _buildEditableField("Name", _nameController),
                _buildEditableField("Phone Number", _phoneController, prefix: "+62 "),
                _buildEditableField("Email", _emailController),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller, {String? prefix}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF10537D),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                if (prefix != null)
                  Text(
                    prefix,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      color: AppColors.deepOcean,
                    ),
                  ),
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: AppColors.deepOcean,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
