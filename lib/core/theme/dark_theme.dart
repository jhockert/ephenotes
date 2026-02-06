import 'package:flutter/material.dart';

class DarkTheme {
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xDDFFFFFF)),
      bodySmall: TextStyle(color: Color(0x99FFFFFF)),
    ),
    // Add other theme properties as needed
  );
}
