import '../models/transaction_model.dart';

class WalletService {
  // coin balances
  static final Map<String, double> coinBalances = {
    "USDT": 1240.20,
    "BTC": 0.015,
    "ETH": 0.60,
    "TRON": 800.0,
  };

  // coin price in USD (for total balance calculation)
  static final Map<String, double> coinPriceUsd = {
    "USDT": 1.0,
    "BTC": 45000.0,
    "ETH": 2400.0,
    "TRON": 0.12,
  };

  // Transactions store
  static final List<TransactionModel> transactions = [];

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

    return true;
  }
}
