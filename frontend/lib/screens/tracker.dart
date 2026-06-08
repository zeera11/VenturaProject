import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../services/finance_service.dart';
import '../utils/app_state.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  final FinanceService _financeService = FinanceService();

  double _totalBudget = 7500000;
  double _totalSpent = 0;
  List<Map<String, dynamic>> _expenses = [];
  bool _isLoading = false;

  final List<String> _categories = ["All", "Transport", "Food", "Accommodation", "Attraction", "Other"];
  String _selectedCategoryFilter = "All";

  @override
  void initState() {
    super.initState();
    _loadFinanceData();
  }

  // Prepulates mock expenses if none exist in demo mode
  void _initializeMockExpensesIfEmpty() {
    if (AppState.mockExpenses.isEmpty) {
      AppState.mockExpenses = [
        {
          "title": "Taxi",
          "amount": 250000.0,
          "category": "Transport",
          "date": "Today",
          "time": "09:30"
        },
        {
          "title": "Lunch",
          "amount": 150000.0,
          "category": "Food",
          "date": "Today",
          "time": "12:45"
        },
        {
          "title": "Snorkeling",
          "amount": 450000.0,
          "category": "Attraction",
          "date": "Today",
          "time": "15:20"
        },
        {
          "title": "Hotel Room",
          "amount": 1200000.0,
          "category": "Accommodation",
          "date": "Yesterday",
          "time": "14:00"
        },
        {
          "title": "Dinner",
          "amount": 350000.0,
          "category": "Food",
          "date": "Yesterday",
          "time": "19:30"
        }
      ];
    }
  }

  Future<void> _loadFinanceData() async {
    // Check if the user is in demo mode
    if (AppState.token == "mock_token" || !AppState.isLoggedIn) {
      _initializeMockExpensesIfEmpty();
      setState(() {
        _totalBudget = AppState.activeBudget ?? 7500000;
        _expenses = List<Map<String, dynamic>>.from(AppState.mockExpenses);
        _calculateTotals();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _financeService.getFinance();
      if (response != null) {
        // Set budget from backend, fallback to local activeBudget or default
        double budgetVal = 7500000;
        final budgetsList = response['budgets'] as List<dynamic>? ?? [];
        if (budgetsList.isNotEmpty) {
          budgetVal = double.tryParse(budgetsList.last['totalBudget']?.toString() ?? '') ?? 7500000;
        } else if (AppState.activeBudget != null) {
          budgetVal = AppState.activeBudget!;
        }

        // Map backend expenses
        final rawExpenses = response['expenses'] as List<dynamic>? ?? [];
        final List<Map<String, dynamic>> mappedExpenses = rawExpenses.map((e) {
          return {
            "id": e['id']?.toString() ?? '',
            "title": e['title']?.toString() ?? 'Expense',
            "amount": double.tryParse(e['amount']?.toString() ?? '0') ?? 0.0,
            "category": e['category']?.toString() ?? 'Other',
            "date": e['date']?.toString() ?? 'Today',
            "time": "12:00" // Simple default time
          };
        }).toList();

        setState(() {
          _totalBudget = double.tryParse(response['totalBudget']?.toString() ?? '') ?? budgetVal;
          _totalSpent = double.tryParse(response['totalSpent']?.toString() ?? '') ?? 0.0;
          _expenses = mappedExpenses;
        });
      }
    } catch (e) {
      debugPrint("Failed to load backend finance: $e");
      // Fallback to local mocks
      _initializeMockExpensesIfEmpty();
      setState(() {
        _totalBudget = AppState.activeBudget ?? 7500000;
        _expenses = List<Map<String, dynamic>>.from(AppState.mockExpenses);
        _calculateTotals();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotals() {
    double spent = 0;
    for (var exp in _expenses) {
      spent += exp['amount'] as double;
    }
    _totalSpent = spent;
  }

  void _showExpenseOptions(Map<String, dynamic> expense) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.deepOcean),
                title: const Text('Edit Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showEditExpenseDialog(expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Expense', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('Confirm Delete'),
                      content: const Text('Are you sure you want to delete this expense?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(c, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    setState(() => _isLoading = true);
                    try {
                      final id = expense['id']?.toString() ?? '';
                      if (AppState.token == "mock_token" || !AppState.isLoggedIn) {
                        // Mock Mode
                        AppState.mockExpenses.remove(expense);
                      } else {
                        // Backend Mode
                        await _financeService.deleteExpense(id: id);
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense deleted successfully!')),
                      );
                      _loadFinanceData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete expense: $e')),
                      );
                      setState(() => _isLoading = false);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditExpenseDialog(Map<String, dynamic> expense) {
    final titleController = TextEditingController(text: expense['title']);
    final amountController = TextEditingController(text: expense['amount'].toString());
    String selectedCat = expense['category'];

    const validCats = ["Transport", "Food", "Accommodation", "Attraction", "Other"];
    if (!validCats.contains(selectedCat)) {
      selectedCat = "Other";
    }

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: const Text(
                'Edit Expense',
                style: TextStyle(fontFamily: 'Chango', color: AppColors.deepOcean, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expense Name", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "e.g., Taxi to Airport",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Amount (Rp)", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g., 150000",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Category", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCat,
                          isExpanded: true,
                          items: validCats.map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCat = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluebird,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final amtStr = amountController.text.trim();

                    if (title.isEmpty || amtStr.isEmpty || double.tryParse(amtStr) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid inputs')),
                      );
                      return;
                    }

                    final double amount = double.parse(amtStr);
                    Navigator.pop(ctx);

                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      final id = expense['id']?.toString() ?? '';
                      if (AppState.token == "mock_token" || !AppState.isLoggedIn) {
                        expense['title'] = title;
                        expense['amount'] = amount;
                        expense['category'] = selectedCat;
                      } else {
                        await _financeService.updateExpense(
                          id: id,
                          title: title,
                          amount: amount,
                          category: selectedCat,
                          date: expense['date'] ?? 'Today',
                        );
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense updated successfully!')),
                      );
                      await _loadFinanceData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update expense: $e')),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getStatus() {
    if (_totalBudget <= 0) return "Safe";
    final ratio = _totalSpent / _totalBudget;
    if (ratio <= 0.8) {
      return "Safe";
    } else if (ratio <= 1.0) {
      return "Warning";
    } else {
      return "Over Budget";
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Safe":
        return const Color(0xFF61C4DB); // Dynamic brand cyan
      case "Warning":
        return const Color(0xFFFFB300); // Amber warning
      case "Over Budget":
      default:
        return const Color(0xFFCA3537); // Crimson over budget
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return Icons.directions_bus_filled;
      case 'food':
      case 'food & drinks':
        return Icons.restaurant;
      case 'accommodation':
      case 'accomodation':
        return Icons.hotel;
      case 'attraction':
      case 'activities':
        return Icons.fitness_center;
      case 'other':
      default:
        return Icons.shopping_bag;
    }
  }

  Color _getCategoryIconBg(String category) {
    switch (category.toLowerCase()) {
      case 'transport':
        return const Color(0xFFFFECC0);
      case 'food':
      case 'food & drinks':
        return const Color(0xFFABE1E1);
      case 'accommodation':
      case 'accomodation':
        return const Color(0xFF4A97CB);
      case 'attraction':
      case 'activities':
        return const Color(0xFFFA855A);
      default:
        return const Color(0xFFE0E0E0);
    }
  }

  // Opens modal dialog to log a new travel expense
  void _showAddExpenseDialog() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCat = "Food";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              title: const Text(
                'Add Expense',
                style: TextStyle(fontFamily: 'Chango', color: AppColors.deepOcean, fontSize: 18),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Expense Name", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: "e.g., Taxi to Airport",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Amount (Rp)", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "e.g., 150000",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text("Category", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCat,
                          isExpanded: true,
                          items: ["Transport", "Food", "Accommodation", "Attraction", "Other"].map((cat) {
                            return DropdownMenuItem(value: cat, child: Text(cat));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                selectedCat = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.bluebird,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    final title = titleController.text.trim();
                    final amtStr = amountController.text.trim();

                    if (title.isEmpty || amtStr.isEmpty || double.tryParse(amtStr) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter valid inputs')),
                      );
                      return;
                    }

                    final double amount = double.parse(amtStr);
                    final now = DateTime.now();
                    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

                    Navigator.pop(ctx);

                    // Add loading status
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      if (AppState.token == "mock_token" || !AppState.isLoggedIn) {
                        // Mock Mode: Save locally
                        AppState.mockExpenses.insert(0, {
                          "title": title,
                          "amount": amount,
                          "category": selectedCat,
                          "date": "Today",
                          "time": timeStr
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense logged locally')),
                        );
                      } else {
                        // Backend Mode: Post to API
                        await _financeService.addExpense(
                          title: title,
                          amount: amount,
                          category: selectedCat,
                          date: "${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}",
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Expense uploaded successfully!')),
                        );
                      }
                      
                      // Refresh financial data
                      await _loadFinanceData();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add expense: $e')),
                      );
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  child: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _getStatus();
    final statusColor = _getStatusColor(status);
    final ratio = _totalBudget > 0 ? (_totalSpent / _totalBudget).clamp(0.0, 1.0) : 0.0;
    final int percentUsed = (ratio * 100).round();

    // Format currencies
    final formatBudget = "Rp. ${_formatCurrency(_totalBudget)}";
    final formatSpent = "Rp. ${_formatCurrency(_totalSpent)}";
    final formatRemaining = "Rp. ${_formatCurrency((_totalBudget - _totalSpent).clamp(0.0, double.infinity))}";

    // Filter expenses based on selected tab
    final filteredExpenses = _expenses.where((exp) {
      if (_selectedCategoryFilter == "All") return true;
      return exp['category']?.toString().toLowerCase() == _selectedCategoryFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.clouds,
      body: RefreshIndicator(
        onRefresh: _loadFinanceData,
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
                    _buildBudgetOverviewCard(formatBudget, formatSpent, formatRemaining, ratio, percentUsed, status, statusColor),
                    const SizedBox(height: 30),
                    _buildCategoryTabs(),
                    const SizedBox(height: 30),
                    
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: CircularProgressIndicator(color: AppColors.deepOcean),
                        ),
                      )
                    else if (filteredExpenses.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            "No expenses logged in this category",
                            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Logged Expenses",
                            style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, color: AppColors.deepOcean, fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          ...filteredExpenses.map((exp) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => _showExpenseOptions(exp),
                              child: _buildTransactionItem(
                                exp['category'] ?? 'Other',
                                exp['title'] ?? 'Expense',
                                exp['time'] ?? '12:00',
                                "Rp. ${_formatCurrency(exp['amount'])}",
                                _getCategoryIconBg(exp['category'] ?? 'Other'),
                                _getCategoryIcon(exp['category'] ?? 'Other'),
                              ),
                            );
                          }),
                        ],
                      ),
                    
                    const SizedBox(height: 120), // Spacer for nav bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.deepOcean,
        onPressed: _showAddExpenseDialog,
        child: const Icon(Icons.add_card, color: Colors.white, size: 28),
      ),
    );
  }

  String _formatCurrency(double amt) {
    try {
      final int val = amt.round();
      final str = val.toString();
      final buffer = StringBuffer();
      int count = 0;
      for (int i = str.length - 1; i >= 0; i--) {
        buffer.write(str[i]);
        count++;
        if (count == 3 && i > 0) {
          buffer.write('.');
          count = 0;
        }
      }
      return buffer.toString().split('').reversed.join('');
    } catch (e) {
      return amt.toStringAsFixed(0);
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 160,
          decoration: const BoxDecoration(
            color: AppColors.brandBlue,
            borderRadius: BorderRadius.vertical(bottom: Radius.elliptical(250, 40)),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.deepOcean, size: 24),
                ),
                const Text(
                  "Expense Tracker",
                  style: TextStyle(fontFamily: 'Chango', fontSize: 22, color: AppColors.deepOcean),
                ),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
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

  Widget _buildBudgetOverviewCard(
    String budget,
    String spent,
    String remaining,
    double ratio,
    int percentUsed,
    String status,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Total Budget", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.deepOcean)),
                Text(budget, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.deepOcean)),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _budgetMiniInfo("Spent", spent, const Color(0xFFCA3537)),
                    const SizedBox(width: 15),
                    _budgetMiniInfo("Remaining", remaining, AppColors.bluebird),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.speed, color: Colors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 95, width: 95,
                child: CircularProgressIndicator(
                  value: ratio,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("$percentUsed%", style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 16)),
                  const Text("of budget\nused", textAlign: TextAlign.center, style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, height: 1.0)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _budgetMiniInfo(String label, String amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        Text(amount, style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 11, color: color)),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 44,
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.04), borderRadius: BorderRadius.circular(15)),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategoryFilter == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryFilter = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.all(5),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)] : [],
              ),
              child: Center(
                child: Text(
                  cat, 
                  style: TextStyle(
                    fontFamily: 'Poppins', 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold, 
                    color: isSelected ? AppColors.deepOcean : Colors.grey
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(String cat, String sub, String time, String price, Color iconBg, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            height: 48, width: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.deepOcean, size: 22),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(cat, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.deepOcean)),
                    const Text("  •  ", style: TextStyle(color: Colors.grey)),
                    Expanded(
                      child: Text(
                        sub, 
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)
                      ),
                    ),
                  ],
                ),
                Text(time, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(price, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.deepOcean)),
        ],
      ),
    );
  }
}