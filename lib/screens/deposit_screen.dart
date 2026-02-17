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
  static const List<String> _coins = ['USDT', 'BTC', 'ETH', 'TRX', 'SOL'];
  static const List<String> _usdtNetworks = ['ERC20', 'BEP20', 'TRC20'];
  final walletAddressController = TextEditingController();
  final amountController = TextEditingController();
  final ApiService apiService = ApiService();
  bool loading = false;
  bool useGenerated = true;
  bool generating = false;
  String selectedNetwork = "ERC20";
  String selectedCoin = "USDT";

  @override
  void initState() {
    super.initState();
    _loadSavedWallet();
    _loadGeneratedIfNeeded();
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

  Future<void> _loadGeneratedIfNeeded() async {
    if (!useGenerated) return;
    final cached =
        await LocalStorageService.getWalletAddressForCoin(_coinKey());
    if (cached != null && cached.isNotEmpty && mounted) {
      walletAddressController.text = cached;
      return;
    }
    await _refreshGeneratedAddress();
  }

  String _coinKey() {
    if (selectedCoin == "USDT") return "USDT_$selectedNetwork";
    return selectedCoin;
  }

  String? _pickAddress(Map<String, dynamic> wallets) {
    if (selectedCoin == "USDT") {
      if (selectedNetwork == "TRC20") return wallets['tron']?.toString();
      if (selectedNetwork == "BEP20") return wallets['bsc']?.toString();
      return wallets['evm']?.toString();
    }
    if (selectedCoin == "ETH") return wallets['evm']?.toString();
    if (selectedCoin == "TRX") return wallets['tron']?.toString();
    if (selectedCoin == "BTC") return wallets['btc']?.toString();
    if (selectedCoin == "SOL") return wallets['sol']?.toString();
    return null;
  }

  Future<void> _refreshGeneratedAddress() async {
    if (generating) return;
    setState(() => generating = true);
    try {
      final response = await ApiService.getWalletAddresses();
      Map<String, dynamic>? wallets;
      if (response is Map && response['wallets'] is Map) {
        wallets = (response['wallets'] as Map)
            .map((k, v) => MapEntry(k.toString(), v));
      }
      if (wallets == null) {
        final created = await ApiService.generateWalletAddresses();
        if (created is Map && created['wallets'] is Map) {
          wallets = (created['wallets'] as Map)
              .map((k, v) => MapEntry(k.toString(), v));
        }
      }
      if (wallets != null) {
        final address = _pickAddress(wallets) ?? "";
        if (address.isNotEmpty) {
          walletAddressController.text = address;
          await LocalStorageService.setWalletAddressForCoin(
            _coinKey(),
            address,
          );
          await LocalStorageService.setWalletAddress(address);
        }
      }
    } catch (_) {
      // ignore for now
    } finally {
      if (mounted) setState(() => generating = false);
    }
  }

  bool _isValidWalletAddress(String address) {
    final tron = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');
    final eth = RegExp(r'^0x[a-fA-F0-9]{40}$');
    final btc = RegExp(r'^(bc1|tb1|[13mn])[a-zA-HJ-NP-Z0-9]{25,62}$');
    final sol = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
    return tron.hasMatch(address) ||
        eth.hasMatch(address) ||
        btc.hasMatch(address) ||
        sol.hasMatch(address);
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
    await LocalStorageService.setWalletAddressForCoin(_coinKey(), address);

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
                _loadGeneratedIfNeeded();
              },
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Switch(
                  value: useGenerated,
                  onChanged: (v) async {
                    setState(() => useGenerated = v);
                    if (useGenerated) {
                      await _loadGeneratedIfNeeded();
                    }
                  },
                ),
                const SizedBox(width: 6),
                Text(
                  "Use generated testnet address",
                  style: TextStyle(
                    color: BybitTheme.subText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (selectedCoin == "USDT")
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    "USDT Network",
                    style: TextStyle(color: BybitTheme.subText, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  DropdownField<String>(
                    value: selectedNetwork,
                    items: _usdtNetworks
                        .map((n) => DropdownMenuItem(
                              value: n,
                              child: Text(n),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => selectedNetwork = v);
                      _loadGeneratedIfNeeded();
                    },
                  ),
                ],
              ),
            const SizedBox(height: 14),
            CustomTextField(
              controller: walletAddressController,
              hintText: "Your Wallet Address (T... or 0x...)",
              readOnly: useGenerated,
            ),
            if (useGenerated)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: TextButton(
                  onPressed: generating ? null : _refreshGeneratedAddress,
                  child: Text(
                    generating ? "Generating..." : "Regenerate address",
                    style: TextStyle(color: BybitTheme.gold),
                  ),
                ),
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
