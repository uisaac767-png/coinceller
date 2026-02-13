import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const String _baseUrl = 'https://celler-backend.onrender.com/api';

  // Helper method to handle HTTP errors gracefully
  static void _handleError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrintStack(
          label: 'ApiService Error: $error', stackTrace: stackTrace);
    }
  }

  Future<dynamic> flashCrypto(TransactionModel transaction) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/crypto/flash'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'address': transaction.address,
              'amount': transaction.amount,
              'currency': transaction.coin,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to process crypto');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> getWalletBalance(String address) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/crypto/balance/$address'))
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to get wallet balance');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> transferCrypto(String fromAddress, String toAddress,
      double amount, String currency) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/crypto/transfer'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'fromAddress': fromAddress,
              'toAddress': toAddress,
              'amount': amount,
              'currency': currency,
            }),
          )
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to transfer crypto');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 30));
      return response.statusCode == 200;
    } catch (e, st) {
      _handleError(e, st);
      return false;
    }
  }

  static Future<bool> signup(
      String username, String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/auth/register'),
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({
              'username': username,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 30));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e, st) {
      _handleError(e, st);
      return false;
    }
  }
}
