import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';

class BottomNavigator extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavigator({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: BybitTheme.card2,
        border: Border(top: BorderSide(color: BybitTheme.border)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: BybitTheme.card2,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedItemColor: BybitTheme.gold,
        unselectedItemColor: BybitTheme.subText,
        items: [
          BottomNavigationBarItem(
            icon: _navIcon("assets/images/wallet_icon.png"),
            label: "Wallet",
          ),
          BottomNavigationBarItem(
            icon: _navIcon("assets/images/send_icon.png"),
            label: "Transfer",
          ),
          BottomNavigationBarItem(
            icon: _navIcon("assets/images/transaction_icon.png"),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: _navIcon("assets/images/profile_icon.png"),
            label: "Profile",
          ),
        ],
      ),
    );
  }

  Widget _navIcon(String assetPath) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.circle, size: 18, color: BybitTheme.subText),
      ),
    );
  }
}
