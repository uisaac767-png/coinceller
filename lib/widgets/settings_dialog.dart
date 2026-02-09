import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: BybitTheme.card,
      title: const Text("Settings"),
      content: const Text(
        "Settings options will be added here.",
        style: TextStyle(color: BybitTheme.subText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close", style: TextStyle(color: BybitTheme.gold)),
        ),
      ],
    );
  }
}
