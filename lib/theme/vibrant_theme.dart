import 'package:flutter/material.dart';

class VibrantTheme {
  static const Color primaryColor = Color(0xFFFF6F00); // Vibrant orange
  static const Color backgroundColor = Color(0xFFFBE9E7);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const gradient = LinearGradient(
    colors: [
      Color(0xFFFF6F00),
      Color(0xFFFFA000),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static ThemeData get themeData {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
