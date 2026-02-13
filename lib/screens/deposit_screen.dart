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

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: const Text("Deposit"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Image.asset(
                "assets/images/flash_icon.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.bolt, size: 18),
              ),
            ),
          ),
        ],
      ),
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
