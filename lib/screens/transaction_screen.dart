import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../services/wallet_service.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  Widget build(BuildContext context) {
    final txs = WalletService.transactions;

    return Scaffold(
      appBar: AppBar(title: const Text("Transactions")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: txs.isEmpty
            ? const Center(
                child: Text(
                  "No transactions yet",
                  style: TextStyle(color: BybitTheme.subText),
                ),
              )
            : ListView.builder(
                itemCount: txs.length,
                itemBuilder: (_, i) {
                  final t = txs[i];
                  final isSend = t.type == "Send";
                  final icon = isSend
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded;

                  return Container(
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
                          child: Icon(icon,
                              color: isSend
                                  ? BybitTheme.danger
                                  : BybitTheme.success),
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
                                    color: BybitTheme.subText, fontSize: 12),
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
                  );
                },
              ),
      ),
    );
  }
}
