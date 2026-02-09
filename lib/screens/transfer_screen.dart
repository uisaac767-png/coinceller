import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../services/wallet_service.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final amountController = TextEditingController();
  final walletController = TextEditingController();

  String selectedCoin = "USDT";
  final coins = ["USDT", "BTC", "ETH", "TRON"];

  void sendNow() {
    final address = walletController.text.trim();
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter recipient wallet address"),
          backgroundColor: BybitTheme.danger,
        ),
      );
      return;
    }

    final ok = WalletService.transfer(selectedCoin, amount, address);

    // ❌ insufficient
    if (!ok) {
      final current = WalletService.coinBalances[selectedCoin] ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Insufficient Balance! You have only $current $selectedCoin",
          ),
          backgroundColor: BybitTheme.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sent $amount $selectedCoin successfully"),
        backgroundColor: BybitTheme.success,
      ),
    );

    amountController.clear();
    walletController.clear();

    setState(() {}); // refresh balance on this screen
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletService.coinBalances[selectedCoin] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Transfer")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            DropdownField<String>(
              value: selectedCoin,
              items: coins
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => selectedCoin = v ?? "USDT"),
            ),
            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Available: $balance $selectedCoin",
                style: const TextStyle(
                  color: BybitTheme.subText,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 14),
            CustomTextField(
              controller: walletController,
              hintText: "Recipient Wallet Address",
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: amountController,
              hintText: "Amount ($selectedCoin)",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: "Send $selectedCoin",
              onPressed: sendNow,
            ),
          ],
        ),
      ),
    );
  }
}
