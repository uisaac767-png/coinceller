import 'package:flutter/material.dart';
import '../services/wallet_service.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final amountController = TextEditingController();
  String selectedCoin = "USDT";

  void depositNow() {
    final amount = double.tryParse(amountController.text) ?? 0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid amount")),
      );
      return;
    }

    WalletService.deposit(selectedCoin, amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deposit")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: depositNow,
              child: const Text("Deposit"),
            )
          ],
        ),
      ),
    );
  }
}
