import 'package:flutter/material.dart';
import '../utils/colors.dart';

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
            _title("Popular Destination", true),
            _popularList(),
            const SizedBox(height: 30),
            _title("Recommended for You", false),
            _recommendedCard(),
            const SizedBox(height: 30),
            _title("Recently Viewed", true),
            _recentList(),
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
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
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
  }

  Widget _title(String t, bool s) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          t,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: AppColors.deepOcean,
          ),
        ),
        if (s)
          const Text(
            "See all",
            style: TextStyle(
              color: Color(0xFF4A98C9),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
      ],
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
        itemBuilder: (context, i) => Container(
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
    );
  }

  Widget _recommendedCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
    );
  }

  Widget _recentList() {
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/images/${item['i']}',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
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
                    Image.asset('assets/images/heart.png', width: 22),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
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
