import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';
import '../services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  String selectedCoin = "USDT";
  final amountController = TextEditingController();
  final coins = ["USDT", "BTC", "ETH", "TRON"];

  void depositNow() {
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    final ok = WalletService.deposit(selectedCoin, amount);

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid deposit amount"),
          backgroundColor: BybitTheme.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Deposited $amount $selectedCoin successfully"),
        backgroundColor: BybitTheme.success,
      ),
    );

    Navigator.pop(context, true); // return true to refresh dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit")),
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
            const SizedBox(height: 14),
            CustomTextField(
              controller: amountController,
              hintText: "Enter amount ($selectedCoin)",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            CustomButton(
              text: "Deposit $selectedCoin",
              onPressed: depositNow,
            ),
          ],
        ),
      ),
    );
  }
}
