import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'profile.dart';

class FavoritePlacesScreen extends StatefulWidget {
  const FavoritePlacesScreen({super.key});

  @override
  State<FavoritePlacesScreen> createState() => _FavoritePlacesScreenState();
}

class _FavoritePlacesScreenState extends State<FavoritePlacesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Pool lengkap semua tempat yang bisa di-search
  final List<Map<String, dynamic>> _allPlaces = [
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
    // Tempat tambahan yang bisa dicari & di-favoritkan
    {
      "name": "Komodo National Park, NTT",
      "sub": "Home of the legendary Komodo dragons.",
      "img": "komodough.webp",
      "ic": "bagpack.png",
      "liked": false,
    },
    {
      "name": "Padar Island, Labuan Bajo",
      "sub": "Iconic three-colored beaches from the summit.",
      "img": "labuanbajo.jpg",
      "ic": "bagpack.png",
      "liked": false,
    },
    {
      "name": "Manta Point, Komodo",
      "sub": "Dive with majestic manta rays.",
      "img": "manta.webp",
      "ic": "bagpack.png",
      "liked": false,
    },
    {
      "name": "Gili Island, Lombok",
      "sub": "Clear waters and laid-back island life.",
      "img": "gili.jpg",
      "ic": "leaves (1).png",
      "liked": false,
    },
    {
      "name": "Raja Ampat, West Papua",
      "sub": "World-class diving and pristine reefs.",
      "img": "rajaampat.jpg",
      "ic": "bagpack.png",
      "liked": false,
    },
    {
      "name": "Ubud, Bali",
      "sub": "Cultural heart of Bali with lush rice terraces.",
      "img": "bali.jpg",
      "ic": "leaves (1).png",
      "liked": false,
    },
    {
      "name": "Malioboro, Yogyakarta",
      "sub": "Iconic street of culture and cuisine.",
      "img": "malioboro.jpg",
      "ic": "food-tray (1).png",
      "liked": false,
    },
    {
      "name": "Thousand Island, Jakarta",
      "sub": "Tropical escape close to the capital.",
      "img": "pulauseribu.jpg",
      "ic": "leaves (1).png",
      "liked": false,
    },
    {
      "name": "Sumba, East NTT",
      "sub": "Unique culture and dramatic landscapes.",
      "img": "sumba.webp",
      "ic": "magic-wand.png",
      "liked": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadFavoritesFromPrefs();
  }

  Future<void> _loadFavoritesFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? favs = prefs.getStringList('favorite_places');
    if (favs == null) {
      favs = _allPlaces
          .where((p) => p['liked'] == true)
          .map((p) => p['name'] as String)
          .toList();
      await prefs.setStringList('favorite_places', favs);
    } else {
      setState(() {
        for (var p in _allPlaces) {
          p['liked'] = favs!.contains(p['name']);
        }
      });
    }
  }

  Future<void> _saveFavoritesToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final likedNames = _allPlaces
        .where((p) => p['liked'] == true)
        .map((p) => p['name'] as String)
        .toList();
    await prefs.setStringList('favorite_places', likedNames);
    ProfileScreen.refreshNotifier.value = !ProfileScreen.refreshNotifier.value;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredPlaces {
    final q = _searchQuery.toLowerCase().trim();
    if (q.isEmpty) {
      // Kalau tidak ada query, tampilkan hanya yang di-favorit
      return _allPlaces.where((p) => p['liked'] == true).toList();
    }
    // Kalau ada query, tampilkan semua yang match nama/deskripsi
    return _allPlaces
        .where(
          (p) =>
              p['name'].toString().toLowerCase().contains(q) ||
              p['sub'].toString().toLowerCase().contains(q),
        )
        .toList();
  }

  int get _favoriteCount =>
      _allPlaces.where((p) => p['liked'] == true).length;

  void _toggleLike(Map<String, dynamic> place) {
    final isCurrentlyLiked = place['liked'] as bool;

    if (isCurrentlyLiked) {
      // Konfirmasi sebelum un-favorite
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Remove from Favorites?',
            style: TextStyle(
              fontFamily: 'Chango',
              fontSize: 18,
              color: AppColors.deepOcean,
            ),
          ),
          content: Text(
            '${place['name']} will be removed from your favorites.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                setState(() => place['liked'] = false);
                await _saveFavoritesToPrefs();
              },
              child: const Text(
                'Remove',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFCA3537),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Langsung tambah ke favorit dengan animasi snackbar
      setState(() => place['liked'] = true);
      _saveFavoritesToPrefs();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: AppColors.deepOcean,
          content: Row(
            children: [
              const Icon(Icons.favorite, color: Color(0xFFFA855A), size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${place['name']} added to favorites!',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = _filteredPlaces;
    final isSearching = _searchQuery.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFFEF9E6),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section label
                  Row(
                    children: [
                      Text(
                        isSearching
                            ? 'Search Results (${places.length})'
                            : 'My Favorites ($_favoriteCount)',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      if (isSearching) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                          child: const Text(
                            'Show favorites',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.bluebird,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 15),

                  if (places.isEmpty)
                    _buildEmptyState(isSearching)
                  else
                    ...places.map((p) => _buildCard(p)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => Container(
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
                  color: AppColors.deepOcean,
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
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.deepOcean,
                ),
                decoration: InputDecoration(
                  hintText: "Search destinations…",
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Poppins',
                  ),
                  border: InputBorder.none,
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () => setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          }),
                          child: const Icon(Icons.close, color: Colors.grey),
                        )
                      : const Icon(Icons.search, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildCard(Map<String, dynamic> p) {
    final isLiked = p['liked'] as bool;
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
                  onTap: () => _toggleLike(p),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Image.asset(
                      isLiked
                          ? 'assets/images/heart.png'
                          : 'assets/images/heartborder.png',
                      key: ValueKey(isLiked),
                      width: 28,
                      color: isLiked ? const Color(0xFFFA855A) : Colors.white,
                    ),
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
                const SizedBox(height: 10),
                // Add/Remove button
                GestureDetector(
                  onTap: () => _toggleLike(p),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isLiked
                          ? const Color(0xFFFFEDE8)
                          : AppColors.brandBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: isLiked
                              ? const Color(0xFFCA3537)
                              : AppColors.deepOcean,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isLiked ? 'Saved' : 'Save to Favorites',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                            color: isLiked
                                ? const Color(0xFFCA3537)
                                : AppColors.deepOcean,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState(bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.favorite_border,
              size: 70,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 15),
            Text(
              isSearching
                  ? 'No results for "$_searchQuery"'
                  : 'No favorite places yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Search for destinations and tap the ❤️ to save them.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
