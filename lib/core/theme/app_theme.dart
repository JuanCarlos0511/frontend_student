/// App-wide color palette and ThemeData.
///
/// Colors follow the university brand: red / white / black.
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ─── Brand colours ──────────────────────────────────────────────
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color darkRed = Color(0xFFB71C1C);
  static const Color darkText = Color(0xFF212121);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFF9E9E9E);
  static const Color errorRed = Color(0xFFB71C1C);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color pendingAmber = Color(0xFFFFB300);

  // ─── ThemeData ──────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: primaryRed,
        onPrimary: white,
        secondary: darkText,
        onSecondary: white,
        surface: white,
        onSurface: darkText,
        error: errorRed,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          foregroundColor: white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryRed,
          minimumSize: const Size(double.infinity, 52),
          side: const BorderSide(color: primaryRed, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryRed,
          textStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryRed, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorRed, width: 1)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorRed, width: 2)),
        hintStyle: const TextStyle(color: mediumGrey),
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}
