import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFE9EDF2);
  static const Color accentTeal = Color(0xFF176B5B);
  static const Color accentCyan = Color(0xFF357A78);
  static const Color riskLow = Color(0xFF23835D);
  static const Color riskMedium = Color(0xFFA66A12);
  static const Color riskHigh = Color(0xFFB54242);
  static const Color riskCritical = Color(0xFF8D2828);
  static const Color textPrimary = Color(0xFF1D2935);
  static const Color textSecondary = Color(0xFF5F6B76);
  static const Color textMuted = Color(0xFF818B95);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    primaryColor: accentTeal,
    colorScheme: const ColorScheme.light(
      primary: accentTeal,
      onPrimary: Colors.white,
      secondary: accentCyan,
      surface: surface,
      onSurface: textPrimary,
      error: riskHigh,
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE7EAED)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 19, fontWeight: FontWeight.w700),
      iconTheme: IconThemeData(color: textSecondary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      hintStyle: const TextStyle(color: textMuted, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDE2E6))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFDDE2E6))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: accentTeal, width: 1.5)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentTeal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
