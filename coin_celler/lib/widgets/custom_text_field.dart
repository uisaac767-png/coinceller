import 'package:flutter/material.dart';
import '../theme/bybit_theme.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BybitTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: BybitTheme.border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: BybitTheme.text,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: BybitTheme.subText,
            fontSize: 13,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
