import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';
import 'theme/bybit_theme.dart';

void main() {
  runApp(const CellerApp());
}

class CellerApp extends StatelessWidget {
  const CellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celler',
      debugShowCheckedModeBanner: false,
      theme: BybitTheme.themeData,
      home: const AuthScreen(),
    );
  }
}
