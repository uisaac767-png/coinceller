import 'package:flutter/material.dart';

class BybitTheme {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121826);
  static const Color card2 = Color(0xFF0F1522);
  static const Color gold = Color(0xFFF5C542);
  static const Color text = Color(0xFFE8EDF2);
  static const Color subText = Color(0xFF98A2B3);
  static const Color border = Color(0xFF1F2A37);
  static const Color danger = Color(0xFFFF4D4F);
  static const Color success = Color(0xFF2ECC71);

  static ThemeData themeData = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: text,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: text),
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: text),
    ),
  );
}
