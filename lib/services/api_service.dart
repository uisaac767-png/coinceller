import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const List<String> _defaultBaseUrls = [
    'https://celler-backend.onrender.com/api',
    'http://10.0.2.2:5000/api',
    'http://127.0.0.1:5000/api',
    'http://localhost:5000/api',
  ];
  static List<String> _baseUrls = List<String>.from(_defaultBaseUrls);
  static String _activeBaseUrl = _defaultBaseUrls.first;

  static String get activeBaseUrl => _activeBaseUrl;

  static void configureBaseUrl(String baseUrl) {
    final normalized = _normalizeApiBase(baseUrl);
    if (normalized == null) return;

    final merged = <String>[normalized, ..._defaultBaseUrls];
    _baseUrls = merged.toSet().toList();
    _activeBaseUrl = normalized;
  }

  static String? _normalizeApiBase(String? baseUrl) {
    if (baseUrl == null) return null;
    var value = baseUrl.trim();
    if (value.isEmpty) return null;

    value = value.replaceAll(RegExp(r'\/+$'), '');
    if (!value.endsWith('/api')) {
      value = '$value/api';
    }
    return value;
  }

  // Helper method to handle HTTP errors gracefully
  static void _handleError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrintStack(
          label: 'ApiService Error: $error', stackTrace: stackTrace);
    }
  }

  static Future<http.Response> _post(
    String path, {
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    Object? lastError;
    final tried = <String>{_activeBaseUrl, ..._baseUrls};
    for (final baseUrl in tried) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl$path'),
              headers: {'Content-Type': 'application/json; charset=UTF-8'},
              body: jsonEncode(body),
            )
            .timeout(timeout);
        _activeBaseUrl = baseUrl;
        return response;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'POST request failed');
  }

  static Future<http.Response> _get(
    String path, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    Object? lastError;
    final tried = <String>{_activeBaseUrl, ..._baseUrls};
    for (final baseUrl in tried) {
      try {
        final response =
            await http.get(Uri.parse('$baseUrl$path')).timeout(timeout);
        _activeBaseUrl = baseUrl;
        return response;
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'GET request failed');
  }

  static String _rootFromApiBase(String apiBaseUrl) {
    if (apiBaseUrl.endsWith('/api')) {
      return apiBaseUrl.substring(0, apiBaseUrl.length - 4);
    }
    return apiBaseUrl;
  }

  static Future<dynamic> getServerStatus() async {
    Object? lastError;
    final tried = <String>{_activeBaseUrl, ..._baseUrls};
    for (final apiBase in tried) {
      final root = _rootFromApiBase(apiBase);
      try {
        final response = await http
            .get(Uri.parse('$root/'))
            .timeout(const Duration(seconds: 30));
        if (response.statusCode == 200) {
          _activeBaseUrl = apiBase;
          return jsonDecode(response.body);
        }
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Failed to get server status');
  }

  Future<dynamic> flashCrypto(TransactionModel transaction) async {
    try {
      final response = await _post(
        '/crypto/flash',
        body: {
          'address': transaction.address,
          'amount': transaction.amount,
          'currency': transaction.coin,
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to process crypto');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> getWalletBalance(String address) async {
    try {
      final response = await _get('/crypto/balance/$address');
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
      var response = await _post(
        '/transfer',
        body: {
          'fromAddress': fromAddress,
          'toAddress': toAddress,
          'amount': amount,
          'currency': currency,
        },
      );

      if (response.statusCode != 200) {
        // Backend also exposes /crypto/transfer in cryptoRoutes.
        response = await _post(
          '/crypto/transfer',
          body: {
            'fromAddress': fromAddress,
            'toAddress': toAddress,
            'amount': amount,
            'currency': currency,
          },
        );
      }

      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to transfer crypto');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> updateWalletBalance(
      String address, double amount, String currency) async {
    try {
      final response = await _post(
        '/crypto/updateBalance',
        body: {
          'address': address,
          'amount': amount,
          'currency': currency,
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to update wallet balance');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> sendUsdt(Map<String, dynamic> payload) async {
    try {
      final response = await _post('/crypto/sendUSDT', body: payload);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to call sendUSDT');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  Future<dynamic> sendTrx(Map<String, dynamic> payload) async {
    try {
      final response = await _post('/crypto/sendTRX', body: payload);
      if (response.statusCode == 200) return jsonDecode(response.body);
      throw Exception('Failed to call sendTRX');
    } catch (e, st) {
      _handleError(e, st);
      rethrow;
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await _post(
        '/auth/login',
        body: {'email': email, 'password': password},
      );
      return response.statusCode == 200;
    } catch (e, st) {
      _handleError(e, st);
      return false;
    }
  }

  static Future<String?> signup(
      String username, String email, String password) async {
    final payload = {
      'username': username,
      'email': email,
      'password': password,
    };

    try {
      late http.Response response;
      var lastError = '';
      var success = false;

      for (var attempt = 1; attempt <= 2; attempt++) {
        try {
          response = await _post(
            '/auth/register',
            body: payload,
            timeout: const Duration(seconds: 60),
          );
          success = true;
          break;
        } catch (e) {
          lastError = e.toString();
          if (attempt == 1) {
            await Future<void>.delayed(const Duration(seconds: 2));
          }
        }
      }

      if (!success) {
        if (lastError.contains('TimeoutException') ||
            lastError.toLowerCase().contains('timed out')) {
          return 'Server is taking too long. Wait 30-60 seconds and try again.';
        }
        return 'Could not reach server. Check internet/server and try again.';
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      return _extractErrorMessage(response.body) ??
          'Signup failed (${response.statusCode})';
    } catch (e, st) {
      _handleError(e, st);
      return 'Could not reach server. Check internet/server and try again.';
    }
  }

  static Future<dynamic> getDashboard() async {
    final response = await _get('/dashboard');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load dashboard');
  }

  static Future<dynamic> getTransactions() async {
    final response = await _get('/transaction');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load transactions');
  }

  static Future<dynamic> getProfile() async {
    final response = await _get('/profile');
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Failed to load profile');
  }

  static String? _extractErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['message'] ?? decoded['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
    } catch (_) {}
    return null;
  }
}
