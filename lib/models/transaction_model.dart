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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'coin': coin,
      'amount': amount,
      'date': date,
      'address': address,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      coin: json['coin']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      date: json['date']?.toString() ?? '',
      address: json['address']?.toString(),
    );
  }
}
