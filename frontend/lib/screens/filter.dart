import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/travel_service.dart';
import '../services/finance_service.dart';
import '../utils/app_state.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final TravelService _travelService = TravelService();
  final FinanceService _financeService = FinanceService();

  final TextEditingController _budgetController = TextEditingController();

  String? _selectedCity;
  int? _selectedDays;

  // Selected categories mapping
  final List<String> _selectedCategories = [];

  final List<Map<String, String>> _cities = [
    {"name": "Jakarta", "img": "pulauseribu.jpg"},
    {"name": "Bandung", "img": "healing.webp"},
    {"name": "Yogyakarta", "img": "malioboro.jpg"},
    {"name": "Bali", "img": "bali.jpg"},
    {"name": "Labuan Bajo", "img": "labuanbajo.jpg"},
    {"name": "Lombok", "img": "gili.jpg"},
  ];

  final List<Map<String, dynamic>> _durations = [
    {"label": "3 Days (Compact)", "value": 3},
    {"label": "5 Days (Balanced)", "value": 5},
    {"label": "7 Days (Slow & Explore)", "value": 7},
  ];

  final Map<String, String> _categoryMapping = {
    "Adventure": "adventure",
    "Relaxation": "relaxation",
    "Nature": "nature",
    "Culture": "culture",
    "Foodie": "food",
    "Beach": "beach",
    "Shopping": "shopping",
    "Other...": "entertainment",
  };

  bool _isLoading = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _handleCategorySelection(String option) {
    setState(() {
      if (_selectedCategories.contains(option)) {
        _selectedCategories.remove(option);
      } else {
        _selectedCategories.add(option);
      }
    });
  }

  Future<void> _generateRecommendation() async {
    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination city')),
      );
      return;
    }

    if (_selectedDays == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a trip duration')),
      );
      return;
    }

    final budgetStr = _budgetController.text.trim();
    if (budgetStr.isEmpty || double.tryParse(budgetStr) == null || double.parse(budgetStr) <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid trip budget')),
      );
      return;
    }

    final double budget = double.parse(budgetStr);
    
    // Map Indonesian category labels to backend lowercase keys
    final mappedCategories = _selectedCategories.map((c) => _categoryMapping[c] ?? c.toLowerCase()).toList();
    if (mappedCategories.isEmpty) {
      // Default category if none selected
      mappedCategories.add('nature');
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _travelService.generateRecommendation(
        city: _selectedCity!,
        categories: mappedCategories,
        activityLevel: "moderate",
        days: _selectedDays!,
        budget: budget,
      );

      if (response != null && response.containsKey('itinerary')) {
        // Normalize response['itinerary'] to Map with "plan" key if it's a List
        final dynamic rawItinerary = response['itinerary'];
        Map<String, dynamic> normalizedItinerary;
        if (rawItinerary is List) {
          normalizedItinerary = {"plan": rawItinerary};
        } else if (rawItinerary is Map) {
          normalizedItinerary = Map<String, dynamic>.from(rawItinerary);
        } else {
          normalizedItinerary = {"plan": []};
        }
        
        final Map<String, dynamic> normalizedResponse = Map<String, dynamic>.from(response);
        normalizedResponse['itinerary'] = normalizedItinerary;

        // Save the dynamic itinerary in global AppState
        AppState.activeItinerary = normalizedResponse;
        AppState.activeBudget = budget;

        // Try to save the budget on the backend database if authenticated
        if (AppState.isLoggedIn && AppState.token != "mock_token") {
          try {
            await _financeService.addBudget(totalBudget: budget);
          } catch (e) {
            debugPrint("Failed to upload budget to backend database: $e");
          }
          try {
            await _travelService.saveItinerary(
              city: response['city'] ?? _selectedCity!,
              days: _selectedDays!,
              itineraryType: response['itineraryType'] ?? 'Balanced Trip',
              itinerary: normalizedItinerary,
            );
          } catch (e) {
            debugPrint("Failed to auto-save itinerary: $e");
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Plan generated successfully for $_selectedCity!')),
          );
          Navigator.pop(context, true); // Return success to switch tab
        }
      } else {
        final errorMsg = response?['message'] ?? 'Unable to generate itinerary. Please try again.';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMsg.toString())),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showMockFallbackDialog(e.toString(), budget, mappedCategories);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMockFallbackDialog(String error, double budget, List<String> categories) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server Offline'),
        content: Text(
          'Failed to connect to the backend recommendation service.\n\nError: $error\n\nWould you like Ventura to generate a beautiful mock itinerary locally for $_selectedCity?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _generateLocalMockItinerary(budget, categories);
            },
            child: const Text('Generate Locally'),
          ),
        ],
      ),
    );
  }

  void _generateLocalMockItinerary(double budget, List<String> categories) {
    final dailyBudget = budget / _selectedDays!;
    final budgetPlan = {
      "food": (dailyBudget * 0.3).round(),
      "transport": (dailyBudget * 0.2).round(),
      "attraction": (dailyBudget * 0.3).round(),
      "accommodation": (dailyBudget * 0.15).round(),
      "misc": (dailyBudget * 0.05).round(),
    };

    final plan = List.generate(_selectedDays!, (index) {
      final day = index + 1;
      return {
        "day": day,
        "activities": [
          "Explore famous tourist attractions in $_selectedCity",
          "Enjoy local culinary delights at $_selectedCity",
          "Evening walk and relaxation around $_selectedCity landmark",
        ]
      };
    });

    final mockResponse = {
      "city": _selectedCity,
      "categories": categories,
      "estimatedDailyBudget": dailyBudget.round(),
      "score": 95,
      "dailyBudget": dailyBudget,
      "budgetPlan": budgetPlan,
      "itineraryType": _selectedDays == 3 ? "compact" : _selectedDays == 5 ? "balanced" : "slow",
      "itinerary": {
        "city": _selectedCity,
        "days": _selectedDays,
        "plan": plan,
      },
      "explanation": "Locally generated itinerary for $_selectedCity"
    };

    AppState.activeItinerary = mockResponse;
    AppState.activeBudget = budget;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Generated local plan for $_selectedCity!')),
    );
    Navigator.pop(context, true);
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

                  // DESTINATION CITY SELECTOR
                  const Text(
                    "Select destination city in Indonesia",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepOcean,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCityPicker(),

                  const SizedBox(height: 10),

                  // DAYS DURATION SELECTOR
                  const Text(
                    "How many days are you planning to travel?",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepOcean,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDurationPicker(),

                  const SizedBox(height: 10),

                  // CUSTOM BUDGET INPUT
                  const Text(
                    "What is your trip budget? (Rp)",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.deepOcean,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBudgetField(),

                  // CATEGORIES PICKER
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        color: AppColors.brandBlue,
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
              "Filter Plan",
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
            _selectedCity = null;
            _selectedDays = null;
            _budgetController.clear();
            _selectedCategories.clear();
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

  Widget _buildCityPicker() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _cities.length,
        itemBuilder: (context, index) {
          final city = _cities[index];
          final isSelected = _selectedCity == city['name'];
          return GestureDetector(
            onTap: () => setState(() => _selectedCity = city['name']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                image: DecorationImage(
                  image: AssetImage('assets/images/${city['img']}'),
                  fit: BoxFit.cover,
                  colorFilter: isSelected
                      ? const ColorFilter.mode(Colors.black38, BlendMode.darken)
                      : ColorFilter.mode(Colors.black.withOpacity(0.15), BlendMode.darken),
                ),
                border: Border.all(
                  color: isSelected ? AppColors.coralGlow : Colors.transparent,
                  width: 3.0,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    city['name']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                  if (isSelected)
                    const Positioned(
                      top: 8,
                      right: 8,
                      child: Icon(Icons.check_circle, color: AppColors.coralGlow, size: 20),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDurationPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _durations.map((duration) {
        final isSelected = _selectedDays == duration['value'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedDays = duration['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.coralGlow : const Color(0xFFFEF9E6),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: isSelected ? AppColors.coralGlow : Colors.black12,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.coralGlow.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                    : [],
              ),
              child: Text(
                duration['label']!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppColors.bluebird,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBudgetField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bluebird,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: _budgetController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          hintText: "e.g., 5000000",
          hintStyle: TextStyle(color: Colors.white60, fontFamily: 'Poppins', fontSize: 13),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          prefixText: "Rp ",
          prefixStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
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
            bool isSelected = _selectedCategories.contains(option);
            return GestureDetector(
              onTap: () => _handleCategorySelection(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.coralGlow : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isSelected ? AppColors.coralGlow : Colors.black12,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.coralGlow.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
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
      onTap: _isLoading ? null : _generateRecommendation,
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
        child: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
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
}
