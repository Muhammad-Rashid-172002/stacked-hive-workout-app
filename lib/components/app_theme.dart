import 'package:flutter/material.dart';

class AppTheme {
  /// 🎨 Colors
  static const Color jetBlack = Color(0xFF0B0B0D);
  static const Color charcoal = Color(0xFF1A1A1D);
  static const Color surface = Color(0xFF1F1F23);
  static const Color border = Color(0xFF2E2E34);

  static const Color primaryRed = Color(0xFF8B0000);
  static const Color darkRed = Color(0xFF6E0000);
  static const Color accentRed = Color(0xFFA11212);

  static const Color textPrimary = Color(0xFFE0E0E0);
  static const Color textSecondary = Color(0xFF9A9A9A);
  static const Color textMuted = Color(0xFF5C5C5C);

  /// 🌙 Dark Theme
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,

    scaffoldBackgroundColor: jetBlack,

    primaryColor: primaryRed,

    cardColor: surface,

    dividerColor: border,

    appBarTheme: const AppBarTheme(
      backgroundColor: jetBlack,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),

    colorScheme: const ColorScheme.dark(
      primary: primaryRed,
      secondary: accentRed,
      surface: surface,
    ),

    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
      titleLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryRed,
        side: const BorderSide(color: primaryRed),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),

    snackBarTheme: const SnackBarThemeData(
      backgroundColor: surface,
      contentTextStyle: TextStyle(color: textPrimary),
      behavior: SnackBarBehavior.floating,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(primaryRed),
      trackColor: MaterialStateProperty.all(primaryRed.withOpacity(0.4)),
    ),
  );

  static get errorRed => null;
}
