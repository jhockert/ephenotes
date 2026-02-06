import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/core/utils/contrast_checker.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  group('Accessibility Helper Tests', () {
    test('should generate correct semantic label for note card', () {
      final note = Note(
        id: '1',
        content: 'Test note content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.high,
        iconCategory: IconCategory.work,
        isPinned: true,
        isArchived: false,
      );

      final label = AccessibilityHelper.getNoteCardSemanticLabel(note);

      expect(label, contains('Note: Test note content'));
      expect(label, contains('Priority: High'));
      expect(label, contains('Pinned'));
      expect(label, contains('Category: Work'));
    });

    test('should generate correct semantic label for priority selector', () {
      final label =
          AccessibilityHelper.getPrioritySemanticLabel(NotePriority.high, true);

      expect(label, equals('High priority, selected'));
    });

    test('should generate correct semantic label for color picker', () {
      final label = AccessibilityHelper.getColorSemanticLabel(
          NoteColor.classicYellow, false);

      expect(label, equals('Classic Yellow color, not selected'));
    });

    test('should generate correct semantic label for icon selector', () {
      final label =
          AccessibilityHelper.getIconSemanticLabel(IconCategory.work, true);

      expect(label, equals('Work icon, selected'));
    });

    test('should generate correct semantic label for null icon', () {
      final label = AccessibilityHelper.getIconSemanticLabel(null, false);

      expect(label, equals('No icon, not selected'));
    });

    test('should generate correct character counter semantic label', () {
      final label =
          AccessibilityHelper.getCharacterCounterSemanticLabel(135, 140);

      expect(label, contains('5 characters remaining'));
      expect(label, contains('135 of 140 characters used'));
    });

    test('should generate correct character limit reached label', () {
      final label =
          AccessibilityHelper.getCharacterCounterSemanticLabel(140, 140);

      expect(label, contains('Character limit reached'));
    });

    test('should generate correct formatting semantic label', () {
      final boldLabel =
          AccessibilityHelper.getFormattingSemanticLabel('Bold', true);
      final italicLabel =
          AccessibilityHelper.getFormattingSemanticLabel('Italic', false);

      expect(boldLabel, equals('Bold formatting enabled'));
      expect(italicLabel, equals('Italic formatting disabled'));
    });

    test('should generate correct theme toggle semantic label', () {
      final lightLabel =
          AccessibilityHelper.getThemeToggleSemanticLabel(ThemeMode.light);
      final darkLabel =
          AccessibilityHelper.getThemeToggleSemanticLabel(ThemeMode.dark);
      final systemLabel =
          AccessibilityHelper.getThemeToggleSemanticLabel(ThemeMode.system);

      expect(lightLabel, contains('Theme mode: Light'));
      expect(darkLabel, contains('Theme mode: Dark'));
      expect(systemLabel, contains('Theme mode: System'));
    });
  });

  group('Contrast Checker Tests', () {
    test('should calculate correct contrast ratio', () {
      final blackOnWhite =
          ContrastChecker.getContrastRatio(Colors.black, Colors.white);
      final whiteOnBlack =
          ContrastChecker.getContrastRatio(Colors.white, Colors.black);

      expect(blackOnWhite, closeTo(21.0, 0.1));
      expect(whiteOnBlack, closeTo(21.0, 0.1));
    });

    test('should identify WCAG AA compliant combinations', () {
      // High contrast combinations should pass
      expect(ContrastChecker.meetsWCAGAANormalText(Colors.black, Colors.white),
          isTrue);
      expect(ContrastChecker.meetsWCAGAANormalText(Colors.white, Colors.black),
          isTrue);

      // Low contrast combinations should fail
      expect(
          ContrastChecker.meetsWCAGAANormalText(
              Colors.grey[300]!, Colors.white),
          isFalse);
      expect(
          ContrastChecker.meetsWCAGAANormalText(
              Colors.grey[700]!, Colors.black),
          isFalse);
    });

    test('should identify WCAG AA compliant large text combinations', () {
      // Medium contrast should pass for large text
      final mediumGray = Colors.grey[600]!;
      expect(ContrastChecker.meetsWCAGAALargeText(mediumGray, Colors.white),
          isTrue);
    });

    test('should get correct WCAG compliance level', () {
      final highContrast =
          ContrastChecker.getWCAGLevel(Colors.black, Colors.white);
      final mediumContrast =
          ContrastChecker.getWCAGLevel(Colors.grey[600]!, Colors.white);
      final lowContrast =
          ContrastChecker.getWCAGLevel(Colors.grey[300]!, Colors.white);

      expect(highContrast, equals('AAA'));
      expect(mediumContrast, equals('AA'));
      expect(lowContrast, equals('Fail'));
    });

    test('should suggest accessible foreground colors', () {
      // Should return original color if already compliant
      final compliantColor = ContrastChecker.suggestAccessibleForeground(
          Colors.black, Colors.white);
      expect(compliantColor, equals(Colors.black));

      // Should suggest alternative for non-compliant combinations
      final suggestedColor = ContrastChecker.suggestAccessibleForeground(
          Colors.grey[300]!, Colors.white);
      expect(suggestedColor, isNot(equals(Colors.grey[300]!)));
    });

    test('should validate app color combinations', () {
      final results = ContrastChecker.validateAppColors();

      // All results should be present
      expect(results.containsKey('Light mode - Primary text on white'), isTrue);
      expect(results.containsKey('Dark mode - Primary text on dark'), isTrue);
      expect(results.containsKey('High priority badge - White text on red'),
          isTrue);
      expect(
          results.containsKey('Medium priority badge - White text on orange'),
          isTrue);
      expect(results.containsKey('Low priority badge - White text on green'),
          isTrue);

      // Priority badges should be compliant
      expect(results['High priority badge - White text on red'], isTrue);
      expect(results['Medium priority badge - White text on orange'], isTrue);
      expect(results['Low priority badge - White text on green'], isTrue);
    });
  });

  group('Accessibility Integration Tests', () {
    test('should provide comprehensive accessibility for all note properties',
        () {
      final note = Note(
        id: '1',
        content:
            'A very long note content that exceeds fifty characters to test truncation behavior',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now(),
        color: NoteColor.skyBlue,
        priority: NotePriority.normal,
        iconCategory: IconCategory.personal,
        isPinned: false,
        isArchived: false,
      );

      final label = AccessibilityHelper.getNoteCardSemanticLabel(note);

      // Should truncate long content
      expect(
          label, contains('A very long note content that exceeds fifty ch...'));
      expect(label, contains('Priority: Normal'));
      expect(label, contains('Category: Personal'));
      expect(label, contains('Created 2 hours ago'));
      expect(label, isNot(contains('Pinned')));
    });

    test('should handle edge cases in accessibility labels', () {
      // Empty content
      final emptyNote = Note(
        id: '1',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.low,
      );

      final emptyLabel =
          AccessibilityHelper.getNoteCardSemanticLabel(emptyNote);
      expect(emptyLabel, contains('Note: .'));

      // Very recent note
      final recentNote = Note(
        id: '1',
        content: 'Recent note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.low,
      );

      final recentLabel =
          AccessibilityHelper.getNoteCardSemanticLabel(recentNote);
      expect(recentLabel, contains('Created just now'));
    });
  });
}
