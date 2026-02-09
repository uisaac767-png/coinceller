import 'package:flutter/material.dart';

import '../theme/bybit_theme.dart';
import '../widgets/bottom_navigator.dart';

import '../services/currency_service.dart';
import '../services/local_storage_service.dart';
import '../services/wallet_service.dart';

import 'deposit_screen.dart';
import 'transfer_screen.dart';
import 'transaction_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int index = 0;

  final screens = const [
    WalletHome(),
    TransferScreen(),
    TransactionScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigator(
        currentIndex: index,
        onTap: (i) => setState(() => index = i),
      ),
    );
  }
}

class WalletHome extends StatefulWidget {
  const WalletHome({super.key});

  @override
  State<WalletHome> createState() => _WalletHomeState();
}

class _WalletHomeState extends State<WalletHome> {
  Currency currency = Currency.usd;

  @override
  void initState() {
    super.initState();
    loadCurrency();
  }

  Widget _QuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: BybitTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: BybitTheme.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: BybitTheme.text),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  color: BybitTheme.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadCurrency() async {
    final c = await LocalStorageService.getCurrency();
    setState(() => currency = c);
  }

  Future<void> openDeposit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DepositScreen()),
    );

    // if deposit happened, refresh dashboard UI
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsd = WalletService.totalUsd();
    final converted = CurrencyService.convertFromUsd(totalUsd, currency);
    final formatted = CurrencyService.format(converted, currency);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallet",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: BybitTheme.text,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Your assets overview",
                      style: TextStyle(
                        fontSize: 13,
                        color: BybitTheme.subText,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: BybitTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: BybitTheme.border),
                  ),
                  child: const Icon(Icons.notifications_none),
                )
              ],
            ),

            const SizedBox(height: 18),

            // Balance Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B2436), Color(0xFF0F1522)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: BybitTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Balance (${CurrencyService.name(currency)})",
                    style: const TextStyle(
                      color: BybitTheme.subText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatted,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: BybitTheme.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "+ 2.4% today",
                    style: TextStyle(
                      color: BybitTheme.success,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Quick actions
            Row(
              children: [
                _QuickAction(
                  icon: Icons.add_circle_outline,
                  title: "Deposit",
                  onTap: openDeposit, // ✅ now opens deposit screen
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.send_outlined,
                  title: "Send",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransferScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                _QuickAction(
                  icon: Icons.list_alt,
                  title: "Transactions",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TransactionScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Recent transactions header
            const Text(
              "Recent Transactions",
              style: TextStyle(
                color: BybitTheme.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Placeholder for transactions list
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: BybitTheme.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: BybitTheme.border),
                ),
                child: const Center(
                  child: Text(
                    "No transactions yet",
                    style: TextStyle(color: BybitTheme.subText),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
