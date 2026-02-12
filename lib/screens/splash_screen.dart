import 'dart:async';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 120,
          height: 120,
          child: Image.asset(
            "assets/images/logo.png",
            width: 120,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.account_balance_wallet_outlined,
                  size: 80, color: Colors.grey);
            },
          ),
        ),
      ),
    );
  }
}
