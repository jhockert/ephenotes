import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/core/constants/app_colors.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  group('AppColors', () {
    test('noteTextColor returns dark text for light mode for all colors', () {
      for (final color in NoteColor.values) {
        final c = AppColors.noteTextColor(Brightness.light, color);
        expect(c, const Color(0xFF212121));
      }
    });

    test('noteTextColor returns correct text color for dark mode', () {
      final lightLike = {
        NoteColor.classicYellow,
        NoteColor.lemon,
        NoteColor.mintGreen,
        NoteColor.peach,
        NoteColor.lightGray,
      };

      for (final color in NoteColor.values) {
        final c = AppColors.noteTextColor(Brightness.dark, color);
        if (lightLike.contains(color)) {
          expect(c, const Color(0xFF212121));
        } else {
          expect(c, const Color(0xFFE0E0E0));
        }
      }
    });

    test('noteSecondaryTextColor returns expected values in both modes', () {
      final darkLike = {
        NoteColor.classicYellow,
        NoteColor.lemon,
        NoteColor.mintGreen,
        NoteColor.peach,
        NoteColor.lightGray,
      };

      for (final color in NoteColor.values) {
        final secondaryDark =
            AppColors.noteSecondaryTextColor(Brightness.dark, color);
        final secondaryLight =
            AppColors.noteSecondaryTextColor(Brightness.light, color);

        if (darkLike.contains(color)) {
          expect(secondaryDark, const Color(0xFF424242));
        } else {
          expect(secondaryDark, const Color(0xFFBDBDBD));
        }

        expect(secondaryLight, const Color(0xFF757575));
      }
    });
  });
}
