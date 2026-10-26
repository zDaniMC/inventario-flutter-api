import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primario = Color(0xFF1E5AA8);

  static ThemeData get claro {
    final esquema = ColorScheme.fromSeed(seedColor: primario);
    return ThemeData(
      useMaterial3: true,
      colorScheme: esquema,
      scaffoldBackgroundColor: const Color(0xFFF4F6FA),
      appBarTheme: AppBarTheme(
        backgroundColor: esquema.primary,
        foregroundColor: esquema.onPrimary,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
