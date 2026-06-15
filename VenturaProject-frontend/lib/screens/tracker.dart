import 'dart:convert';
import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  String selectedCategory = "All";
  bool _isLoading = true;
  bool _isRefreshing = false;

  // Finance data
  double _totalBudget = 0;
  double _totalSpent = 0;
  double _remainingBudget = 0;
  double _percentageUsed = 0;
  String _status = 'SAFE';
  List<Map<String, dynamic>> _expenses = [];

  // Controllers untuk Add Expense form
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedAddCategory = 'Transport';

  // Dummy fallback data (dipakai kalau API tidak konek)
  final List<Map<String, dynamic>> _dummyExpenses = [];

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showSetBudgetDialog() {
    final controller = TextEditingController(text: _totalBudget.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Set Budget",
          style: TextStyle(
            fontFamily: 'Chango',
            fontSize: 18,
            color: AppColors.deepOcean,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            hintText: "Enter budget amount in Rp",
            hintStyle: TextStyle(fontFamily: 'Poppins'),
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              final newBudget = double.tryParse(controller.text.trim()) ?? 0;
              if (newBudget > 0) {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                
                final prefs = await SharedPreferences.getInstance();
                await prefs.setDouble('user_budget', newBudget);
                
                final result = await ApiService.addBudget(totalBudget: newBudget);
                await _loadFinanceData();
              }
            },
            child: const Text("Save", style: TextStyle(color: AppColors.deepOcean)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadFinanceData() async {
    if (!_isRefreshing) setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final double userBudget = prefs.getDouble('user_budget') ?? 0.0;
    final bool isFirstLoginEmpty = prefs.getBool('is_first_login_empty') ?? true;

    final result = await ApiService.getFinanceAll();

    if (result['success'] == true) {
      final data = result['data'] as Map<String, dynamic>;
      final rawExpenses = (data['expenses'] as List? ?? [])
          .cast<Map<String, dynamic>>();

      setState(() {
        _totalBudget = (data['totalBudget'] as num?)?.toDouble() ?? 0;
        if (_totalBudget == 0) {
          _totalBudget = userBudget;
        }
        _totalSpent = (data['totalSpent'] as num?)?.toDouble() ?? 0;
        _remainingBudget = _totalBudget - _totalSpent;
        _percentageUsed = _totalBudget > 0
            ? (_totalSpent / _totalBudget) * 100
            : 0;
        _status = data['status'] ?? 'SAFE';
        _expenses = rawExpenses.map((e) {
          final cat = e['category'] ?? 'Other';
          return {
            "id": e['id'] ?? '',
            "category": cat,
            "title": e['title'] ?? 'Expense',
            "time": e['createdAt'] != null
                ? e['createdAt'].toString().substring(11, 16)
                : '--:--',
            "amount": (e['amount'] as num?)?.toDouble() ?? 0,
            "color": _colorForCategory(cat),
            "icon": _iconForCategory(cat),
            "date": "Recent",
          };
        }).toList();
        _isLoading = false;
        _isRefreshing = false;
      });
    } else {
      // Fallback
      final localExpensesJson = prefs.getStringList('local_expenses') ?? [];
      final List<Map<String, dynamic>> loadedExpenses = [];
      for (var jsonStr in localExpensesJson) {
        try {
          final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(jsonStr));
          final cat = map['category'] ?? 'Other';
          map['color'] = _colorForCategory(cat);
          map['icon'] = _iconForCategory(cat);
          loadedExpenses.add(map);
        } catch (e) {
          debugPrint("Error decoding local expense: $e");
        }
      }

      setState(() {
        _totalBudget = userBudget;
        if (isFirstLoginEmpty) {
          _totalSpent = 0;
          _remainingBudget = userBudget;
          _percentageUsed = 0;
          _status = 'SAFE';
          _expenses = [];
        } else {
          _expenses = loadedExpenses;
          final totalSpent = _expenses.fold<double>(
            0,
            (s, e) => s + ((e['amount'] as num).toDouble()),
          );
          _totalSpent = totalSpent;
          _remainingBudget = userBudget - totalSpent;
          _percentageUsed = userBudget > 0
              ? (totalSpent / userBudget) * 100
              : 0;
          _status = _totalSpent > userBudget
              ? 'OVER'
              : _totalSpent > userBudget * 0.8
                  ? 'WARNING'
                  : 'SAFE';
        }
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _deleteExpense(String id, double amount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Delete Expense",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: AppColors.deepOcean,
          ),
        ),
        content: const Text(
          "Are you sure you want to delete this expense?",
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isRefreshing = true);

              final isLocal = id.startsWith('local_') || id.isEmpty;
              bool success = false;
              if (isLocal) {
                success = true;
              } else {
                success = await ApiService.deleteExpense(id);
              }

              if (success) {
                setState(() {
                  _expenses.removeWhere((e) => e['id'] == id);
                  _totalSpent -= amount;
                  _remainingBudget += amount;
                  _percentageUsed = _totalBudget > 0
                      ? (_totalSpent / _totalBudget) * 100
                      : 0;
                  _status = _totalSpent > _totalBudget
                      ? 'OVER'
                      : _totalSpent > _totalBudget * 0.8
                          ? 'WARNING'
                          : 'SAFE';
                });

                // Update SharedPreferences local_expenses
                final prefs = await SharedPreferences.getInstance();
                final List<String> updatedLocal = _expenses.map((e) {
                  final copy = Map<String, dynamic>.from(e);
                  copy.remove('color');
                  copy.remove('icon');
                  return jsonEncode(copy);
                }).toList();
                await prefs.setStringList('local_expenses', updatedLocal);
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Failed to delete expense from server")),
                  );
                }
              }
              setState(() => _isRefreshing = false);
            },
            child: const Text(
              "Delete",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'transport':
        return const Color(0xFFFFECC0);
      case 'food':
        return const Color(0xFFABE1E1);
      case 'activities':
        return const Color(0xFFFA855A);
      case 'accomodation':
      case 'accommodation':
        return const Color(0xFF4A97CB);
      default:
        return const Color(0xFFD4C5F9);
    }
  }

  IconData _iconForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'transport':
        return Icons.directions_bus_filled;
      case 'food':
        return Icons.restaurant;
      case 'activities':
        return Icons.fitness_center;
      case 'accomodation':
      case 'accommodation':
        return Icons.hotel;
      default:
        return Icons.receipt_long;
    }
  }

  String _formatRp(double amount) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    String formatted;
    if (absAmount >= 1000000) {
      final m = absAmount / 1000000;
      formatted = 'Rp ${m.toStringAsFixed(m == m.truncate() ? 0 : 1)}M';
    } else if (absAmount >= 1000) {
      formatted = 'Rp ${(absAmount / 1000).truncate()}K';
    } else {
      formatted = 'Rp ${absAmount.truncate()}';
    }
    return isNegative ? '-$formatted' : formatted;
  }

  void _showAddExpenseSheet() {
    _titleController.clear();
    _amountController.clear();
    _selectedAddCategory = 'Transport';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(30, 25, 30, 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'Add Expense',
                  style: TextStyle(
                    fontFamily: 'Chango',
                    fontSize: 24,
                    color: AppColors.deepOcean,
                  ),
                ),
                const SizedBox(height: 25),

                // Title field
                _sheetField('Title / Description', _titleController),
                const SizedBox(height: 15),

                // Amount field
                _sheetField(
                  'Amount (Rp)',
                  _amountController,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 15),

                // Category dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedAddCategory,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.deepOcean,
                      ),
                      items: [
                        'Transport',
                        'Food',
                        'Accomodation',
                        'Activities',
                        'Other',
                      ]
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                      onChanged: (v) {
                        setSheetState(
                          () => _selectedAddCategory = v ?? 'Transport',
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit button
                GestureDetector(
                  onTap: () async {
                    final title = _titleController.text.trim();
                    final amount =
                        double.tryParse(_amountController.text.trim()) ?? 0;
                    if (title.isEmpty || amount <= 0) return;

                    Navigator.pop(ctx);
                    setState(() => _isRefreshing = true);

                    final result = await ApiService.addExpense(
                      title: title,
                      amount: amount,
                      category: _selectedAddCategory,
                      date: DateTime.now().toIso8601String(),
                    );

                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('is_first_login_empty', false);

                    if (result['success'] == true) {
                      await _loadFinanceData();
                    } else {
                      // Fallback: tambah ke list lokal saja
                      final newExpense = {
                        "id": 'local_${DateTime.now().millisecondsSinceEpoch}',
                        "category": _selectedAddCategory,
                        "title": title,
                        "time": "${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}",
                        "amount": amount,
                        "color": _colorForCategory(_selectedAddCategory),
                        "icon": _iconForCategory(_selectedAddCategory),
                        "date": "Today",
                      };

                      setState(() {
                        _expenses.insert(0, newExpense);
                        _totalSpent += amount;
                        _remainingBudget -= amount;
                        _percentageUsed = _totalBudget > 0
                            ? (_totalSpent / _totalBudget) * 100
                            : 0;
                        _status = _totalSpent > _totalBudget
                            ? 'OVER'
                            : _totalSpent > _totalBudget * 0.8
                                ? 'WARNING'
                                : 'SAFE';
                        _isRefreshing = false;
                      });

                      // Save to SharedPreferences (strip out non-encodable objects first)
                      final List<String> updatedLocal = _expenses.map((e) {
                        final copy = Map<String, dynamic>.from(e);
                        copy.remove('color');
                        copy.remove('icon');
                        return jsonEncode(copy);
                      }).toList();
                      await prefs.setStringList('local_expenses', updatedLocal);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      color: AppColors.deepOcean,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text(
                        'Add Expense',
                        style: TextStyle(
                          fontFamily: 'Chango',
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
    String hint,
    TextEditingController ctrl, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: AppColors.deepOcean,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontFamily: 'Poppins',
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenses = _expenses.where((e) {
      return selectedCategory == "All" ||
          e['category'] == selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.clouds,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseSheet,
        backgroundColor: AppColors.deepOcean,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.bluebird,
        onRefresh: () async {
          _isRefreshing = true;
          await _loadFinanceData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _buildHeader(context),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _isLoading
                        ? _buildSkeletonBudget()
                        : _buildBudgetOverviewCard(),
                    const SizedBox(height: 30),
                    _buildCategoryTabs(),
                    const SizedBox(height: 30),
                    if (_isLoading)
                      _buildSkeletonList()
                    else if (filteredExpenses.isEmpty)
                      _buildEmptyState()
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Transactions",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.deepOcean,
                                  fontSize: 14,
                                ),
                              ),
                              if (_isRefreshing)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.bluebird,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          ...filteredExpenses.map(
                            (item) => _buildTransactionItem(
                              item['id'] ?? '',
                              item['category'],
                              item['title'],
                              item['time'],
                              item['amount'],
                              item['color'],
                              item['icon'],
                              item['date'],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.elliptical(250, 40),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
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
                      Icons.arrow_back_rounded,
                      color: AppColors.deepOcean,
                      size: 24,
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      "Expense Tracker",
                      style: TextStyle(
                        fontFamily: 'Chango',
                        fontSize: 22,
                        color: AppColors.deepOcean,
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _getCategoryAllocation(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return 0.20;
      case 'food':
        return 0.30;
      case 'accomodation':
      case 'accommodation':
        return 0.15;
      case 'activities':
        return 0.30;
      case 'other':
      default:
        return 0.05;
    }
  }

  Widget _buildBudgetOverviewCard() {
    double displayBudget;
    double displaySpent;
    double displayRemaining;
    double displayPercentage;
    String displayStatus;

    if (selectedCategory == "All") {
      displayBudget = _totalBudget;
      displaySpent = _totalSpent;
      displayRemaining = _remainingBudget;
      displayPercentage = _percentageUsed;
      displayStatus = _status;
    } else {
      final allocation = _getCategoryAllocation(selectedCategory);
      displayBudget = _totalBudget * allocation;
      
      // Calculate spent for selectedCategory
      displaySpent = _expenses
          .where((e) => e['category'].toString().toLowerCase() == selectedCategory.toLowerCase())
          .fold<double>(0.0, (sum, e) => sum + ((e['amount'] as num?)?.toDouble() ?? 0.0));
          
      displayRemaining = displayBudget - displaySpent;
      displayPercentage = displayBudget > 0
          ? (displaySpent / displayBudget) * 100
          : 0.0;
          
      displayStatus = displaySpent > displayBudget
          ? 'OVER'
          : displaySpent > displayBudget * 0.8
              ? 'WARNING'
              : 'SAFE';
    }

    final pct = displayPercentage.clamp(0, 100) / 100;
    final statusColor = displayStatus == 'OVER'
        ? const Color(0xFFCA3537)
        : displayStatus == 'WARNING'
            ? const Color(0xFFFA855A)
            : AppColors.bluebird;

    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: selectedCategory == "All" ? _showSetBudgetDialog : null,
                  child: Row(
                    children: [
                      Text(
                        selectedCategory == "All"
                            ? "Total Budget"
                            : "$selectedCategory Budget",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppColors.deepOcean,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (selectedCategory == "All")
                        const Icon(
                          Icons.edit,
                          size: 13,
                          color: AppColors.bluebird,
                        ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: selectedCategory == "All" ? _showSetBudgetDialog : null,
                  child: Text(
                    _formatRp(displayBudget),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      color: AppColors.deepOcean,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _budgetMiniInfo(
                      "Spent",
                      _formatRp(displaySpent),
                      const Color(0xFFCA3537),
                    ),
                    const SizedBox(width: 20),
                    _budgetMiniInfo(
                      "Remaining",
                      _formatRp(displayRemaining),
                      displayRemaining < 0 ? const Color(0xFFCA3537) : AppColors.bluebird,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 85,
                width: 85,
                child: CircularProgressIndicator(
                  value: pct.toDouble(),
                  strokeWidth: 9,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${displayPercentage.toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    "of budget\nused",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _budgetMiniInfo(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: color,
          ),
        ),
      ],
    );
  }

  // ─── Skeleton Loading ────────────────────────────────────────────────────────

  Widget _buildSkeletonBudget() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmer(w: 100, h: 14),
                const SizedBox(height: 8),
                _shimmer(w: 140, h: 22),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _shimmer(w: 70, h: 30),
                    const SizedBox(width: 20),
                    _shimmer(w: 80, h: 30),
                  ],
                ),
              ],
            ),
          ),
          _shimmer(w: 85, h: 85, radius: 42.5),
        ],
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              _shimmer(w: 50, h: 50, radius: 25),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmer(w: double.infinity, h: 14),
                    const SizedBox(height: 6),
                    _shimmer(w: 100, h: 10),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              _shimmer(w: 80, h: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmer({
    required double w,
    required double h,
    double radius = 8,
  }) {
    return Container(
      width: w == double.infinity ? null : w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 60,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 15),
            const Text(
              "No expenses yet",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w700,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      "All",
      "Transport",
      "Food",
      "Accomodation",
      "Activities",
    ];
    return Container(
      height: 45,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [const BoxShadow(color: Colors.black12, blurRadius: 4)]
                    : [],
              ),
              child: Center(
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.deepOcean : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(
    String id,
    String cat,
    String title,
    String time,
    dynamic amount,
    Color iconBg,
    IconData icon,
    String date,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: iconBg.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.deepOcean, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        cat,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: AppColors.deepOcean,
                        ),
                      ),
                    ),
                    const Text(
                      "  •  ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatRp((amount as num).toDouble()),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w900,
              fontSize: 13,
              color: AppColors.deepOcean,
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _deleteExpense(id, (amount as num).toDouble()),
            child: Icon(
              Icons.delete_outline,
              color: Colors.grey.shade600,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
