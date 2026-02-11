import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';
import '../widgets/bottom_navigator.dart';
import '../services/wallet_service.dart';
import 'transfer_screen.dart';
import 'transaction_screen.dart';
import 'profile_screen.dart';
import 'deposit_screen.dart';

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
  Future<void> openDeposit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DepositScreen()),
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final totalUsd = WalletService.totalUsd();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Wallet",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: BybitTheme.text)),
            const SizedBox(height: 20),
            Text("\$${totalUsd.toStringAsFixed(2)}",
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: BybitTheme.gold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: openDeposit,
                    child: const Text("Deposit"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TransferScreen()));
                    },
                    child: const Text("Send"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
