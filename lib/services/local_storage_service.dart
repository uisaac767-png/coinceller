import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'currency_service.dart';
import '../models/transaction_model.dart';

class LocalStorageService {
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _currencyKey = 'saved_currency';
  static const String _walletAddressKey = 'saved_wallet_address';
  static const String _walletAddressesKey = 'saved_wallet_addresses';
  static const String _authTokenKey = 'auth_token';
  static const String _profileKey = 'profile_info';
  static const String _balancesKey = 'saved_coin_balances';
  static const String _transactionsKey = 'saved_transactions';

  static String? _savedEmail;
  static String? _savedPassword;
  static String? _savedWalletAddress;
  static String? _authToken;
  static Map<String, String>? _walletAddresses;
  static Map<String, String>? _profile;

  static Currency _currency = Currency.usd;

  static Future<void> saveUser(String email, String password) async {
    _savedEmail = email;
    _savedPassword = password;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  static Future<bool> validateUser(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    _savedEmail ??= prefs.getString(_emailKey);
    _savedPassword ??= prefs.getString(_passwordKey);
    return _savedEmail == email && _savedPassword == password;
  }

  static Future<void> clearUser() async {
    _savedEmail = null;
    _savedPassword = null;
    _authToken = null;
    _profile = null;
    _walletAddresses = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_authTokenKey);
    await prefs.remove(_profileKey);
    await prefs.remove(_walletAddressesKey);
  }

  static Future<void> setCurrency(Currency currency) async {
    _currency = currency;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, currency.name);
  }

  static Future<Currency> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_currencyKey);
    if (saved != null) {
      _currency = Currency.values.firstWhere(
        (c) => c.name == saved,
        orElse: () => Currency.usd,
      );
    }
    return _currency;
  }

  static Future<void> setWalletAddress(String address) async {
    _savedWalletAddress = address;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_walletAddressKey, address);
  }

  static Future<String?> getWalletAddress() async {
    if (_savedWalletAddress != null && _savedWalletAddress!.isNotEmpty) {
      return _savedWalletAddress;
    }
    final prefs = await SharedPreferences.getInstance();
    _savedWalletAddress = prefs.getString(_walletAddressKey);
    return _savedWalletAddress;
  }

  static Future<void> setWalletAddressForCoin(
      String coinKey, String address) async {
    final prefs = await SharedPreferences.getInstance();
    _walletAddresses ??= {};
    _walletAddresses![coinKey] = address;
    await prefs.setString(_walletAddressesKey, jsonEncode(_walletAddresses));
  }

  static Future<String?> getWalletAddressForCoin(String coinKey) async {
    if (_walletAddresses != null && _walletAddresses!.containsKey(coinKey)) {
      return _walletAddresses![coinKey];
    }
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_walletAddressesKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    _walletAddresses = decoded.map((k, v) => MapEntry(k, v.toString()));
    return _walletAddresses![coinKey];
  }

  static Future<void> setAuthToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
  }

  static Future<String?> getAuthToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString(_authTokenKey);
    return _authToken;
  }

  static Future<void> setProfileInfo(
      String username, String displayName, String email) async {
    _profile = {
      'username': username,
      'displayName': displayName,
      'email': email,
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(_profile));
  }

  static Future<Map<String, String>?> getProfileInfo() async {
    if (_profile != null) return _profile;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;
    _profile = decoded.map((k, v) => MapEntry(k, v.toString()));
    return _profile;
  }

  static Future<void> saveCoinBalances(Map<String, double> balances) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_balancesKey, jsonEncode(balances));
  }

  static Future<Map<String, double>?> getCoinBalances() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_balancesKey);
    if (raw == null || raw.isEmpty) return null;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return null;

    final result = <String, double>{};
    decoded.forEach((key, value) {
      result[key] = (value as num).toDouble();
    });
    return result;
  }

  static Future<void> saveTransactions(List<TransactionModel> txs) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = txs.map((t) => t.toJson()).toList();
    await prefs.setString(_transactionsKey, jsonEncode(payload));
  }

  static Future<List<TransactionModel>> getTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_transactionsKey);
    if (raw == null || raw.isEmpty) return [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .map(TransactionModel.fromJson)
        .toList();
  }
}
