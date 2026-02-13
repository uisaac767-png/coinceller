import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../theme/bybit_theme.dart';
import '../services/currency_service.dart';
import '../services/local_storage_service.dart';
import '../services/wallet_service.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/settings_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Currency currency = Currency.usd;
  bool syncing = false;

  @override
  void initState() {
    super.initState();
    loadCurrency();
  }

  void loadCurrency() async {
    try {
      final c = await LocalStorageService.getCurrency();
      if (mounted) {
        setState(() => currency = c);
      }
    } catch (e) {
      // Fallback to USD if loading fails
      if (mounted) {
        setState(() => currency = Currency.usd);
      }
    }
  }

  void changeCurrency(Currency newCurrency) async {
    try {
      await LocalStorageService.setCurrency(newCurrency);
      if (mounted) {
        setState(() => currency = newCurrency);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Currency changed to ${CurrencyService.name(newCurrency)}"),
            backgroundColor: BybitTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to change currency"),
            backgroundColor: BybitTheme.danger,
          ),
        );
      }
    }
  }

  Future<void> logout() async {
    await LocalStorageService.clearUser();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  Future<void> syncNow() async {
    if (syncing) return;
    setState(() => syncing = true);

    String message = "Data synced";
    Color color = BybitTheme.success;

    try {
      await ApiService.getProfile();
      await ApiService.getDashboard();
      await ApiService.getTransactions();
      final walletSync = await WalletService.syncWalletFromBackend();
      if (walletSync != null) {
        message = walletSync;
        color = Colors.orange.shade700;
      }
    } catch (e) {
      message = "Sync failed: $e";
      color = BybitTheme.danger;
    }

    if (!mounted) return;
    setState(() => syncing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User")),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BybitTheme.card,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: BybitTheme.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  "assets/images/profile_icon.png",
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.person,
                      size: 45, color: BybitTheme.gold),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Isaac Uche",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              "isaac@gmail.com",
              style: TextStyle(color: BybitTheme.subText),
            ),

            const SizedBox(height: 22),

            // Currency selector
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Display Currency",
                style: TextStyle(
                  color: BybitTheme.subText,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 10),
            DropdownField<Currency>(
              value: currency,
              items: Currency.values.map((c) {
                return DropdownMenuItem(
                  value: c,
                  child: Text(CurrencyService.name(c)),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) changeCurrency(v);
              },
            ),

            const SizedBox(height: 20),

            ListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => SettingsDialog(
                    onLogout: logout,
                    onSync: syncNow,
                  ),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: BybitTheme.card,
              leading: SizedBox(
                width: 24,
                height: 24,
                child: Image.asset(
                  "assets/images/settings_icon.png",
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.settings, color: BybitTheme.gold),
                ),
              ),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
            const SizedBox(height: 12),
            if (syncing)
              const LinearProgressIndicator(
                minHeight: 3,
                color: BybitTheme.gold,
                backgroundColor: BybitTheme.card2,
              ),
          ],
        ),
      ),
    );
  }
}
