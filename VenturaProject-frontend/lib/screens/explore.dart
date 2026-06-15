import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'plan.dart';
import 'filter.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 25),
            _title("Popular Destination"),
            _popularList(),
            const SizedBox(height: 30),
            _title("Recommended for You"),
            _recommendedCard(context),
            const SizedBox(height: 30),
            _title("Recently Viewed"),
            _recentList(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 30),
      decoration: const BoxDecoration(color: Color(0xFFC7E3EA)),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.deepOcean,
                        size: 20,
                      ),
                    ),
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
              "Explore Destination",
              style: TextStyle(
                fontFamily: 'Chango',
                fontSize: 24,
                color: AppColors.deepOcean,
              ),
            ),
            const Text(
              "Discover dreamy destinations for your next getaway",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10537D),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _title(String t) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(
      t,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w900,
        fontSize: 18,
        color: AppColors.deepOcean,
      ),
    ),
  );

  Widget _popularList() {
    final data = [
      {'n': 'Thousand Island', 'l': 'DKI Jakarta', 'i': 'pulauseribu.jpg'},
      {'n': 'Malioboro', 'l': 'Yogyakarta', 'i': 'malioboro.jpg'},
      {'n': 'Gili Island', 'l': 'Lombok', 'i': 'gili.jpg'},
    ];
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        itemCount: data.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination(data[i]['n']!)),
            ),
          ),
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/${data[i]['i']}',
                    height: 180,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data[i]['n']!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: AppColors.deepOcean,
                  ),
                ),
                Text(
                  data[i]['l']!,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _recommendedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination("Sumba, East NTT")),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/images/sumba.webp',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sumba, East NTT",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.2,
                      ),
                    ),
                    const Text(
                      "Perfect mix of culture and nature.",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    _iconText(Icons.hotel, "Rp800K - Rp7M"),
                    _iconText(Icons.access_time_filled, "3 - 5 Days"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentList(BuildContext context) {
    final items = [
      {
        'n': 'Ubud, Bali',
        'p': 'Rp400K - 1.3M',
        'd': '4-6 Days',
        'i': 'bali.jpg',
      },
      {
        'n': 'Raja Ampat',
        'p': 'Rp350K - 10M',
        'd': '3-5 Days',
        'i': 'rajaampat.jpg',
      },
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 15),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination(item['n']!)),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/${item['i']}',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => FilterScreen(destinationName: _mapToPrimaryDestination(item['n']!)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['n']!,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                            _iconText(Icons.hotel, item['p']!),
                            _iconText(Icons.access_time_filled, item['d']!),
                          ],
                        ),
                      ),
                    ),
                    Image.asset('assets/images/heart.png', width: 22),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

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
    return "Yogyakarta";
  }

  Widget _iconText(IconData i, String t) => Row(
    children: [
      Icon(i, size: 14, color: AppColors.deepOcean),
      const SizedBox(width: 6),
      Text(
        t,
        style: const TextStyle(
          color: Color(0xFF4A98C9),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    ],
  );
}
