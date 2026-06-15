import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'explore.dart';
import 'category_detail.dart';
import 'plan.dart';
import 'filter.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onFundTap;
  const HomeScreen({super.key, required this.onFundTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "Christian";
  String _profilePicture = "";

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadFavorites();
    ProfileScreen.refreshNotifier.addListener(_loadProfile);
  }

  @override
  void dispose() {
    ProfileScreen.refreshNotifier.removeListener(_loadProfile);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
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

    setState(() {
      for (var dest in _destinations) {
        final fullName = _mapHomeLabelToFullName(dest['label']);
        dest['isLiked'] = favs.contains(fullName);
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getProfile();
      final name = profile['name'] ?? 'Christian';
      final firstName = name.split(' ').first;
      final profilePic = profile['profilePicture'] ?? '';
      if (mounted) {
        setState(() {
          _userName = firstName;
          _profilePicture = profilePic;
        });
      }
    } catch (_) {}
  }

  // Data interaktif untuk Explore Destination — Labuan Bajo
  final List<Map<String, dynamic>> _destinations = [
    {
      "label": "Komodo National Park",
      "image": "assets/images/komodough.webp",
      "isLiked": true,
    },
    {
      "label": "Padar Island",
      "image": "assets/images/labuanbajo.jpg",
      "isLiked": false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                const Text(
                  "Vibe Check",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 5),
                _buildVibeGrid(),
                const SizedBox(height: 35),

                // EXPLORE DESTINATION (di atas Fund)
                _buildExploreSection(context),

                const SizedBox(height: 35),

                // FUND TRACKER CARD
                GestureDetector(
                  onTap: widget.onFundTap,
                  child: _buildFundCard(),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(250, 50),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              25,
              5,
              25,
              0,
            ), // Font diketasin (naik)
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    backgroundImage: _profilePicture.isNotEmpty
                        ? NetworkImage('${ApiService.baseUrl}/uploads/$_profilePicture')
                        : null,
                    child: _profilePicture.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(6),
                            child: Image.asset('assets/images/logo.png'),
                          )
                        : null,
                  ),
                ),
                const Text(
                  "Hi,",
                  style: TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 36,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  "$_userName! 👋",
                  style: const TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 36,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Ready for your next adventure?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.deepOcean,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVibeGrid() {
    final List<Map<String, dynamic>> vibes = [
      {
        'n': 'Healing',
        'i': 'healing.webp',
        'ic': 'leaves (1).png',
        'c': const Color(0xFF8DA47E),
      },
      {
        'n': 'Adventure',
        'i': 'adventure.jpg',
        'ic': 'bagpack.png',
        'c': AppColors.bluebird,
      },
      {
        'n': 'Food',
        'i': 'food.jpg',
        'ic': 'food-tray (1).png',
        'c': const Color(0xFFD04E50),
      },
      {
        'n': 'Hidden',
        'i': 'hidden.jpg',
        'ic': 'magic-wand.png',
        'c': AppColors.skyBlue,
      },
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: 4,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => CategoryDetailScreen(category: vibes[i]['n']),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              image: AssetImage('assets/images/${vibes[i]['i']}'),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              color: Colors.black.withOpacity(0.35),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/${vibes[i]['ic']}',
                  width: 38,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Text(
                  vibes[i]['n'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFundCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: ShapeDecoration(
        // GRADASI: Krem -> Kuning Muda -> Oranye -> Coral
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFEF9E6), // Krem Pucat
            Color(0xFFFFDE97), // Kuning Peach
            Color(0xFFFCB178), // Oranye
            Color(0xFFFA855A), // Coral Glow
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(35), // Sudut sangat bulat
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BADGE: CURRENT STATUS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF61C4D8), // Biru Cyan
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Text(
              'CURRENT STATUS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 15),

          // TEKS JUDUL: Merah Tua
          const Text(
            'How’s the \nfund looking?',
            style: TextStyle(
              color: Color(0xFFC83636), // Warna Merah Figma
              fontSize: 28,
              fontFamily: 'Chango',
              height: 1.1,
            ),
          ),

          const SizedBox(height: 15),

          // TOMBOL STATUS: On Track
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF61C4DB), // Biru Cyan
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/trend.png',
                  width: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                const Text(
                  'On Track',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection(context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Explore Destination",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: AppColors.deepOcean,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (c) => const ExploreScreen()),
            ),
            child: const Text(
              "See all",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w800,
                color: AppColors.bluebird,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
      const Text(
        "Hidden gems & dreamy getaways await",
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 25),
      Column(
        children: List.generate(
          _destinations.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 25),
            child: _buildDestCard(
              i,
              _destinations[i]['image'],
              _destinations[i]['label'],
              _destinations[i]['isLiked'],
            ),
          ),
        ),
      ),
    ],
  );

  String _mapToPrimaryDestination(String originalName) {
    final name = originalName.toLowerCase();
    if (name.contains("bajo") || name.contains("komodo") || name.contains("padar")) return "Labuan Bajo";
    if (name.contains("yogyakarta") || name.contains("jogja") || name.contains("malioboro")) return "Yogyakarta";
    if (name.contains("lombok") || name.contains("gili")) return "Lombok";
    if (name.contains("sumba")) return "Sumba";
    if (name.contains("bali") || name.contains("ubud")) return "Bali";
    if (name.contains("raja ampat")) return "Raja Ampat";
    if (name.contains("bandung") || name.contains("pangalengan")) return "Bandung";
    if (name.contains("dieng") || name.contains("sikunir")) return "Dieng";
    if (name.contains("sumatra") || name.contains("harau")) return "Sumatra";
    if (name.contains("jakarta") || name.contains("seribu")) return "Jakarta";
    return "Labuan Bajo";
  }

  String _mapHomeLabelToFullName(String label) {
    if (label == "Komodo National Park") return "Komodo National Park, NTT";
    if (label == "Padar Island") return "Padar Island, Labuan Bajo";
    return label;
  }

  Widget _buildDestCard(int i, String img, String lbl, bool liked) => GestureDetector(
    onTap: () => Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination(lbl)),
      ),
    ),
    child: Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Colors.black.withOpacity(0.15),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 25,
            child: Text(
              lbl,
              style: const TextStyle(
                fontFamily: 'ClimateCrisis',
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: 25,
            child: GestureDetector(
              onTap: () async {
                final newLiked = !liked;
                setState(() {
                  _destinations[i]['isLiked'] = newLiked;
                });
                
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
                
                final fullName = _mapHomeLabelToFullName(lbl);
                if (newLiked) {
                  if (!favs.contains(fullName)) favs.add(fullName);
                } else {
                  favs.remove(fullName);
                }
                await prefs.setStringList('favorite_places', favs);
                
                ProfileScreen.refreshNotifier.value = !ProfileScreen.refreshNotifier.value;
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  liked
                      ? 'assets/images/heart.png'
                      : 'assets/images/heartborder.png',
                  width: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
