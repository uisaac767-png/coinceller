import 'dart:async';

import '../models/transaction_model.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

class WalletService {
  static const Map<String, double> _defaultCoinBalances = {
    "USDT": 1240.20,
    "BTC": 0.015,
    "ETH": 0.60,
    "TRX": 800.0,
  };

  // coin balances
  static final Map<String, double> coinBalances =
      Map<String, double>.from(_defaultCoinBalances);

  // coin price in USD (for total balance calculation)
  static final Map<String, double> coinPriceUsd = {
    "USDT": 1.0,
    "BTC": 45000.0,
    "ETH": 2400.0,
    "TRX": 0.12,
  };

  // Transactions store
  static final List<TransactionModel> transactions = [];

  static Future<void> initialize() async {
    final storedBalances = await LocalStorageService.getCoinBalances();
    if (storedBalances != null && storedBalances.isNotEmpty) {
      if (storedBalances.containsKey('TRON') &&
          !storedBalances.containsKey('TRX')) {
        storedBalances['TRX'] = storedBalances['TRON'] ?? 0;
      }
      coinBalances
        ..clear()
        ..addAll(storedBalances);
    }

    final storedTransactions = await LocalStorageService.getTransactions();
    transactions
      ..clear()
      ..addAll(storedTransactions);
  }

  static void _persistState() {
    unawaited(LocalStorageService.saveCoinBalances(coinBalances));
    unawaited(LocalStorageService.saveTransactions(transactions));
  }

  static Future<String?> syncWalletFromBackend({
    String coin = 'USDT',
  }) async {
    final address = await LocalStorageService.getWalletAddress();
    if (address == null || address.trim().isEmpty) {
      return 'No wallet address saved yet.';
    }

    try {
      final api = ApiService();
      final response = await api.getWalletBalance(address.trim());

      if (response is Map<String, dynamic>) {
        final balanceField = response['balance'];

        if (balanceField is num) {
          coinBalances[coin] = balanceField.toDouble();
          _persistState();
          return null;
        }

        if (balanceField is Map) {
          balanceField.forEach((key, value) {
            if (value is num) {
              final k = key.toString().toUpperCase();
              if (coinBalances.containsKey(k)) {
                coinBalances[k] = value.toDouble();
              }
            }
          });
          _persistState();
          return null;
        }
      }

      return 'Unexpected wallet balance response.';
    } catch (e) {
      return 'Wallet sync failed: $e';
    }
  }

  static Future<String?> refreshFromBackend() async {
    try {
      await ApiService.getServerStatus();
      await ApiService.getDashboard();
      await ApiService.getProfile();
      final txResponse = await ApiService.getTransactions();
      if (txResponse is List) {
        final parsed = txResponse
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .map(TransactionModel.fromJson)
            .toList();
        if (parsed.isNotEmpty) {
          transactions
            ..clear()
            ..addAll(parsed);
          _persistState();
        }
      }
      await syncWalletFromBackend();
      return null;
    } catch (e) {
      return 'Refresh failed: $e';
    }
  }

  static Future<String?> hardRefresh() async {
    try {
      final refreshResult = await refreshFromBackend();
      await initialize();
      return refreshResult;
    } catch (e) {
      return 'Hard refresh failed: $e';
    }
  }

  // Total wallet USD value
  static double totalUsd() {
    double total = 0;
    coinBalances.forEach((coin, amount) {
      total += amount * (coinPriceUsd[coin] ?? 0);
    });
    return total;
  }

  // Deposit coin
  static bool deposit(String coin, double amount) {
    if (amount <= 0) return false;

    coinBalances[coin] = (coinBalances[coin] ?? 0) + amount;

    transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: "Deposit",
        coin: coin,
        amount: amount,
        date: DateTime.now().toString(),
      ),
    );

    _persistState();
    return true;
  }

  // Transfer coin
  static bool transfer(String coin, double amount, String toAddress) {
    if (amount <= 0) return false;

    final currentBalance = coinBalances[coin] ?? 0;

    // ❌ insufficient
    if (amount > currentBalance) return false;

    // deduct
    coinBalances[coin] = currentBalance - amount;

    transactions.insert(
      0,
      TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: "Send",
        coin: coin,
        amount: amount,
        date: DateTime.now().toString(),
        address: toAddress,
      ),
    );

    _persistState();
    return true;
  }
}
