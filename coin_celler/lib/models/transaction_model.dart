class TransactionModel {
  final String id;
  final String type; // Deposit, Send, Receive
  final String coin;
  final double amount;
  final String date;
  final String? address;

  TransactionModel({
    required this.id,
    required this.type,
    required this.coin,
    required this.amount,
    required this.date,
    this.address,
  });
}
