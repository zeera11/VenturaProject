import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/colors.dart';
import 'filter.dart';
import 'plan.dart';

class SavedPlansScreen extends StatefulWidget {
  const SavedPlansScreen({super.key});

  static final ValueNotifier<bool> refreshNotifier = ValueNotifier<bool>(false);

  @override
  State<SavedPlansScreen> createState() => _SavedPlansScreenState();
}

class _SavedPlansScreenState extends State<SavedPlansScreen> {
  List<Map<String, dynamic>> _savedPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedPlans();
    SavedPlansScreen.refreshNotifier.addListener(_loadSavedPlans);
  }

  @override
  void dispose() {
    SavedPlansScreen.refreshNotifier.removeListener(_loadSavedPlans);
    super.dispose();
  }

  Future<void> _loadSavedPlans() async {
    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('saved_plans') ?? [];
    
    final List<Map<String, dynamic>> plans = [];
    for (var jsonStr in plansJson) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        plans.add(map);
      } catch (e) {
        debugPrint("Error parsing saved plan: $e");
      }
    }
    
    // Sort plans by createdAt (newest first)
    plans.sort((a, b) {
      final aTime = a['createdAt'] != null ? DateTime.tryParse(a['createdAt']) : null;
      final bTime = b['createdAt'] != null ? DateTime.tryParse(b['createdAt']) : null;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    setState(() {
      _savedPlans = plans;
      _isLoading = false;
    });
  }

  String _getImageForDestination(String dest) {
    final d = dest.toLowerCase();
    if (d.contains("bajo")) return 'assets/images/labuanbajo.jpg';
    if (d.contains("yogyakarta") || d.contains("jogja")) return 'assets/images/malioboro.jpg';
    if (d.contains("lombok")) return 'assets/images/gili.jpg';
    if (d.contains("sumba")) return 'assets/images/sumba.webp';
    if (d.contains("bali")) return 'assets/images/bali.jpg';
    if (d.contains("raja ampat")) return 'assets/images/rajaampat.jpg';
    if (d.contains("bandung")) return 'assets/images/pangalenganrafting.jpg';
    if (d.contains("dieng")) return 'assets/images/bukitsikunir.jpg';
    if (d.contains("sumatra")) return 'assets/images/lembahharau.jpg';
    if (d.contains("jakarta")) return 'assets/images/pulauseribu.jpg';
    return 'assets/images/bali.jpg'; // fallback
  }

  Future<void> _deletePlan(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getStringList('saved_plans') ?? [];
    
    // Find the correct item in plansJson matching the sorted _savedPlans[index]
    final planToDelete = _savedPlans[index];
    
    plansJson.removeWhere((jsonStr) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        return map['createdAt'] == planToDelete['createdAt'] &&
               map['destination'] == planToDelete['destination'];
      } catch (e) {
        return false;
      }
    });

    final createdAt = planToDelete['createdAt'];
    if (createdAt != null) {
      await prefs.remove('itinerary_$createdAt');
    }

    await prefs.setStringList('saved_plans', plansJson);
    _loadSavedPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.bluebird))
          : Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _savedPlans.isEmpty ? _buildEmptyState() : _buildPlansList(),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 25),
      decoration: const BoxDecoration(
        color: Color(0xFFC7E3EA), // Blue tone header
        borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(250, 20)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Ventura",
                    style: TextStyle(
                      fontFamily: 'Chango',
                      fontSize: 18,
                      color: AppColors.deepOcean,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              "Saved Plans",
              style: TextStyle(
                fontFamily: 'Chango',
                fontSize: 26,
                color: AppColors.deepOcean,
              ),
            ),
            const Text(
              "Access and manage your generated travel itineraries",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF10537D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.card_travel,
              size: 70,
              color: AppColors.coralGlow,
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "no plans yet",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Create your first travel itinerary plan to track budgets and coordinate your vacation trip activities.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 35),
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FilterScreen()),
              );
              _loadSavedPlans();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.bluebird,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.bluebird.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Create Plan",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlansList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(25, 20, 25, 120),
      itemCount: _savedPlans.length,
      itemBuilder: (context, index) {
        final plan = _savedPlans[index];
        final destination = plan['destination'] ?? 'Unknown City';
        final daysCount = plan['daysCount'] ?? 3;
        final daysOption = plan['daysOption'] ?? '$daysCount Days';
        final budgetOption = plan['budgetOption'] ?? 'Flexible';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlanScreen(
                        destinationName: destination,
                        daysCount: daysCount,
                        planId: plan['createdAt'],
                      ),
                    ),
                  );
                  _loadSavedPlans();
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                      child: Image.asset(
                        _getImageForDestination(destination),
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.1),
                            Colors.black.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 15,
                      child: Text(
                        destination,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: AppColors.bluebird),
                        const SizedBox(width: 6),
                        Text(
                          daysOption,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.deepOcean,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Icon(Icons.payments, size: 16, color: AppColors.coralGlow),
                        const SizedBox(width: 6),
                        Text(
                          budgetOption,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.deepOcean,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Delete Plan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                            content: const Text("Are you sure you want to delete this itinerary plan?", style: TextStyle(fontFamily: 'Poppins')),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _deletePlan(index);
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
