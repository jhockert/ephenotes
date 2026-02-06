import 'package:flutter/material.dart';
import 'package:ephenotes/data/models/note.dart';

/// Centralized color mappings for light and dark modes.
///
/// Note color values come from the design system in SPEC.md.
class AppColors {
  AppColors._();

  // Light mode note colors
  static const _lightColors = <NoteColor, Color>{
    NoteColor.classicYellow: Color(0xFFFFF59D),
    NoteColor.coralPink: Color(0xFFFF8A80),
    NoteColor.skyBlue: Color(0xFF82B1FF),
    NoteColor.mintGreen: Color(0xFFB9F6CA),
    NoteColor.lavender: Color(0xFFE1BEE7),
    NoteColor.peach: Color(0xFFFFCCBC),
    NoteColor.teal: Color(0xFFA7FFEB),
    NoteColor.lightGray: Color(0xFFCFD8DC),
    NoteColor.lemon: Color(0xFFF4FF81),
    NoteColor.rose: Color(0xFFF8BBD0),
  };

  // Dark mode note colors (deeper tones for dark backgrounds)
  static const _darkColors = <NoteColor, Color>{
    NoteColor.classicYellow: Color(0xFFFFE082),
    NoteColor.coralPink: Color(0xFFFF6F60),
    NoteColor.skyBlue: Color(0xFF6699FF),
    NoteColor.mintGreen: Color(0xFF81C784),
    NoteColor.lavender: Color(0xFFCE93D8),
    NoteColor.peach: Color(0xFFFFAB91),
    NoteColor.teal: Color(0xFF64FFDA),
    NoteColor.lightGray: Color(0xFF90A4AE),
    NoteColor.lemon: Color(0xFFE6EE9C),
    NoteColor.rose: Color(0xFFF48FB1),
  };

  /// Returns the Color value for a [NoteColor] based on current [brightness].
  static Color getNoteColor(NoteColor noteColor, Brightness brightness) {
    final palette = brightness == Brightness.dark ? _darkColors : _lightColors;
    return palette[noteColor]!;
  }

  /// Returns the text color to use on a note card based on [brightness] and [noteColor].
  ///
  /// Ensures text is always readable (WCAG AA) in both light and dark mode.
  static Color noteTextColor(Brightness brightness, NoteColor noteColor) {
    if (brightness == Brightness.dark) {
      // For light note colors in dark mode, use dark text
      switch (noteColor) {
        case NoteColor.classicYellow:
        case NoteColor.lemon:
        case NoteColor.mintGreen:
        case NoteColor.peach:
        case NoteColor.lightGray:
          return const Color(0xFF212121); // dark text
        default:
          return const Color(0xFFE0E0E0); // light text
      }
    } else {
      // Always use dark text in light mode
      return const Color(0xFF212121);
    }
  }

  /// Returns the secondary text color (timestamps, labels) for notes.
  static Color noteSecondaryTextColor(
      Brightness brightness, NoteColor noteColor) {
    if (brightness == Brightness.dark) {
      switch (noteColor) {
        case NoteColor.classicYellow:
        case NoteColor.lemon:
        case NoteColor.mintGreen:
        case NoteColor.peach:
        case NoteColor.lightGray:
          return const Color(0xFF424242); // darker secondary text
        default:
          return const Color(0xFFBDBDBD); // light secondary text
      }
    } else {
      return const Color(0xFF757575);
    }
  }
}
