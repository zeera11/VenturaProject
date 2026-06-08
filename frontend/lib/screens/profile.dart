import 'package:flutter/material.dart';
import 'package:p_ventura/screens/logout.dart';
import '../utils/colors.dart';
import 'edit_profile.dart';
import 'favorite_places.dart';
import 'about_app.dart';
import '../widgets/logout.dart';
import '../utils/app_state.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  String _phone = "+62 81234567891";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (AppState.token == 'mock_token' || !AppState.isLoggedIn) {
      setState(() {
        _phone = "+62 81234567891";
      });
      return;
    }
    try {
      final profile = await _authService.getProfile();
      if (profile != null && profile.containsKey('username')) {
        setState(() {
          AppState.username = profile['username'];
          AppState.userEmail = profile['email'];
          final dbPhone = profile['phoneNumber']?.toString() ?? '';
          _phone = dbPhone.isNotEmpty ? "+62 $dbPhone" : "+62 81234567891";
        });
      }
    } catch (e) {
      debugPrint("Failed to load profile in dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double curveHeight = 200; // Tinggi area biru
    double profileCardHeight = 120; // Tinggi kotak putih

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // 1. Background Biru Melengkung
              Container(
                height: curveHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(250, 60),
                  ),
                ),
                child: SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: const Text(
                        "Profile",
                        style: TextStyle(
                          fontFamily: 'Chango',
                          fontSize: 28,
                          color: AppColors.deepOcean,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Kotak Putih Profil (Dinaikkan agar pas di puncak)
              Positioned(
                top:
                    curveHeight -
                    (profileCardHeight /
                        2), // Titik tengah kotak di garis puncak
                child: _buildProfileCard(context, profileCardHeight),
              ),
            ],
          ),

          // Spasi setelah kotak profil agar konten di bawah tidak tertutup
          SizedBox(height: (profileCardHeight / 2) + 30),

          // 3. Grid Favorite & About App
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    context,
                    "7",
                    "Favorite Places",
                    [const Color(0xFFFA855A), const Color(0xFFCA3537)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => const FavoritePlacesScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildGridCard(
                    context,
                    "sparkles",
                    "About App",
                    [const Color(0xFFFFF8D0), const Color(0xFFFA855A)],
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (c) => const AboutAppScreen()),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // 4. Tombol Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: GestureDetector(
              onTap: () => showDialog(
                context: context,
                builder: (c) => const LogoutPopup(),
              ),
              child: _buildLogoutBtn(),
            ),
          ),
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildProfileCard(context, double height) => Container(
    width: MediaQuery.of(context).size.width * 0.85,
    height: height,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: const Color(0xFFFEF9E6),
          child: Image.asset('assets/images/logo.png', width: 45),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppState.isLoggedIn ? (AppState.username ?? "Christian Dave") : "Christian Dave",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                  color: AppColors.deepOcean,
                ),
              ),
              Text(
                AppState.isLoggedIn ? (AppState.userEmail ?? "christiandave@ventura.com") : "christiandave@ventura.com",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10537D),
                ),
              ),
              Text(
                _phone,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10537D),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.edit, size: 22),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const EditProfileScreen()),
            );
            if (result == true) {
              _loadProfile();
            }
          },
        ),
      ],
    ),
  );

  Widget _buildGridCard(
    context,
    String val,
    String title,
    List<Color> clrs,
    VoidCallback onTap,
  ) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: clrs),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (val == "7")
            Text(
              val,
              style: const TextStyle(
                fontFamily: 'ClimateCrisis',
                fontSize: 50,
                color: Colors.white,
              ),
            )
          else
            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 50,
            ), // Ukuran icon disamakan (50)

          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          const Text(
            "See all",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildLogoutBtn() => Container(
    height: 55,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 5)],
    ),
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.logout),
        SizedBox(width: 10),
        Text("Log out", style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}
