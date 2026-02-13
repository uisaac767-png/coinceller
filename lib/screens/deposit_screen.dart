import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';
import '../services/wallet_service.dart';
import '../theme/bybit_theme.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown_field.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  static const List<String> _coins = ['USDT', 'BTC', 'ETH', 'TRX'];
  final walletAddressController = TextEditingController();
  final amountController = TextEditingController();
  final ApiService apiService = ApiService();
  bool loading = false;
  String selectedCoin = "USDT";

  @override
  void initState() {
    super.initState();
    _loadSavedWallet();
  }

  @override
  void dispose() {
    walletAddressController.dispose();
    amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedWallet() async {
    final saved = await LocalStorageService.getWalletAddress();
    if (saved != null && saved.isNotEmpty && mounted) {
      walletAddressController.text = saved;
    }
  }

  bool _isValidWalletAddress(String address) {
    final tron = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');
    final eth = RegExp(r'^0x[a-fA-F0-9]{40}$');
    return tron.hasMatch(address) || eth.hasMatch(address);
  }

  Future<void> depositNow() async {
    final address = walletAddressController.text.trim();
    final amount = double.tryParse(amountController.text) ?? 0;

    if (address.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid details")),
      );
      return;
    }

    if (!_isValidWalletAddress(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter a valid wallet address (T... or 0x...)"),
        ),
      );
      return;
    }

    setState(() => loading = true);

    String? syncError;
    try {
      await apiService.updateWalletBalance(address, amount, selectedCoin);
    } catch (_) {
      syncError = "Backend sync failed. Local balance updated.";
    }

    WalletService.deposit(selectedCoin, amount);
    await LocalStorageService.setWalletAddress(address);

    if (!mounted) return;
    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(syncError ?? "Deposit successful"),
        backgroundColor:
            syncError == null ? BybitTheme.success : Colors.orange.shade700,
      ),
    );
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              controller: walletAddressController,
              hintText: "Your Wallet Address (T... or 0x...)",
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: amountController,
              hintText: "Amount",
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Deposit",
              loading: loading,
              onPressed: loading ? null : () => depositNow(),
            ),
          ],
        ),
      ),
    );
  }
}
