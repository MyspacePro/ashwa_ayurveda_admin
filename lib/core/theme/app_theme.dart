import 'package:flutter/material.dart';

class AppTheme {
  // =========================
  // COLORS
  // =========================

  // DARK THEME COLORS
  static const Color darkBackground = Color(0xFF0B0F1A); // deep navy
  static const Color darkSurface = Color(0xFF121A2A);
  static const Color darkCard = Color(0xFF1A2333);

  static const Color primaryPurple = Color(0xFF6C3EF5);
  static const Color deepPurple = Color(0xFF3B1B7A);

  static const Color accentBlue = Color(0xFF3A7BD5);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B8C5);

  // LIGHT THEME COLORS
  static const Color lightBackground = Color(0xFFF7F8FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF1F3F8);

  static const Color lightPrimary = Color(0xFF6C3EF5);
  static const Color lightAccent = Color(0xFF3A7BD5);

  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLightGrey = Color(0xFF6B7280);

  // =========================
  // DARK THEME
  // =========================
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBackground,
    primaryColor: primaryPurple,

    colorScheme: const ColorScheme.dark(
      primary: primaryPurple,
      secondary: accentBlue,
      surface: darkSurface,
      background: darkBackground,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textWhite,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textWhite),
    ),

    cardColor: darkCard,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textWhite),
      bodyMedium: TextStyle(color: textGrey),
      titleLarge: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textWhite),
    ),

    buttonTheme: const ButtonThemeData(
      buttonColor: primaryPurple,
      textTheme: ButtonTextTheme.primary,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurface,
      hintStyle: const TextStyle(color: textGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );

  // =========================
  // LIGHT THEME
  // =========================
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: lightBackground,
    primaryColor: lightPrimary,

    colorScheme: const ColorScheme.light(
      primary: lightPrimary,
      secondary: lightAccent,
      surface: lightSurface,
      background: lightBackground,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: lightSurface,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textDark,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: textDark),
    ),

    cardColor: lightCard,

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textDark),
      bodyMedium: TextStyle(color: textLightGrey),
      titleLarge: TextStyle(color: textDark, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: textDark),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: textLightGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
  );
}