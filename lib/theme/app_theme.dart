import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFFEFF7E6);
  static const Color primary = Color(0xFF77B255);
  static const Color primaryDark = Color(0xFF4E8E3E);
  static const Color accent = Color(0xFFF7C948);
  static const Color card = Color(0xFFFFFFFF);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Color(0xFF1F2D1F),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w800,
          color: Color(0xFF1F2D1F),
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xFF1F2D1F),
        ),
      )
    );
  }
}
