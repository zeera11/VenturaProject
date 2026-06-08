import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/app_state.dart';
import 'filter.dart';
import '../services/travel_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final TravelService _travelService = TravelService();
  bool isShowingItinerary = true; // Toggle for Schedule view
  int selectedDay = 1;

  String _getCityImage(String city) {
    switch (city.toLowerCase()) {
      case 'jakarta':
        return 'assets/images/pulauseribu.jpg';
      case 'bandung':
        return 'assets/images/healing.webp';
      case 'yogyakarta':
        return 'assets/images/malioboro.jpg';
      case 'bali':
        return 'assets/images/bali.jpg';
      case 'labuan bajo':
        return 'assets/images/labuanbajo.jpg';
      case 'lombok':
        return 'assets/images/gili.jpg';
      default:
        return 'assets/images/tempogelato.jpg';
    }
  }

  String _getActivityImage(String activity, int index) {
    final act = activity.toLowerCase();
    if (act.contains('food') || act.contains('eat') || act.contains('culinary')) {
      return 'assets/images/food.jpg';
    } else if (act.contains('attraction') || act.contains('explore') || act.contains('famous')) {
      return 'assets/images/adventure.jpg';
    } else if (act.contains('walk') || act.contains('relax') || act.contains('evening')) {
      return 'assets/images/healing.webp';
    }
    // Fallbacks
    final imgs = ['adventure.jpg', 'food.jpg', 'healing.webp'];
    return 'assets/images/${imgs[index % imgs.length]}';
  }

  Future<void> _showSavedItinerariesBottomSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return FutureBuilder<dynamic>(
              future: _travelService.getSavedItineraries(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 250,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.deepOcean),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return SizedBox(
                    height: 250,
                    child: Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }
                final List<dynamic> list = snapshot.data as List<dynamic>? ?? [];
                if (list.isEmpty) {
                  return SizedBox(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, size: 40, color: Colors.grey),
                          const SizedBox(height: 10),
                          const Text(
                            "No saved plans found",
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Saved Itineraries",
                        style: TextStyle(
                          fontFamily: 'Chango',
                          fontSize: 16,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: list.length,
                          itemBuilder: (context, idx) {
                            final item = list[idx] as Map<String, dynamic>;
                            final id = item['id']?.toString() ?? '';
                            final city = item['city'] ?? 'Unknown';
                            final days = item['days'] ?? 3;
                            final type = item['itineraryType'] ?? 'Balanced Trip';
                            return Card(
                              color: const Color(0xFFFEF9E6),
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.bluebird.withOpacity(0.2),
                                  child: const Icon(Icons.location_on, color: AppColors.bluebird),
                                ),
                                title: Text(
                                  city,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.deepOcean,
                                    fontSize: 14,
                                  ),
                                ),
                                subtitle: Text(
                                  "$days Days • $type",
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (c) => AlertDialog(
                                            title: const Text('Delete Plan'),
                                            content: const Text('Are you sure you want to delete this itinerary?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(c, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                onPressed: () => Navigator.pop(c, true),
                                                child: const Text('Delete', style: TextStyle(color: Colors.white)),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (confirm == true) {
                                          try {
                                            await _travelService.deleteItinerary(id);
                                            setSheetState(() {});
                                            ScaffoldMessenger.of(ctx).showSnackBar(
                                              const SnackBar(content: Text('Itinerary deleted successfully')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(ctx).showSnackBar(
                                              SnackBar(content: Text('Failed to delete itinerary: $e')),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.deepOcean),
                                  ],
                                ),
                                onTap: () {
                                  // Load the itinerary into AppState
                                  setState(() {
                                    AppState.activeItinerary = item;
                                    // Set a default mock budget if activeBudget is null
                                    if (AppState.activeBudget == null) {
                                      AppState.activeBudget = 5000000;
                                    }
                                  });
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Loaded itinerary for $city!')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final itineraryData = AppState.activeItinerary;

    // Check if there is an active generated plan
    if (itineraryData == null) {
      return _buildEmptyState();
    }

    final String city = itineraryData['city'] ?? 'Indonesia';
    final String itineraryType = itineraryData['itineraryType'] ?? 'balanced';
    final itineraryPlan = itineraryData['itinerary']?['plan'] as List<dynamic>? ?? [];
    
    // Ensure selected day is within range
    if (selectedDay > itineraryPlan.length) {
      selectedDay = 1;
    }

    // Get current day's activities
    var currentDayData = itineraryPlan.firstWhere(
      (element) => element['day'] == selectedDay,
      orElse: () => null,
    );

    final List<dynamic> activities = currentDayData?['activities'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: Column(
        children: [
          _buildHeader(city, itineraryType, itineraryPlan.length),
          _buildDaySelector(itineraryPlan.length),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: activities.isEmpty
                  ? Center(
                      child: Text(
                        "No activities scheduled for Day $selectedDay",
                        style: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(25, 30, 25, 100),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final String activityText = activities[index].toString();
                        
                        // Map index to time and details
                        String time = "09.00 AM";
                        String subtitle = "Morning Exploration";
                        if (index == 1) {
                          time = "01.00 PM";
                          subtitle = "Local Culinary Journey";
                        } else if (index == 2) {
                          time = "06.30 PM";
                          subtitle = "Evening Relaxation";
                        } else if (index > 2) {
                          time = "08.00 PM";
                          subtitle = "Night Leisure";
                        }

                        return _buildScheduleItem(
                          index + 1,
                          time,
                          activityText,
                          subtitle,
                          _getActivityImage(activityText, index),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                ),
                child: const Icon(
                  Icons.map_rounded,
                  size: 80,
                  color: AppColors.bluebird,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                "No Active Trip",
                style: TextStyle(
                  fontFamily: 'Chango',
                  fontSize: 26,
                  color: AppColors.deepOcean,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "You haven't planned a trip yet. Generate a smart itinerary tailored to your budget and travel preferences!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 35),
              GestureDetector(
                onTap: () async {
                  final bool? isGenerated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FilterScreen()),
                  );
                  if (isGenerated == true && mounted) {
                    setState(() {});
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: AppColors.bluebird,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.bluebird.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Plan Your Trip Now",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (AppState.isLoggedIn && AppState.token != "mock_token") ...[
                const SizedBox(height: 15),
                GestureDetector(
                  onTap: _showSavedItinerariesBottomSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.bluebird, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Text(
                      "Load Saved Itinerary",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        color: AppColors.bluebird,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String city, String itineraryType, int totalDays) {
    // Label for itinerary type matching user specifications
    String typeLabel = "Balanced Trip";
    if (totalDays <= 3) {
      typeLabel = "Compact Trip";
    } else if (totalDays <= 5) {
      typeLabel = "Balanced Trip";
    } else {
      typeLabel = "Slow & Explore Trip";
    }

    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_getCityImage(city)),
              fit: BoxFit.cover,
              colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.elliptical(200, 30),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.coralGlow,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        typeLabel.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (AppState.isLoggedIn && AppState.token != "mock_token")
                          IconButton(
                            icon: const Icon(Icons.folder_open, color: Colors.white, size: 22),
                            tooltip: "Saved Plans",
                            onPressed: _showSavedItinerariesBottomSheet,
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 22),
                          tooltip: "Clear Plan",
                          onPressed: () {
                            setState(() {
                              AppState.activeItinerary = null;
                            });
                          },
                        ),
                        const SizedBox(width: 8),
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
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  city,
                  style: const TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 28,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                  ),
                ),
                Text(
                  "A personalized $totalDays-day journey built just for you",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector(int totalDays) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          itemCount: totalDays,
          itemBuilder: (context, index) {
            final day = index + 1;
            bool active = selectedDay == day;
            return GestureDetector(
              onTap: () => setState(() => selectedDay = day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: active ? AppColors.coralGlow : const Color(0xFFFEF9E6),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.coralGlow.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    "Day $day",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: active ? Colors.white : AppColors.coralGlow.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleItem(
    int num,
    String time,
    String title,
    String loc,
    String img,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index Number Circle
          Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF9E6),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                "$num",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: AppColors.deepOcean,
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          // Detail card
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF9E6),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: AppColors.deepOcean,
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF10537D),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          loc,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Color(0xFF10537D),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      img,
                      width: 65,
                      height: 65,
                      fit: BoxFit.cover,
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
}
