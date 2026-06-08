class AppState {
  static bool isLoggedIn = false;
  static String? username;
  static String? userEmail;
  static String? userId;
  static String? token;
  
  // Stores the active itinerary data returned by the backend
  static Map<String, dynamic>? activeItinerary;
  
  // Active travel budget
  static double? activeBudget;

  // Stores local mock expenses for demo mode
  static List<Map<String, dynamic>> mockExpenses = [];

  // Clear session on logout
  static void clear() {
    isLoggedIn = false;
    username = null;
    userEmail = null;
    userId = null;
    token = null;
    activeItinerary = null;
    activeBudget = null;
    mockExpenses.clear();
  }
}
