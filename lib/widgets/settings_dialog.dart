import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';

class SettingsDialog extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onSync;

  const SettingsDialog({
    super.key,
    required this.onLogout,
    required this.onSync,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BybitTheme.card,
      title: const Text("Settings"),
      content: const Text(
        "Manage your account session.",
        style: TextStyle(color: BybitTheme.subText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onSync();
          },
          child: const Text(
            "Sync Data",
            style: TextStyle(color: BybitTheme.success),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onLogout();
          },
          child: const Text(
            "Logout",
            style: TextStyle(color: BybitTheme.danger),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close", style: TextStyle(color: BybitTheme.gold)),
        ),
      ],
    );
  }
}
