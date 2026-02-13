import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/bybit_theme.dart';
import '../models/transaction_model.dart';
import '../services/wallet_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  Future<void> refreshTransactions() async {
    try {
      final response = await ApiService.getTransactions();
      if (response is List) {
        final parsed = response
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .map(TransactionModel.fromJson)
            .toList();
        if (parsed.isNotEmpty) {
          WalletService.transactions
            ..clear()
            ..addAll(parsed);
        }
      }
    } catch (_) {}
    if (mounted) setState(() {});
  }

  void showReceipt(dynamic t) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: BybitTheme.card,
        title: const Text("Transaction Receipt"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Receipt ID: ${t.id}",
                style: const TextStyle(color: BybitTheme.text)),
            const SizedBox(height: 6),
            Text("Type: ${t.type}",
                style: const TextStyle(color: BybitTheme.subText)),
            Text("Coin: ${t.coin}",
                style: const TextStyle(color: BybitTheme.subText)),
            Text("Amount: ${t.amount}",
                style: const TextStyle(color: BybitTheme.subText)),
            Text("Date: ${t.date}",
                style: const TextStyle(color: BybitTheme.subText)),
            Text(
              "Address: ${t.address ?? 'N/A'}",
              style: const TextStyle(color: BybitTheme.subText),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text("Close", style: TextStyle(color: BybitTheme.gold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final txs = WalletService.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: RefreshIndicator(
        onRefresh: refreshTransactions,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: txs.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(color: BybitTheme.subText),
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: txs.length,
                  itemBuilder: (_, i) {
                    final t = txs[i];
                    final isSend = t.type == "Send";

                    return InkWell(
                      onTap: () => showReceipt(t),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: BybitTheme.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: BybitTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: BybitTheme.card2,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: BybitTheme.border),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  "assets/images/transaction_icon.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => Icon(
                                    isSend
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: isSend
                                        ? BybitTheme.danger
                                        : BybitTheme.success,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${t.type} ${t.coin}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(
                                    t.address != null
                                        ? "To: ${t.address}"
                                        : "Wallet",
                                    style: const TextStyle(
                                        color: BybitTheme.subText,
                                        fontSize: 12),
                                  ),
                                  Text(
                                    "Receipt: ${t.id}",
                                    style: const TextStyle(
                                        color: BybitTheme.subText,
                                        fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${isSend ? "-" : "+"}${t.amount} ${t.coin}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: isSend
                                      ? BybitTheme.danger
                                      : BybitTheme.success),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
