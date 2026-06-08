import 'dart:convert';
import 'package:http/http.dart' as http;
import 'secure_storage_service.dart';

class AuthService {
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

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/register',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/auth/login',
      ),
      headers: {
        'Content-Type':
            'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await http.get(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? email,
    String? phoneNumber,
  }) async {
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (email != null) body['email'] = email;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;

    final response = await http.put(
      Uri.parse('$baseUrl/auth/profile'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
}