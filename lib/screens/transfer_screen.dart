import 'package:flutter/material.dart';
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

  void sendNow() {
    final amount = double.tryParse(amountController.text) ?? 0;
    final address = walletController.text.trim();

    if (address.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid details")),
      );
      return;
    }

    WalletService.transfer(selectedCoin, amount, address);
    amountController.clear();
    walletController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletService.coinBalances[selectedCoin] ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text("Transfer")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Balance: $balance $selectedCoin"),
            TextField(
              controller: walletController,
              decoration:
                  const InputDecoration(labelText: "Recipient Address"),
            ),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendNow,
              child: const Text("Send"),
            )
          ],
        ),
      ),
    );
  }
}
