import 'dart:convert';
import 'package:http/http.dart' as http;

import 'secure_storage_service.dart';

class FinanceService {
  static const String baseUrl =
      'http://localhost:3000';

  final storage =
      SecureStorageService();

  Future<Map<String, String>>
      _headers() async {
    final token =
        await storage.getToken();

    return {
      'Content-Type':
          'application/json',
      'Authorization':
          'Bearer $token',
    };
  }

  Future<dynamic> addExpense({
    required String title,
    required double amount,
    required String category,
    required String date,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/finance/expense',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> updateExpense({
    required String id,
    required String title,
    required double amount,
    required String category,
    required String date,
  }) async {
    final response = await http.put(
      Uri.parse(
        '$baseUrl/finance/expense/$id',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'title': title,
        'amount': amount,
        'category': category,
        'date': date,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> deleteExpense({
    required String id,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/finance/expense/$id',
      ),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> addBudget({
    required double totalBudget,
  }) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/finance/budget',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'totalBudget': totalBudget,
      }),
    );

    return jsonDecode(response.body);
  }

  Future<dynamic> getFinance() async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/finance',
      ),
      headers: await _headers(),
    );

    return jsonDecode(response.body);
  }
}