import 'package:flutter/material.dart';
import 'theme/bybit_theme.dart';
import 'screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Celler Wallet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: BybitTheme.gold,
        scaffoldBackgroundColor: BybitTheme.background,
        colorScheme: ColorScheme.fromSeed(seedColor: BybitTheme.gold),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: BybitTheme.text),
        ),
      ),
      home: const AuthScreen(), // Entry point is AuthScreen
    );
  }
}
