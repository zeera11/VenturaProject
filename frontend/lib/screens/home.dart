import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'explore.dart';
import '../utils/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State untuk Like interaktif
  final List<Map<String, dynamic>> _destinations = [
    {
      "name": "Raja Ampat, West Papua",
      "image": "assets/images/rajaampat.jpg",
      "isLiked": true,
    },
    {"name": "Ubud, Bali", "image": "assets/images/bali.jpg", "isLiked": false},
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(context),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                _buildHeroCard(),

                // VIBE CHECK SECTION (Spasi dirapatkan)
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
                const SizedBox(height: 5), // Spasi rapat sesuai request
                _buildVibeGrid(),

                const SizedBox(height: 30),
                _buildFundTracker(),

                const SizedBox(height: 35),
                _buildExploreSection(context),

                // Jarak akhir ke Navbar (tidak terlalu jauh)
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Header (Greeting dinaikkan)
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 250,
          decoration: const BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(250, 60),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 5), // Spasi atas kecil agar tulisan NAIK
                Align(
                  alignment: Alignment.topRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                ),
                Text(
                  AppState.isLoggedIn ? "Hi," : "Hi,",
                  style: const TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 32,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                Text(
                  AppState.isLoggedIn ? "${AppState.username ?? 'Christian'}! 👋" : "Christian! 👋",
                  style: const TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "Ready for your next adventure?",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    color: AppColors.deepOcean,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Where do you want to go?",
                      hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      border: InputBorder.none,
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 2. Hero Card (Labuan Bajo)
  Widget _buildHeroCard() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage('assets/images/labuanbajo.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCA3537),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "CURRENT TRIP",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Labuan Bajo",
                  style: TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 32,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  "July 21 - July 28",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Grid Vibe Check
  Widget _buildVibeGrid() {
    final vibes = [
      {'n': 'Healing', 'i': 'healing.webp', 'ic': 'leaves (1).png'},
      {'n': 'Adventure', 'i': 'adventure.jpg', 'ic': 'bagpack.png'},
      {'n': 'Food', 'i': 'food.jpg', 'ic': 'food-tray (1).png'},
      {'n': 'Hidden', 'i': 'hidden.jpg', 'ic': 'magic-wand.png'},
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
      itemBuilder: (context, index) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: AssetImage('assets/images/${vibes[index]['i']}'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.black.withOpacity(0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/${vibes[index]['ic']}',
                width: 35,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                vibes[index]['n']!,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 4. Fund Tracker (Climate Crisis & Layout Adjustment)
  Widget _buildFundTracker() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFEF9E6), Color(0xFFFFDE97), Color(0xFFFA855A)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF61C4DB),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Text(
              "CURRENT STATUS",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "How's the fund looking?",
            style: TextStyle(
              fontFamily: 'Chango',
              fontSize: 26,
              color: Color(0xFFC83636),
              height: 1.1,
            ),
          ),

          const SizedBox(height: 10),

          // Remaining Berada di Sebelah Saldo
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "Remaining: ",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppState.activeBudget != null
                      ? "Rp\n${((AppState.activeBudget! * 0.6) / 1000000).toStringAsFixed(1)}M"
                      : "Rp\n3.5M",
                  style: const TextStyle(
                    fontFamily: 'ClimateCrisis',
                    fontSize: 28,
                    color: Color(0xFFFFECC0),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF61C4DB),
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
                const SizedBox(width: 8),
                const Text(
                  "On Track",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 5. Explore Destinations
  Widget _buildExploreSection(BuildContext context) {
    return Column(
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
                fontSize: 18,
                color: AppColors.deepOcean,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ExploreScreen()),
              ),
              child: const Text(
                "See all",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
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
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Column(
          children: List.generate(
            _destinations.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _buildDestCard(
                index,
                _destinations[index]['image'],
                _destinations[index]['name'],
                _destinations[index]['isLiked'],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDestCard(int index, String img, String location, bool isLiked) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            bottom: 20,
            child: Text(
              location,
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 15,
            child: GestureDetector(
              onTap: () =>
                  setState(() => _destinations[index]['isLiked'] = !isLiked),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  // Nama asset heartborder.png
                  isLiked
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
    );
  }
}
