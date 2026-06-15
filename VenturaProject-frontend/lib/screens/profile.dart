import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import 'edit_profile.dart';
import 'favorite_places.dart';
import 'about_app.dart';
import 'logout.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Christian Dave';
  String _email = 'christiandave@ventura.com';
  String _phone = '+6281234567891';
  String _profilePicture = '';
  int _favoriteCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    ProfileScreen.refreshNotifier.addListener(_loadProfile);
  }

  @override
  void dispose() {
    ProfileScreen.refreshNotifier.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final profile = await ApiService.getProfile();
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_places') ?? [
      "Raja Ampat Sunset Point, West Papua",
      "Gigi Susu, Bali",
      "Tempo Gelato, Yogyakarta",
      "Sunday Market, Bali",
      "Pangalengan Rafting, Bandung",
      "Lembah Harau, Sumatra",
      "Bukit Sikunir Sunrise, Dieng"
    ];

    if (!mounted) return;
    setState(() {
      _name = profile['name'] ?? 'Christian Dave';
      _email = profile['email'] ?? 'christiandave@ventura.com';
      final rawPhone = profile['phone'] ?? '81234567891';
      _phone = rawPhone.startsWith('+62') ? rawPhone : '+62$rawPhone';
      _profilePicture = profile['profilePicture'] ?? '';
      _favoriteCount = favs.length;
      _isLoading = false;
    });
  }

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (c) => const EditProfileScreen()),
    );
    // Refresh data profil jika ada perubahan
    if (result == true) {
      ProfileScreen.refreshNotifier.value = !ProfileScreen.refreshNotifier.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    const double curveHeight = 200.0;
    const double profileCardHeight = 120.0;

    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Background biru melengkung
              Container(
                height: curveHeight,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.brandBlue,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.elliptical(250, 60),
                  ),
                ),
                child: const SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
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

              // Kotak putih profil
              Positioned(
                top: curveHeight - (profileCardHeight / 2),
                child: _buildProfileCard(context, profileCardHeight),
              ),
            ],
          ),

          SizedBox(height: (profileCardHeight / 2) + 30),

          // Grid Favorite & About App
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              children: [
                Expanded(
                  child: _buildGridCard(
                    context,
                    _favoriteCount.toString(),
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
                      MaterialPageRoute(
                        builder: (c) => const AboutAppScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Tombol Logout
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

  Widget _buildProfileCard(BuildContext context, double height) {
    return Container(
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
            backgroundImage: _profilePicture.isNotEmpty
                ? NetworkImage('${ApiService.baseUrl}/uploads/$_profilePicture')
                : null,
            child: _profilePicture.isEmpty
                ? Image.asset('assets/images/logo.png', width: 45)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _isLoading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _shimmer(w: 120, h: 14),
                      const SizedBox(height: 8),
                      _shimmer(w: 160, h: 10),
                      const SizedBox(height: 6),
                      _shimmer(w: 100, h: 10),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                          color: AppColors.deepOcean,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10537D),
                        ),
                        overflow: TextOverflow.ellipsis,
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
            onPressed: _openEditProfile,
          ),
        ],
      ),
    );
  }

  Widget _shimmer({required double w, required double h}) => Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: Colors.grey.shade200,
      borderRadius: BorderRadius.circular(6),
    ),
  );

  Widget _buildGridCard(
    BuildContext context,
    String val,
    String title,
    List<Color> clrs,
    VoidCallback onTap,
  ) =>
      GestureDetector(
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
              if (val != "sparkles")
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
                ),
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
