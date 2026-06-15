import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'plan.dart';
import 'main_navigation.dart';
import 'saved_plans.dart';

class FilterScreen extends StatefulWidget {
  final String? destinationName;
  const FilterScreen({super.key, this.destinationName});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Map untuk menyimpan status pilihan
  final Map<String, List<String>> _selectedFilters = {
    "destination": [],
    "days": [],
    "accommodation": [],
    "budget": [],
    "travelers": [],
    "tripType": [], // Ini satu-satunya yang Multiple Choice
  };

  final List<String> _destinations = [
    "Labuan Bajo",
    "Yogyakarta",
    "Lombok",
    "Sumba",
    "Bali",
    "Raja Ampat",
    "Bandung",
    "Dieng",
    "Sumatra",
    "Jakarta",
  ];

  @override
  void initState() {
    super.initState();
    if (widget.destinationName != null) {
      _selectedFilters["destination"] = [widget.destinationName!];
    }
  }

  // Fungsi Logika Pemilihan
  void _handleSelection(String category, String value) {
    setState(() {
      if (category == "tripType") {
        // --- LOGIKA MULTIPLE CHOICE ---
        if (_selectedFilters[category]!.contains(value)) {
          _selectedFilters[category]!.remove(value);
        } else {
          _selectedFilters[category]!.add(value);
        }
      } else {
        // --- LOGIKA SINGLE CHOICE ---
        if (_selectedFilters[category]!.contains(value)) {
          _selectedFilters[category]!.clear(); // Hapus jika pencet yang sama
        } else {
          _selectedFilters[category]!.clear(); // Hapus pilihan lama
          _selectedFilters[category]!.add(value); // Tambah pilihan baru
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSubHeader(),
                  const SizedBox(height: 10),

                  if (widget.destinationName == null) ...[
                    _buildFilterSection(
                      "Where do you want to go?",
                      _destinations,
                      "destination",
                    ),
                  ],

                  _buildFilterSection(
                    "How many days are you planning to travel?",
                    ["1 - 2 Days", "3 - 4 Days", "5 - 7 Days", "7+ Days"],
                    "days",
                  ),

                  _buildFilterSection(
                    "What type of accommodation do you prefer?",
                    ["Budget", "Mid-range", "Luxury", "Unique Stay"],
                    "accommodation",
                  ),

                  _buildFilterSection("What is your budget range?", [
                    "< Rp500K",
                    "Rp500K - 1M",
                    "Rp1M - 2.5M",
                    "> Rp2.5M",
                  ], "budget"),

                  _buildFilterSection("Who are you traveling with?", [
                    "Solo",
                    "Couple",
                    "Friends",
                    "Family",
                  ], "travelers"),

                  // Bagian ini Multiple Choice
                  _buildFilterSection(
                    "What kind of trip are you looking for? (Optional)",
                    [
                      "Adventure",
                      "Relaxation",
                      "Nature",
                      "Culture",
                      "Foodie",
                      "Beach",
                      "Shopping",
                      "Other...",
                    ],
                    "tripType",
                  ),

                  const SizedBox(height: 40),
                  _buildActionButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.brandBlue, // Biru #ABE1E1
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
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
              "Filter",
              style: TextStyle(
                fontFamily: 'Chango',
                fontSize: 26,
                color: AppColors.deepOcean,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Tell us about your trip,\nwe’ll do the rest.",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF10537D),
          ),
        ),
        GestureDetector(
          onTap: () => setState(() {
            _selectedFilters.forEach((key, value) => value.clear());
          }),
          child: const Text(
            "Reset",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.bluebird,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String category,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 25),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.deepOcean,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((option) {
            bool isSelected = _selectedFilters[category]!.contains(option);
            return GestureDetector(
              onTap: () => _handleSelection(category, option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.coralGlow
                      : Colors.white, // Merah/Oren saat dipilih
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppColors.coralGlow : Colors.black12,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.coralGlow.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : AppColors.bluebird,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final destList = _selectedFilters["destination"] ?? [];
        final selectedDest = destList.isNotEmpty ? destList.first : widget.destinationName;
        if (selectedDest == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a destination")),
          );
          return;
        }

        final daysList = _selectedFilters["days"] ?? [];
        if (daysList.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select travel duration")),
          );
          return;
        }
        final daysOption = daysList.first;

        int daysCount = 3; // default fallback
        if (daysOption == "1 - 2 Days") {
          daysCount = 2;
        } else if (daysOption == "3 - 4 Days") {
          daysCount = 3;
        } else if (daysOption == "5 - 7 Days") {
          daysCount = 5;
        } else if (daysOption == "7+ Days") {
          daysCount = 7;
        }

        double budgetAmount = 2500000; // default fallback
        final budgetList = _selectedFilters["budget"] ?? [];
        final budgetOption = budgetList.isNotEmpty ? budgetList.first : "Rp1M - 2.5M";
        if (budgetOption == "< Rp500K") {
          budgetAmount = 500000;
        } else if (budgetOption == "Rp500K - 1M") {
          budgetAmount = 1000000;
        } else if (budgetOption == "Rp1M - 2.5M") {
          budgetAmount = 2500000;
        } else if (budgetOption == "> Rp2.5M") {
          budgetAmount = 5000000;
        }

        // Save the budget to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_budget', budgetAmount);

        // Clear expenses when a new trip budget is set!
        await prefs.setBool('is_first_login_empty', true);
        await prefs.remove('local_expenses');

        // Also call ApiService.clearAllExpenses to delete backend expenses!
        await ApiService.clearAllExpenses();

        // Also call ApiService.addBudget to save it in backend if logged in
        await ApiService.addBudget(totalBudget: budgetAmount);

        // Save the plan details to a persistent saved_plans list in SharedPreferences
        final savedPlansJsonList = prefs.getStringList('saved_plans') ?? [];
        
        final createdAtStr = DateTime.now().toIso8601String();
        final newPlan = {
          'destination': selectedDest,
          'daysCount': daysCount,
          'daysOption': daysOption,
          'budgetOption': budgetOption,
          'budgetAmount': budgetAmount,
          'createdAt': createdAtStr,
        };
        
        savedPlansJsonList.add(jsonEncode(newPlan));
        await prefs.setStringList('saved_plans', savedPlansJsonList);

        // Notify SavedPlansScreen to refresh its list
        SavedPlansScreen.refreshNotifier.value = !SavedPlansScreen.refreshNotifier.value;
        // Switch tab in MainNavigation to the Plan/Explore tab (index 1)
        MainNavigation.tabNotifier.value = 1;

        // Navigate directly to PlanScreen and replace FilterScreen on stack
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PlanScreen(
              destinationName: selectedDest,
              daysCount: daysCount,
              planId: createdAtStr,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.bluebird,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "Show Recommendations",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // Pastikan di bagian build() kamu memanggilnya dengan context:
  // _buildActionButton(context),
}
