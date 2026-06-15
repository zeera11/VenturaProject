import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'plan.dart';
import 'filter.dart';

class CategoryDetailScreen extends StatefulWidget {
  final String category;
  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  // Mapping Data khusus per kategori
  late List<Map<String, dynamic>> _currentItems;

  @override
  void initState() {
    super.initState();
    if (widget.category == "Healing") {
      _currentItems = [
        {
          "n": "Raja Ampat Sunset Point, West Papua",
          "s": "Golden sunsets and quiet escapes",
          "i": "rajaampatsunset.jpg",
          "ic": "leaves (1).png",
          "l": true,
        },
      ];
    } else if (widget.category == "Hidden") {
      _currentItems = [
        {
          "n": "Sunday Market, Bali",
          "s": "Vintage finds and local crafts",
          "i": "sundaymarket.jpg",
          "ic": "magic-wand.png",
          "l": true,
        },
        {
          "n": "Lembah Harau, Sumatra",
          "s": "Quiet cliffs and hidden waterfalls",
          "i": "lembahharau.jpg",
          "ic": "magic-wand.png",
          "l": true,
        },
      ];
    } else if (widget.category == "Adventure") {
      _currentItems = [
        {
          "n": "Pangalengan Rafting, Bandung",
          "s": "Thrilling river rides and fresh air",
          "i": "pangalenganrafting.jpg",
          "ic": "bagpack.png",
          "l": true,
        },
        {
          "n": "Bukit Sikunir Sunrise, Dieng",
          "s": "An early morning climb for breathtaking views",
          "i": "bukitsikunir.jpg",
          "ic": "bagpack.png",
          "l": true,
        },
      ];
    } else {
      // Food
      _currentItems = [
        {
          "n": "Gigi Susu, Bali",
          "s": "Soft pastries and slow mornings",
          "i": "gigisusu.jpg",
          "ic": "food-tray (1).png",
          "l": true,
        },
        {
          "n": "Tempo Gelato, Yogyakarta",
          "s": "Sweet gelato and colorful corners",
          "i": "tempogelato.jpg",
          "ic": "food-tray (1).png",
          "l": true,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: List.generate(
                  _currentItems.length,
                  (i) => _buildCard(i),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(context) => Container(
    height: 180,
    width: double.infinity,
    decoration: const BoxDecoration(
      color: Color(0xFFC7E3EA),
      borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(250, 40)),
    ),
    child: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Image.asset('assets/images/logo.png', width: 25),
                ),
              ],
            ),
          ),
          Text(
            widget.category,
            style: const TextStyle(
              fontFamily: 'Chango',
              fontSize: 28,
              color: AppColors.deepOcean,
            ),
          ),
          const Text(
            "Your personal collection of beautiful places",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF10537D),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCard(int i) {
    final item = _currentItems[i];
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination(item['n'])),
        ),
      ),
      child: Container(
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
                    'assets/images/${item['i']}',
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
                      'assets/images/${item['ic']}',
                      width: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  bottom: 15,
                  child: GestureDetector(
                    onTap: () => setState(() => item['l'] = !item['l']),
                    child: Image.asset(
                      item['l']
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
                    item['n'],
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item['s'],
                    style: const TextStyle(
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
      ),
    );
  }

  String _mapToPrimaryDestination(String originalName) {
    final name = originalName.toLowerCase();
    if (name.contains("bajo") || name.contains("komodo") || name.contains("padar")) return "Labuan Bajo";
    if (name.contains("yogyakarta") || name.contains("jogja") || name.contains("malioboro") || name.contains("tempo gelato")) return "Yogyakarta";
    if (name.contains("lombok") || name.contains("gili")) return "Lombok";
    if (name.contains("sumba")) return "Sumba";
    if (name.contains("bali") || name.contains("ubud") || name.contains("sunday market") || name.contains("gigi susu")) return "Bali";
    if (name.contains("raja ampat")) return "Raja Ampat";
    if (name.contains("bandung") || name.contains("pangalengan")) return "Bandung";
    if (name.contains("dieng") || name.contains("sikunir")) return "Dieng";
    if (name.contains("sumatra") || name.contains("harau")) return "Sumatra";
    if (name.contains("jakarta") || name.contains("seribu")) return "Jakarta";
    return "Yogyakarta";
  }
}
