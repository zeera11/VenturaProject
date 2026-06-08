import 'package:flutter/material.dart';
import '../utils/colors.dart';

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({super.key});

  @override
  State<FavoritePlacesScreen> createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  // Data 7 Tempat Favorit
  final List<Map<String, dynamic>> _places = [
    {
      "name": "Raja Ampat Sunset Point, West Papua",
      "sub": "Golden sunsets and endless ocean views.",
      "img": "rajaampatsunset.jpg",
      "ic": "leaves (1).png",
      "liked": true,
    },
    {
      "name": "Gigi Susu, Bali",
      "sub": "Soft pastries, warm coffee, and slow mornings.",
      "img": "gigisusu.jpg",
      "ic": "food-tray (1).png",
      "liked": true,
    },
    {
      "name": "Tempo Gelato, Yogyakarta",
      "sub": "Sweet gelato breaks and colorful corners.",
      "img": "tempogelato.jpg",
      "ic": "food-tray (1).png",
      "liked": true,
    },
    {
      "name": "Sunday Market, Bali",
      "sub": "Vintage finds and weekend vibes.",
      "img": "sundaymarket.jpg",
      "ic": "magic-wand.png",
      "liked": true,
    },
    {
      "name": "Pangalengan Rafting, Bandung",
      "sub": "Thrilling river rides and lush landscapes.",
      "img": "pangalenganrafting.jpg",
      "ic": "bagpack.png",
      "liked": true,
    },
    {
      "name": "Lembah Harau, Sumatra",
      "sub": "Quiet cliffs and hidden waterfalls.",
      "img": "lembahharau.jpg",
      "ic": "magic-wand.png",
      "liked": true,
    },
    {
      "name": "Bukit Sikunir Sunrise, Dieng",
      "sub": "Breathtaking sunrise from the clouds.",
      "img": "bukitsikunir.jpg",
      "ic": "bagpack.png",
      "liked": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: List.generate(
                  _places.length,
                  (index) => _buildCard(index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(context) => Container(
    color: AppColors.brandBlue,
    padding: const EdgeInsets.only(bottom: 25),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 22,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            "Favorite Places",
            style: TextStyle(
              fontFamily: 'Chango',
              fontSize: 24,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search Destination",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCard(int i) {
    final p = _places[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: Image.asset(
                  'assets/images/${p['img']}',
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                left: 15,
                bottom: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.white30,
                  radius: 18,
                  child: Image.asset(
                    'assets/images/${p['ic']}',
                    width: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                right: 15,
                bottom: 15,
                child: GestureDetector(
                  onTap: () => setState(() => p['liked'] = !p['liked']),
                  child: Image.asset(
                    p['liked']
                        ? 'assets/images/heart.png'
                        : 'assets/images/heartborder.png',
                    width: 25,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['name'],
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.deepOcean,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  p['sub'],
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
        ],
      ),
    );
  }
}
