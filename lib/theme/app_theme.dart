import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF1E3A8A); // Deep Navy
  static const Color accentGold = Color(0xFFB45309);  // Subtle warm gold
  static const Color bgLight = Color(0xFFF8FAFC);     // Clean off-white
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color borderSubtle = Color(0xFFE2E8F0);
  static const Color textMain = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);

  // Status colors (soft & professional)
  static const Color statusGreenBg = Color(0xFFECFDF5);
  static const Color statusGreenText = Color(0xFF047857);
  static const Color statusGreenBorder = Color(0xFFA7F3D0);

  static const Color statusAmberBg = Color(0xFFFFFBEB);
  static const Color statusAmberText = Color(0xFFB45309);
  static const Color statusAmberBorder = Color(0xFFFDE68A);

  static const Color statusGrayBg = Color(0xFFF8FAFC);
  static const Color statusGrayText = Color(0xFF64748B);
  static const Color statusGrayBorder = Color(0xFFE2E8F0);

  static const Color statusRedBg = Color(0xFFFFF1F2);
  static const Color statusRedText = Color(0xFFBE123C);
  static const Color statusRedBorder = Color(0xFFFECDD3);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: accentGold,
        surface: cardWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: cardWhite,
        foregroundColor: textMain,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textMain,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardTheme(
        color: cardWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: borderSubtle, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
      ),
    );
  }
}
