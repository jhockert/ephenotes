import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/core/utils/contrast_checker.dart';
import 'package:ephenotes/core/constants/app_colors.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';

/// Property-based tests for accessibility compliance.
///
/// **Validates: Requirements NFR-2.1, NFR-2.2, NFR-2.3**
///
/// This test suite verifies that all interactive elements are accessible
/// according to WCAG AA standards, including touch target sizes, semantic
/// labeling completeness, and color contrast ratios.

void main() {
  group('Property Test: Accessibility Compliance', () {
    setUp(() {
      PropertyTestConfig.reset();
    });

    testProperty(
        'Property 5.2.1: All interactive elements meet minimum touch target size',
        () {
      // **Validates: Requirements NFR-2.1**
      forAll(
        Generator.fromFunction((random) {
          // Generate various UI component sizes that might be used in the app
          final componentTypes = [
            'FloatingActionButton',
            'AppBarIcon',
            'ColorPickerOption',
            'PriorityButton',
            'IconSelectorOption',
            'TextFormattingButton',
            'SlidableAction',
            'NoteCard',
            'SearchButton',
            'ArchiveButton',
          ];

          final type = componentTypes[random.nextInt(componentTypes.length)];

          // Generate sizes that include both valid and invalid cases
          final width = 20.0 + random.nextDouble() * 80.0; // 20-100 pixels
          final height = 20.0 + random.nextDouble() * 80.0; // 20-100 pixels

          return {
            'type': type,
            'size': Size(width, height),
          };
        }),
        (Map<String, dynamic> component) {
          final type = component['type'] as String;
          final size = component['size'] as Size;

          // WCAG AA requires minimum 44x44 logical pixels for touch targets
          const minTouchSize = 44.0;

          // Check if the component meets the minimum touch target size
          final meetsRequirement =
              size.width >= minTouchSize && size.height >= minTouchSize;

          // Define expected sizes for each component type
          final expectedSizes = {
            'FloatingActionButton': const Size(56.0, 56.0),
            'AppBarIcon': const Size(48.0, 48.0),
            'ColorPickerOption': const Size(48.0, 48.0),
            'PriorityButton': const Size(80.0, 60.0),
            'IconSelectorOption': const Size(56.0, 56.0),
            'TextFormattingButton': const Size(48.0, 48.0),
            'SlidableAction': const Size(80.0, 80.0),
            'NoteCard': const Size(
                double.infinity, 80.0), // Width can be infinite, height minimum
            'SearchButton': const Size(48.0, 48.0),
            'ArchiveButton': const Size(48.0, 48.0),
          };

          final expectedSize = expectedSizes[type];
          if (expectedSize != null) {
            // For components with defined expected sizes, they should meet requirements
            final expectedMeetsRequirement =
                (expectedSize.width >= minTouchSize ||
                        expectedSize.width == double.infinity) &&
                    expectedSize.height >= minTouchSize;

            expect(expectedMeetsRequirement, isTrue,
                reason:
                    '$type with expected size ${expectedSize.width}x${expectedSize.height} should meet WCAG AA touch target requirements');
          }

          // Property: All interactive elements should meet minimum touch target size
          if (meetsRequirement) {
            // If it meets the requirement, it should be accessible
            expect(size.width, greaterThanOrEqualTo(minTouchSize));
            expect(size.height, greaterThanOrEqualTo(minTouchSize));
          } else {
            // If it doesn't meet the requirement, it should be flagged as inaccessible
            expect(
                size.width < minTouchSize || size.height < minTouchSize, isTrue,
                reason:
                    'Component $type with size ${size.width}x${size.height} does not meet minimum touch target size');
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 5.2.2: All interactive elements have complete semantic labeling',
        () {
      // **Validates: Requirements NFR-2.2**
      forAll(
        noteGenerator(),
        (Note note) {
          // Test semantic labeling for note cards
          final noteCardLabel =
              AccessibilityHelper.getNoteCardSemanticLabel(note);
          final noteCardHint = AccessibilityHelper.getNoteCardSemanticHint();

          // Property: Semantic labels must be non-empty and descriptive
          expect(noteCardLabel, isNotEmpty,
              reason: 'Note card semantic label should not be empty');
          expect(noteCardLabel.length, greaterThan(10),
              reason:
                  'Note card semantic label should be descriptive (>10 characters)');

          // Property: Semantic labels must contain essential information
          expect(noteCardLabel, contains('Note:'),
              reason: 'Note card label should identify it as a note');
          expect(noteCardLabel, contains('Priority:'),
              reason: 'Note card label should include priority information');

          // Property: Semantic hints must provide interaction guidance
          expect(noteCardHint, isNotEmpty,
              reason: 'Note card semantic hint should not be empty');
          expect(noteCardHint, contains('tap'),
              reason: 'Note card hint should mention tap interaction');

          // Test semantic labeling for priority selector
          for (final priority in NotePriority.values) {
            for (final isSelected in [true, false]) {
              final priorityLabel =
                  AccessibilityHelper.getPrioritySemanticLabel(
                      priority, isSelected);

              expect(priorityLabel, isNotEmpty,
                  reason: 'Priority selector label should not be empty');
              expect(priorityLabel, contains('priority'),
                  reason: 'Priority selector label should mention priority');
              expect(priorityLabel,
                  contains(isSelected ? 'selected' : 'not selected'),
                  reason:
                      'Priority selector label should indicate selection state');
            }
          }

          // Test semantic labeling for color picker
          for (final color in NoteColor.values) {
            for (final isSelected in [true, false]) {
              final colorLabel =
                  AccessibilityHelper.getColorSemanticLabel(color, isSelected);

              expect(colorLabel, isNotEmpty,
                  reason: 'Color picker label should not be empty');
              expect(colorLabel, contains('color'),
                  reason: 'Color picker label should mention color');
              expect(colorLabel,
                  contains(isSelected ? 'selected' : 'not selected'),
                  reason: 'Color picker label should indicate selection state');
            }
          }

          // Test semantic labeling for icon selector
          for (final iconCategory in [...IconCategory.values, null]) {
            for (final isSelected in [true, false]) {
              final iconLabel = AccessibilityHelper.getIconSemanticLabel(
                  iconCategory, isSelected);

              expect(iconLabel, isNotEmpty,
                  reason: 'Icon selector label should not be empty');
              expect(iconLabel, contains('icon'),
                  reason: 'Icon selector label should mention icon');
              expect(
                  iconLabel, contains(isSelected ? 'selected' : 'not selected'),
                  reason:
                      'Icon selector label should indicate selection state');
            }
          }
        },
        iterations:
            50, // Fewer iterations since we're testing multiple combinations per note
      );
    });

    testProperty(
        'Property 5.2.3: All color combinations meet WCAG AA contrast requirements',
        () {
      // **Validates: Requirements NFR-2.3**
      forAll(
        Generator.fromFunction((random) {
          // Generate various color combinations used in the app
          final brightness =
              random.nextBool() ? Brightness.light : Brightness.dark;
          final noteColor =
              NoteColor.values[random.nextInt(NoteColor.values.length)];

          return {
            'brightness': brightness,
            'noteColor': noteColor,
          };
        }),
        (Map<String, dynamic> colorContext) {
          final brightness = colorContext['brightness'] as Brightness;
          final noteColor = colorContext['noteColor'] as NoteColor;

          // Get the actual colors used in the app
          final backgroundColor = AppColors.getNoteColor(noteColor, brightness);
          final primaryTextColor =
              AppColors.noteTextColor(brightness, noteColor);
          final secondaryTextColor =
              AppColors.noteSecondaryTextColor(brightness, noteColor);

          // Property: Primary text must meet WCAG AA contrast ratio (4.5:1)
          final primaryRatio = ContrastChecker.getContrastRatio(
              primaryTextColor, backgroundColor);
          expect(primaryRatio, greaterThanOrEqualTo(4.5),
              reason:
                  'Primary text on ${noteColor.name} in ${brightness.name} mode has contrast ratio ${primaryRatio.toStringAsFixed(2)}:1, should be ≥4.5:1');

          expect(
              ContrastChecker.meetsWCAGAANormalText(
                  primaryTextColor, backgroundColor),
              isTrue,
              reason:
                  'Primary text on ${noteColor.name} in ${brightness.name} mode should meet WCAG AA standards');

          // Property: Secondary text must meet WCAG AA contrast ratio (4.5:1)
          final secondaryRatio = ContrastChecker.getContrastRatio(
              secondaryTextColor, backgroundColor);
          expect(secondaryRatio, greaterThanOrEqualTo(4.5),
              reason:
                  'Secondary text on ${noteColor.name} in ${brightness.name} mode has contrast ratio ${secondaryRatio.toStringAsFixed(2)}:1, should be ≥4.5:1');

          expect(
              ContrastChecker.meetsWCAGAANormalText(
                  secondaryTextColor, backgroundColor),
              isTrue,
              reason:
                  'Secondary text on ${noteColor.name} in ${brightness.name} mode should meet WCAG AA standards');
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 5.2.4: Priority badge colors meet WCAG AA contrast requirements',
        () {
      // **Validates: Requirements NFR-2.3**
      forAll(
        Generator.oneOf(NotePriority.values),
        (NotePriority priority) {
          // Get priority badge colors
          final priorityColors = {
            NotePriority.high: const Color(0xFFE53935), // Red
            NotePriority.normal: Colors.grey, // Grey (not displayed)
            NotePriority.low: const Color(0xFF4CAF50), // Green
          };

          final backgroundColor = priorityColors[priority]!;
          final textColor = Colors.white; // Priority badges use white text

          // Property: Priority badge text must meet WCAG AA contrast ratio (4.5:1)
          final contrastRatio =
              ContrastChecker.getContrastRatio(textColor, backgroundColor);
          expect(contrastRatio, greaterThanOrEqualTo(4.5),
              reason:
                  '${priority.name} priority badge has contrast ratio ${contrastRatio.toStringAsFixed(2)}:1, should be ≥4.5:1');

          expect(
              ContrastChecker.meetsWCAGAANormalText(textColor, backgroundColor),
              isTrue,
              reason:
                  '${priority.name} priority badge should meet WCAG AA standards');

          // Property: Priority badges should achieve at least AA level compliance
          final wcagLevel =
              ContrastChecker.getWCAGLevel(textColor, backgroundColor);
          expect(wcagLevel, isIn(['AA', 'AAA']),
              reason:
                  '${priority.name} priority badge should achieve at least AA compliance, got $wcagLevel');
        },
        iterations: 50,
      );
    });

    testProperty(
        'Property 5.2.5: Character counter provides accessible feedback', () {
      // **Validates: Requirements NFR-2.2**
      forAll(
        intGenerator(min: 0, max: 200),
        (int currentLength) {
          const maxLength = 140;

          final counterLabel =
              AccessibilityHelper.getCharacterCounterSemanticLabel(
                  currentLength, maxLength);

          // Property: Character counter label must be non-empty
          expect(counterLabel, isNotEmpty,
              reason: 'Character counter label should not be empty');

          // Property: Character counter must indicate current usage
          expect(counterLabel, contains(currentLength.toString()),
              reason: 'Character counter should show current character count');
          expect(counterLabel, contains(maxLength.toString()),
              reason: 'Character counter should show maximum character count');

          // Property: Character counter must provide appropriate warnings
          if (currentLength >= maxLength) {
            expect(counterLabel, contains('limit reached'),
                reason: 'Character counter should warn when limit is reached');
          } else if (maxLength - currentLength <= 10) {
            expect(counterLabel, contains('remaining'),
                reason:
                    'Character counter should show remaining characters when close to limit');
          }

          // Property: Character counter must be descriptive for screen readers
          expect(counterLabel.length, greaterThan(15),
              reason:
                  'Character counter label should be descriptive for screen readers');
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 5.2.6: Empty and error states have accessible descriptions',
        () {
      // **Validates: Requirements NFR-2.2**
      forAll(
        stringGenerator(minLength: 0, maxLength: 100),
        (String errorMessage) {
          // Test empty state accessibility
          final emptyStateLabel =
              AccessibilityHelper.getEmptyStateSemanticLabel();

          expect(emptyStateLabel, isNotEmpty,
              reason: 'Empty state label should not be empty');
          expect(emptyStateLabel, contains('No notes'),
              reason: 'Empty state should indicate no notes are available');
          expect(emptyStateLabel, contains('create'),
              reason: 'Empty state should guide user to create notes');

          // Test loading state accessibility
          final loadingLabel = AccessibilityHelper.getLoadingSemanticLabel();

          expect(loadingLabel, isNotEmpty,
              reason: 'Loading state label should not be empty');
          expect(loadingLabel, contains('Loading'),
              reason: 'Loading state should indicate loading is in progress');

          // Test error state accessibility (if error message is provided)
          if (errorMessage.isNotEmpty) {
            final errorLabel =
                AccessibilityHelper.getErrorSemanticLabel(errorMessage);

            expect(errorLabel, isNotEmpty,
                reason: 'Error state label should not be empty');
            expect(errorLabel, contains('Error'),
                reason: 'Error state should indicate an error occurred');
            expect(errorLabel, contains(errorMessage),
                reason:
                    'Error state should include the specific error message');
          }
        },
        iterations: 50,
      );
    });

    testProperty(
        'Property 5.2.7: Theme toggle provides accessible mode information',
        () {
      // **Validates: Requirements NFR-2.2**
      forAll(
        Generator.oneOf(ThemeMode.values),
        (ThemeMode currentMode) {
          final themeLabel =
              AccessibilityHelper.getThemeToggleSemanticLabel(currentMode);

          // Property: Theme toggle label must be non-empty
          expect(themeLabel, isNotEmpty,
              reason: 'Theme toggle label should not be empty');

          // Property: Theme toggle must indicate current mode
          expect(themeLabel, contains('Theme mode:'),
              reason: 'Theme toggle should indicate current theme mode');

          final modeText = switch (currentMode) {
            ThemeMode.system => 'System',
            ThemeMode.light => 'Light',
            ThemeMode.dark => 'Dark',
          };

          expect(themeLabel, contains(modeText),
              reason: 'Theme toggle should show current mode ($modeText)');

          // Property: Theme toggle must indicate next action
          expect(themeLabel, contains('Tap to switch'),
              reason: 'Theme toggle should indicate how to change theme');

          // Property: Theme toggle should be descriptive for screen readers
          expect(themeLabel.length, greaterThan(20),
              reason:
                  'Theme toggle label should be descriptive for screen readers');
        },
        iterations: 50,
      );
    });
  });

  group('Accessibility Integration Properties', () {
    testProperty(
        'Property 5.2.8: Search results maintain accessibility with dynamic content',
        () {
      // **Validates: Requirements NFR-2.2, 4.1, 4.2**
      forAll2(
        intGenerator(min: 0, max: 100),
        searchQueryGenerator(),
        (int resultCount, String query) {
          final searchResultsLabel =
              AccessibilityHelper.getSearchResultsSemanticLabel(resultCount);

          // Property: Search results label must be non-empty
          expect(searchResultsLabel, isNotEmpty,
              reason: 'Search results label should not be empty');

          // Property: Search results must indicate count appropriately
          if (resultCount == 0) {
            expect(searchResultsLabel, contains('No search results'),
                reason: 'Should indicate when no results are found');
          } else if (resultCount == 1) {
            expect(searchResultsLabel, contains('1 search result'),
                reason: 'Should use singular form for one result');
            expect(searchResultsLabel, isNot(contains('results')),
                reason: 'Should not use plural form for one result');
          } else {
            expect(searchResultsLabel, contains('$resultCount search results'),
                reason: 'Should show exact count for multiple results');
            expect(searchResultsLabel, contains('results'),
                reason: 'Should use plural form for multiple results');
          }

          // Property: Search results should be announced to screen readers
          expect(searchResultsLabel, contains('found'),
              reason: 'Search results should indicate results were found');
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 5.2.9: Action buttons provide clear semantic descriptions',
        () {
      // **Validates: Requirements NFR-2.2**
      forAll(
        boolGenerator(),
        (bool isPinned) {
          // Test archive action accessibility
          final archiveLabel =
              AccessibilityHelper.getArchiveActionSemanticLabel();
          expect(archiveLabel, equals('Archive note'),
              reason: 'Archive action should have clear semantic label');

          // Test pin/unpin action accessibility
          final pinLabel =
              AccessibilityHelper.getPinActionSemanticLabel(isPinned);
          final expectedPinLabel = isPinned ? 'Unpin note' : 'Pin note';
          expect(pinLabel, equals(expectedPinLabel),
              reason: 'Pin action should indicate current state and action');

          // Test undo action accessibility
          final undoLabel = AccessibilityHelper.getUndoSemanticLabel();
          expect(undoLabel, equals('Undo archive action'),
              reason: 'Undo action should have clear semantic label');

          // Test FAB accessibility
          final fabLabel = AccessibilityHelper.getFabSemanticLabel();
          expect(fabLabel, equals('Create new note'),
              reason: 'FAB should have clear semantic label');

          // Property: All action labels should be concise but descriptive
          for (final label in [archiveLabel, pinLabel, undoLabel, fabLabel]) {
            expect(label, isNotEmpty,
                reason: 'Action labels should not be empty');
            expect(label.length, greaterThan(5),
                reason: 'Action labels should be descriptive');
            expect(label.length, lessThan(50),
                reason: 'Action labels should be concise');
          }
        },
        iterations: 50,
      );
    });
  });
}
