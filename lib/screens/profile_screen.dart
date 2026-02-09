import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../services/currency_service.dart';
import '../services/local_storage_service.dart';
import '../widgets/dropdown_field.dart';
import '../widgets/settings_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Currency currency = Currency.usd;

  @override
  void initState() {
    super.initState();
    loadCurrency();
  }

  void loadCurrency() async {
    final c = await LocalStorageService.getCurrency();
    setState(() => currency = c);
  }

  void changeCurrency(Currency newCurrency) async {
    await LocalStorageService.setCurrency(newCurrency);
    setState(() => currency = newCurrency);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Currency changed to ${CurrencyService.name(newCurrency)}"),
        backgroundColor: BybitTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
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
              child: const Icon(Icons.person, size: 45, color: BybitTheme.gold),
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
                  builder: (_) => const SettingsDialog(),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              tileColor: BybitTheme.card,
              leading: const Icon(Icons.settings, color: BybitTheme.gold),
              title: const Text("Settings"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            )
          ],
        ),
      ),
    );
  }
}
