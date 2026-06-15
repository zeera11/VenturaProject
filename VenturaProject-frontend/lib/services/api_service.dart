import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Web (Chrome): pakai localhost
  // Android emulator: pakai 10.0.2.2
  // Device fisik: ganti dengan IP komputer kamu di LAN (misal 192.168.1.x)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:3000';
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {}
    return 'http://localhost:3000';
  }

  // ─── Token Management ───────────────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Auth Endpoints ─────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data['access_token'] != null) {
          await saveToken(data['access_token']);
          return {'success': true, ...data};
        }
      }
      return {
        'success': false,
        'message': data['message'] is List
            ? (data['message'] as List).join(', ')
            : (data['message'] ?? 'Login gagal')
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa konek ke server'};
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password, {
    String? profileImagePath,
    Uint8List? profileImageBytes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/auth/register'),
      );
      request.fields['username'] = name;
      request.fields['email'] = email;
      request.fields['password'] = password;

      if (kIsWeb && profileImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profilePicture',
            profileImageBytes,
            filename: 'profile_pic.jpg',
          ),
        );
      } else if (profileImagePath != null && profileImagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            profileImagePath,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, ...data};
      }
      return {
        'success': false,
        'message': data['message'] is List
            ? (data['message'] as List).join(', ')
            : (data['message'] ?? 'Registration failed')
      };
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa konek ke server'};
    }
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true};
      }
      return {'success': false, 'message': 'Gagal kirim email'};
    } catch (e) {
      // Untuk demo: tetap anggap sukses agar flow bisa dilanjutkan
      return {'success': true};
    }
  }

  // ─── Finance Endpoints ──────────────────────────────────────────────────────

  /// Ambil semua data finance (expenses + budgets + summary)
  static Future<Map<String, dynamic>> getFinanceSummary() async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .get(Uri.parse('$baseUrl/finance/summary'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> getFinanceAll() async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .get(Uri.parse('$baseUrl/finance'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false};
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> addExpense({
    required String title,
    required double amount,
    required String category,
    required String date,
  }) async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .post(
            Uri.parse('$baseUrl/finance/expense'),
            headers: headers,
            body: jsonEncode({
              'title': title,
              'amount': amount,
              'category': category,
              'date': date,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false, 'message': 'Gagal tambah pengeluaran'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa konek ke server'};
    }
  }

  static Future<Map<String, dynamic>> addBudget({
    required double totalBudget,
  }) async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .post(
            Uri.parse('$baseUrl/finance/budget'),
            headers: headers,
            body: jsonEncode({'totalBudget': totalBudget}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, 'data': jsonDecode(res.body)};
      }
      return {'success': false, 'message': 'Gagal set budget'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa konek ke server'};
    }
  }

  static Future<bool> deleteExpense(String id) async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .delete(Uri.parse('$baseUrl/finance/expense/$id'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAllExpenses() async {
    try {
      final headers = await _authHeaders();
      final res = await http
          .delete(Uri.parse('$baseUrl/finance/expenses/all'), headers: headers)
          .timeout(const Duration(seconds: 10));
      return res.statusCode == 200 || res.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ─── Profile (local SharedPreferences) ──────────────────────────────────────

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final headers = await _authHeaders();
      debugPrint("ApiService.getProfile: Calling $baseUrl/auth/profile with headers: $headers");
      final res = await http
          .get(Uri.parse('$baseUrl/auth/profile'), headers: headers)
          .timeout(const Duration(seconds: 10));

      debugPrint("ApiService.getProfile: Response status: ${res.statusCode}, body: ${res.body}");
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final String name = data['username'] ?? data['name'] ?? 'Christian Dave';
        final String email = data['email'] ?? 'christiandave@ventura.com';
        final String phone = data['phoneNumber'] ?? data['phone'] ?? '81234567891';
        final String profilePicture = data['profilePicture'] ?? '';
        
        // Cache them locally so we have offline fallback
        await prefs.setString('profile_name', name);
        await prefs.setString('profile_email', email);
        await prefs.setString('profile_phone', phone);
        await prefs.setString('profile_picture', profilePicture);

        return {
          'name': name,
          'email': email,
          'phone': phone,
          'profilePicture': profilePicture,
        };
      } else {
        debugPrint("ApiService.getProfile: Non-200 status code: ${res.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService.getProfile: Exception caught: $e");
    }

    return {
      'name': prefs.getString('profile_name') ?? 'Christian Dave',
      'email': prefs.getString('profile_email') ?? 'christiandave@ventura.com',
      'phone': prefs.getString('profile_phone') ?? '81234567891',
      'profilePicture': prefs.getString('profile_picture') ?? '',
    };
  }

  static Future<bool> saveProfile({
    required String name,
    required String email,
    required String phone,
    String? profileImagePath,
    Uint8List? profileImageBytes,
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse('$baseUrl/auth/profile'),
      );
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['username'] = name;
      request.fields['email'] = email;
      request.fields['phoneNumber'] = phone;

      if (kIsWeb && profileImageBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'profilePicture',
            profileImageBytes,
            filename: 'profile_pic.jpg',
          ),
        );
      } else if (profileImagePath != null && profileImagePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profilePicture',
            profileImagePath,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        // Cache the updated profile locally
        final prefs = await SharedPreferences.getInstance();
        final updatedData = data['data'] ?? data;
        final String updatedName = updatedData['username'] ?? updatedData['name'] ?? name;
        final String updatedEmail = updatedData['email'] ?? email;
        final String updatedPhone = updatedData['phoneNumber'] ?? updatedData['phone'] ?? phone;
        final String updatedPic = updatedData['profilePicture'] ?? '';

        await prefs.setString('profile_name', updatedName);
        await prefs.setString('profile_email', updatedEmail);
        await prefs.setString('profile_phone', updatedPhone);
        if (updatedPic.isNotEmpty) {
          await prefs.setString('profile_picture', updatedPic);
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error updating profile: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 || res.statusCode == 201) {
        return {'success': true, ...data};
      }
      return {'success': false, 'message': data['message'] ?? 'Reset password failed'};
    } catch (e) {
      return {'success': false, 'message': 'Tidak bisa konek ke server'};
    }
  }

  static Future<String?> uploadDestinationPhoto({
    String? filePath,
    Uint8List? bytes,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/travel/upload'),
      );

      if (kIsWeb && bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            bytes,
            filename: 'destination.jpg',
          ),
        );
      } else if (filePath != null && filePath.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            filePath,
          ),
        );
      } else {
        return null;
      }

      final streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      final res = await http.Response.fromStream(streamedResponse);
      
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['filename'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint("Error uploading destination photo: $e");
      return null;
    }
  }
}
