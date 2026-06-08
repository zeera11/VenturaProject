import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class TravelService {
  static const String baseUrl =
      'http://localhost:3000';

  final storage = SecureStorageService();

  Future<Map<String, String>> _headers() async {
    final token = await storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> generateRecommendation({
    required String city,
    required List<String> categories,
    required String activityLevel,
    required int days,
    required double budget,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/travel/recommendation',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'city': city,
        'categories': categories,
        'activityLevel':
            activityLevel,
        'days': days,
        'budget': budget,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> saveItinerary({
    required String city,
    required int days,
    required String itineraryType,
    required Map<String, dynamic> itinerary,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/travel/itinerary'),
      headers: await _headers(),
      body: jsonEncode({
        'city': city,
        'days': days,
        'itineraryType': itineraryType,
        'itinerary': itinerary,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> getSavedItineraries() async {
    final response = await http.get(
      Uri.parse('$baseUrl/travel/itinerary/list'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> updateItinerary({
    required String id,
    required String city,
    required int days,
    required String itineraryType,
    required Map<String, dynamic> itinerary,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/travel/itinerary/$id'),
      headers: await _headers(),
      body: jsonEncode({
        'city': city,
        'days': days,
        'itineraryType': itineraryType,
        'itinerary': itinerary,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> deleteItinerary(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/travel/itinerary/$id'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }
}