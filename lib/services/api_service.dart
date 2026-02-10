import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:celler/models/transaction_model.dart';

class ApiService {
  // 🔥 CHANGE THIS TO YOUR RENDER BACKEND
  static const String _baseUrl = 'https://celler-backend.onrender.com/api';

  // FLASH CRYPTO
  Future<dynamic> flashCrypto(TransactionModel transaction) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/crypto/flash'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'address': transaction.address,
        'amount': transaction.amount,
        'currency': transaction.coin,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to process crypto');
    }
  }

  // GET WALLET BALANCE
  Future<dynamic> getWalletBalance(String address) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/crypto/balance/$address'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get wallet balance');
    }
  }

  // TRANSFER CRYPTO
  Future<dynamic> transferCrypto(
      String fromAddress,
      String toAddress,
      double amount,
      String currency) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/crypto/transfer'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'fromAddress': fromAddress,
        'toAddress': toAddress,
        'amount': amount,
        'currency': currency,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to transfer crypto');
    }
  }

  // LOGIN
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://celler-backend.onrender.com/api/auth/login'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // SIGNUP
  static Future<bool> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('https://celler-backend.onrender.com/api/auth/signup'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}
