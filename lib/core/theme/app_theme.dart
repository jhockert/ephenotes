import 'package:flutter/material.dart';

/// Application theme definitions for light and dark modes.
class AppTheme {
  AppTheme._();

  static final light = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFF59D),
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFFFFFFF),
    cardTheme: const CardThemeData(
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xDD000000)),
      bodySmall: TextStyle(color: Color(0x99000000)),
    ),
  );

  static final dark = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFE082),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardTheme: const CardThemeData(
      elevation: 2,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xDDFFFFFF)),
      bodySmall: TextStyle(color: Color(0x99FFFFFF)),
    ),
  );
}
