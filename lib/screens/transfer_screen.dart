import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/wallet_service.dart';
import '../theme/bybit_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  static const List<String> _coins = ['USDT', 'BTC', 'ETH', 'TRX'];
  final senderWalletController = TextEditingController();
  final amountController = TextEditingController();
  final recipientWalletController = TextEditingController();
  final ApiService apiService = ApiService();
  bool loading = false;
  String selectedCoin = "USDT";

  @override
  void initState() {
    super.initState();
    _loadSavedWallet();
  }

  Future<void> _loadSavedWallet() async {
    final saved = await LocalStorageService.getWalletAddress();
    if (saved != null && saved.isNotEmpty && mounted) {
      senderWalletController.text = saved;
    }
  }

  @override
  void dispose() {
    senderWalletController.dispose();
    amountController.dispose();
    recipientWalletController.dispose();
    super.dispose();
  }

  bool _isValidWalletAddress(String address) {
    final tron = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');
    final eth = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return tron.hasMatch(address) || eth.hasMatch(address);
  }

  Future<bool> _walletExists(String address) async {
    try {
      final result = await apiService.getWalletBalance(address);
      if (result is Map && result.containsKey('balance')) {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> sendNow() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    final senderAddress = senderWalletController.text.trim();
    final recipientAddress = recipientWalletController.text.trim();

    if (senderAddress.isEmpty || recipientAddress.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid details")),
      );
      return;
    }

    if (!_isValidWalletAddress(senderAddress)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Enter your real wallet address before transaction (T... or 0x...)"),
        ),
      );
      return;
    }

    if (!_isValidWalletAddress(recipientAddress)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong recipient address. Use a valid wallet address."),
        ),
      );
      return;
    }

    setState(() => loading = true);

    final senderExists = await _walletExists(senderAddress);
    if (!senderExists) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your wallet address does not exist on network."),
        ),
      );
      return;
    }

    final recipientExists = await _walletExists(recipientAddress);
    if (!recipientExists) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wrong address: recipient wallet does not exist."),
        ),
      );
      return;
    }

    try {
      await apiService.transferCrypto(
        senderAddress,
        recipientAddress,
        amount,
        selectedCoin,
      );

      final ok = WalletService.transfer(selectedCoin, amount, recipientAddress);
      if (!mounted) return;
      setState(() => loading = false);

      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Insufficient balance")),
        );
        return;
      }

      await LocalStorageService.setWalletAddress(senderAddress);
      amountController.clear();
      recipientWalletController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer successful")),
      );
      setState(() {});
    } catch (_) {
      if (!mounted) return;
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Transfer failed. Check wallet details.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = WalletService.coinBalances[selectedCoin] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transfer"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 20,
              height: 20,
              child: Image.asset(
                "assets/images/send_icon.png",
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.send, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Balance: $balance $selectedCoin",
              style: const TextStyle(
                color: BybitTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Select Coin",
              style: TextStyle(color: BybitTheme.subText, fontSize: 13),
            ),
            const SizedBox(height: 8),
            DropdownField<String>(
              value: selectedCoin,
              items: _coins
                  .map((coin) =>
                      DropdownMenuItem(value: coin, child: Text(coin)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => selectedCoin = v);
              },
            ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: senderWalletController,
              hintText: "Your Wallet Address (T... or 0x...)",
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: recipientWalletController,
              hintText: "Recipient Wallet Address",
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: amountController,
              hintText: "Amount",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Send",
              loading: loading,
              onPressed: loading ? null : () => sendNow(),
            ),
          ],
        ),
      ),
    );
  }
}
