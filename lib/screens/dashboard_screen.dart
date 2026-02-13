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
  bool hardRefreshing = false;

  Future<void> openDeposit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DepositScreen()),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> refreshNow() async {
    final result = await WalletService.refreshFromBackend();
    if (!mounted) return;
    setState(() {});
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Wallet refreshed"),
          backgroundColor: BybitTheme.success,
        ),
      );
    }
  }

  Future<void> hardRefreshNow() async {
    if (hardRefreshing) return;
    setState(() => hardRefreshing = true);
    final result = await WalletService.hardRefresh();
    if (!mounted) return;
    setState(() => hardRefreshing = false);
    setState(() {});

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: Colors.orange.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hard refresh completed"),
          backgroundColor: BybitTheme.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalUsd = WalletService.totalUsd();

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: refreshNow,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text("Wallet",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: BybitTheme.text)),
                  ),
                  IconButton(
                    onPressed: hardRefreshing ? null : hardRefreshNow,
                    icon: hardRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, color: BybitTheme.gold),
                    tooltip: "Hard Refresh",
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  "assets/images/home_banner.png",
                  width: double.infinity,
                  height: 130,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 130,
                    color: BybitTheme.card,
                  ),
                ),
              ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionImage("assets/images/flash_icon.png"),
                          const SizedBox(width: 8),
                          const Text("Deposit"),
                        ],
                      ),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _actionImage("assets/images/send_icon.png"),
                          const SizedBox(width: 8),
                          const Text("Send"),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionImage(String assetPath) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.circle,
          size: 14,
          color: Colors.black54,
        ),
      ),
    );
  }
}
