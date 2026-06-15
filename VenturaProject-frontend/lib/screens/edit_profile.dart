import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/api_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasChanges = false;

  File? _profileImage;
  Uint8List? _webImageBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _nameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  String _profilePicture = '';

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
            _hasChanges = true;
          });
        } else {
          setState(() {
            _profileImage = File(image.path);
            _hasChanges = true;
          });
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    if (!mounted) return;
    setState(() {
      _nameController.text = profile['name'] ?? 'Christian Dave';
      _phoneController.text = profile['phone'] ?? '81234567891';
      _emailController.text =
          profile['email'] ?? 'christiandave@ventura.com';
      _profilePicture = profile['profilePicture'] ?? '';
      _isLoading = false;
      _hasChanges = false;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty) {
      _showError('Name cannot be empty.');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      _showError('Please enter a valid email.');
      return;
    }

    setState(() => _isSaving = true);

    final success = await ApiService.saveProfile(
      name: name,
      email: email,
      phone: phone,
      profileImagePath: kIsWeb ? null : _profileImage?.path,
      profileImageBytes: kIsWeb ? _webImageBytes : null,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      // Tampilkan SnackBar sukses
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.deepOcean,
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF61C4D8), size: 18),
              SizedBox(width: 10),
              Text(
                'Profile saved successfully!',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );

      // Kembali ke halaman Profile dengan status berhasil save
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.pop(context, true); // true = ada perubahan
    } else {
      _showError('Failed to update profile. Please try again.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: const Color(0xFFCA3537),
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double headerHeight = 220;
    const double avatarSize = 180;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.bluebird),
            )
          : Stack(
              children: [
                // ─── Layer 1: Scrollable content ────────────────────────────
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.none,
                        children: [
                          // Background oren oval
                          Container(
                            height: headerHeight,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.coralGlow,
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.elliptical(
                                  screenWidth * 1.5,
                                  120,
                                ),
                              ),
                            ),
                          ),

                          // Avatar
                          Positioned(
                            top: headerHeight - (avatarSize / 2),
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickImage,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      Container(
                                        height: avatarSize,
                                        width: avatarSize,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          image: (kIsWeb ? _webImageBytes != null : _profileImage != null)
                                              ? (kIsWeb
                                                  ? DecorationImage(
                                                      image: MemoryImage(_webImageBytes!),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : DecorationImage(
                                                      image: FileImage(_profileImage!),
                                                      fit: BoxFit.cover,
                                                    ))
                                              : (_profilePicture.isNotEmpty
                                                  ? DecorationImage(
                                                      image: NetworkImage('${ApiService.baseUrl}/uploads/$_profilePicture'),
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withOpacity(0.1),
                                              blurRadius: 15,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: (kIsWeb ? _webImageBytes == null : _profileImage == null) && _profilePicture.isEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.all(25),
                                                child: Image.asset(
                                                  'assets/images/logo.png',
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            : null,
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
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  "Profile Image",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: Color(0xFF10537D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Form input
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 35),
                        child: Column(
                          children: [
                            const SizedBox(height: 140),
                            _buildEditableField("Name", _nameController),
                            const SizedBox(height: 25),
                            _buildEditableField(
                              "Phone Number",
                              _phoneController,
                              prefix: "+62 ",
                              keyboard: TextInputType.phone,
                            ),
                            const SizedBox(height: 25),
                            _buildEditableField(
                              "Email",
                              _emailController,
                              keyboard: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Layer 2: Fixed navigation bar ──────────────────────────
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Tombol Back
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF0F2C54),
                            ),
                          ),
                        ),

                        // Tombol Save
                        GestureDetector(
                          onTap: _isSaving ? null : _saveProfile,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: _hasChanges
                                  ? AppColors.deepOcean
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    "Save",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w900,
                                      color: _hasChanges
                                          ? Colors.white
                                          : const Color(0xFF0F2C54),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    String? prefix,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
              fontSize: 12,
              color: Color(0xFF10537D),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF0F2C54),
            ),
            decoration: InputDecoration(
              prefixText: prefix,
              prefixStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: Color(0xFF0F2C54),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
