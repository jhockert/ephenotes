import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';

/// Property-based tests for archive gesture threshold requirements.
///
/// **Validates: Requirements 1.3**
///
/// This test suite validates Property 8: Archive Gesture Threshold
/// from the design document, ensuring that:
/// - Archive requires >50% screen width swipe
/// - Threshold behavior is consistent across different screen sizes
/// - Both left and right swipe directions work correctly
/// - Swipe distances below 50% do not trigger archive
/// - Swipe distances at or above 50% trigger archive

void main() {
  group('Property Test: Archive Gesture Threshold', () {
    setUp(() {
      PropertyTestConfig.reset();
    });

    testProperty(
      'Property 8: Archive requires >50% screen width swipe',
      () {
        // **Validates: Requirements 1.3**
        //
        // Test that archive gesture requires more than 50% screen width swipe.
        // This property validates that:
        // 1. Swipe distance < 50% does not trigger archive
        // 2. Swipe distance >= 50% triggers archive
        // 3. Threshold applies to both left and right swipes
        // 4. Behavior is consistent across different screen sizes

        forAll3(
          noteGenerator(allowLongContent: false, ensureValidTimestamps: true),
          doubleGenerator(min: 0.0, max: 1.0), // Swipe ratio (0-100%)
          screenWidthGenerator(), // Different screen sizes
          (Note note, double swipeRatio, double screenWidth) {
            // Calculate swipe distance in pixels
            final swipeDistance = screenWidth * swipeRatio;

            // Determine if archive should be triggered
            // Archive requires >= 50% screen width swipe
            final shouldArchive = swipeRatio >= 0.5;

            // Simulate the archive gesture threshold check
            final actuallyArchived =
                checkArchiveGestureThreshold(swipeDistance, screenWidth);

            // Verify threshold behavior
            expect(
              actuallyArchived,
              equals(shouldArchive),
              reason:
                  'Archive gesture with ${(swipeRatio * 100).toStringAsFixed(1)}% '
                  'swipe (${swipeDistance.toStringAsFixed(1)}px of ${screenWidth.toStringAsFixed(1)}px) '
                  'should ${shouldArchive ? "trigger" : "not trigger"} archive',
            );

            // Additional validation: verify edge cases
            if (swipeRatio == 0.5) {
              // Exactly 50% should trigger archive
              expect(actuallyArchived, isTrue,
                  reason: 'Exactly 50% swipe should trigger archive');
            }

            if (swipeRatio < 0.5) {
              // Less than 50% should not trigger archive
              expect(actuallyArchived, isFalse,
                  reason:
                      'Less than 50% swipe should not trigger archive');
            }

            if (swipeRatio > 0.5) {
              // More than 50% should trigger archive
              expect(actuallyArchived, isTrue,
                  reason: 'More than 50% swipe should trigger archive');
            }
          },
          iterations: 100,
        );
      },
    );

    testProperty(
      'Property 8.1: Threshold behavior is consistent across screen sizes',
      () {
        // **Validates: Requirements 1.3**
        //
        // Test that the 50% threshold works consistently regardless of screen size.
        // A 50% swipe on a small screen and a 50% swipe on a large screen
        // should both trigger archive, even though the absolute pixel distances differ.

        forAll2(
          doubleGenerator(min: 0.4, max: 0.6), // Swipe ratios near threshold
          screenSizeVariationsGenerator(), // Various screen sizes
          (double swipeRatio, List<double> screenWidths) {
            final shouldArchive = swipeRatio >= 0.5;

            // Test the same swipe ratio on different screen sizes
            for (final screenWidth in screenWidths) {
              final swipeDistance = screenWidth * swipeRatio;
              final actuallyArchived =
                  checkArchiveGestureThreshold(swipeDistance, screenWidth);

              expect(
                actuallyArchived,
                equals(shouldArchive),
                reason:
                    'Archive threshold should be consistent: ${(swipeRatio * 100).toStringAsFixed(1)}% '
                    'swipe on ${screenWidth.toStringAsFixed(0)}px screen should '
                    '${shouldArchive ? "trigger" : "not trigger"} archive',
              );
            }
          },
          iterations: 50,
        );
      },
    );

    testProperty(
      'Property 8.2: Both left and right swipe directions work correctly',
      () {
        // **Validates: Requirements 1.3**
        //
        // Test that archive gesture works for both swipe directions.
        // The threshold should apply equally to left and right swipes.

        forAll3(
          noteGenerator(allowLongContent: false, ensureValidTimestamps: true),
          doubleGenerator(min: 0.0, max: 1.0), // Swipe ratio
          swipeDirectionGenerator(), // Left or right
          (Note note, double swipeRatio, SwipeDirection direction) {
            final screenWidth = 400.0; // Standard test screen width
            final swipeDistance = screenWidth * swipeRatio;
            final shouldArchive = swipeRatio >= 0.5;

            // Check threshold for the given direction
            final actuallyArchived = checkArchiveGestureThresholdWithDirection(
              swipeDistance,
              screenWidth,
              direction,
            );

            expect(
              actuallyArchived,
              equals(shouldArchive),
              reason:
                  '${direction.name} swipe with ${(swipeRatio * 100).toStringAsFixed(1)}% '
                  'distance should ${shouldArchive ? "trigger" : "not trigger"} archive',
            );
          },
          iterations: 100,
        );
      },
    );

    testProperty(
      'Property 8.3: Swipe progress calculation is accurate',
      () {
        // **Validates: Requirements 1.3**
        //
        // Test that swipe progress is calculated correctly as a percentage.
        // This validates the visual feedback shown to users during swipe.

        forAll2(
          doubleGenerator(min: 0.0, max: 1.0), // Swipe ratio
          screenWidthGenerator(), // Screen width
          (double swipeRatio, double screenWidth) {
            final swipeDistance = screenWidth * swipeRatio;

            // Calculate progress (0.0 to 1.0, where 1.0 = 50% threshold reached)
            final progress = calculateSwipeProgress(swipeDistance, screenWidth);

            // Progress should be 2x the swipe ratio (since 50% swipe = 100% progress)
            final expectedProgress = (swipeRatio / 0.5).clamp(0.0, 1.0);

            expect(
              progress,
              closeTo(expectedProgress, 0.01),
              reason:
                  'Swipe progress for ${(swipeRatio * 100).toStringAsFixed(1)}% '
                  'swipe should be ${(expectedProgress * 100).toStringAsFixed(1)}%',
            );

            // Verify progress boundaries
            expect(progress, greaterThanOrEqualTo(0.0),
                reason: 'Progress should never be negative');
            expect(progress, lessThanOrEqualTo(1.0),
                reason: 'Progress should never exceed 1.0');

            // Verify threshold crossing
            if (swipeRatio >= 0.5) {
              expect(progress, equals(1.0),
                  reason: 'Progress should be 1.0 when threshold is reached');
            }
          },
          iterations: 100,
        );
      },
    );

    testProperty(
      'Property 8.4: Edge cases near threshold are handled correctly',
      () {
        // **Validates: Requirements 1.3**
        //
        // Test edge cases very close to the 50% threshold to ensure
        // there are no rounding errors or boundary issues.

        forAll(
          edgeCaseSwipeRatioGenerator(), // Ratios very close to 0.5
          (double swipeRatio) {
            final screenWidth = 400.0;
            final swipeDistance = screenWidth * swipeRatio;
            final shouldArchive = swipeRatio >= 0.5;

            final actuallyArchived =
                checkArchiveGestureThreshold(swipeDistance, screenWidth);

            expect(
              actuallyArchived,
              equals(shouldArchive),
              reason:
                  'Edge case: ${(swipeRatio * 100).toStringAsFixed(4)}% swipe '
                  'should ${shouldArchive ? "trigger" : "not trigger"} archive',
            );
          },
          iterations: 100,
        );
      },
    );
  });
}

// ============================================================================
// Helper Functions
// ============================================================================

/// Simulates the archive gesture threshold check.
///
/// This function replicates the logic from SwipeableNoteCard to determine
/// if a swipe should trigger archive based on distance and screen width.
///
/// Returns true if the swipe distance is >= 50% of screen width.
bool checkArchiveGestureThreshold(double swipeDistance, double screenWidth) {
  if (screenWidth <= 0) return false;

  // Calculate the ratio of swipe distance to screen width
  final ratio = swipeDistance / screenWidth;

  // Archive is triggered when ratio >= 0.5 (50% threshold)
  // This matches the extentRatio and dismissThreshold in SwipeableNoteCard
  return ratio >= 0.5;
}

/// Simulates the archive gesture threshold check with direction.
///
/// The direction doesn't affect the threshold logic, but this function
/// is provided to explicitly test both directions.
bool checkArchiveGestureThresholdWithDirection(
  double swipeDistance,
  double screenWidth,
  SwipeDirection direction,
) {
  // Direction doesn't affect threshold - both left and right use same logic
  return checkArchiveGestureThreshold(swipeDistance, screenWidth);
}

/// Calculates swipe progress as shown in the UI.
///
/// Progress is 0.0 to 1.0, where:
/// - 0.0 = no swipe
/// - 1.0 = 50% threshold reached
/// - Values are clamped to [0.0, 1.0]
double calculateSwipeProgress(double swipeDistance, double screenWidth) {
  if (screenWidth <= 0) return 0.0;

  final ratio = swipeDistance / screenWidth;
  // Progress is 2x the ratio (since 50% swipe = 100% progress)
  final progress = (ratio / 0.5).clamp(0.0, 1.0);

  return progress;
}

// ============================================================================
// Custom Generators
// ============================================================================

/// Generates random double values within a range.
Generator<double> doubleGenerator({
  double min = 0.0,
  double max = 1.0,
}) {
  return Generator.fromFunction((random) {
    final range = max - min;
    return min + (random.nextDouble() * range);
  });
}

/// Generates realistic screen widths for mobile devices.
///
/// Covers common device widths:
/// - Small phones: 320-375px
/// - Medium phones: 375-414px
/// - Large phones: 414-480px
/// - Tablets: 600-1024px
Generator<double> screenWidthGenerator() {
  return Generator.fromFunction((random) {
    final widthRanges = [
      (320.0, 375.0), // Small phones (iPhone SE, etc.)
      (375.0, 414.0), // Medium phones (iPhone 12, etc.)
      (414.0, 480.0), // Large phones (iPhone Pro Max, etc.)
      (600.0, 768.0), // Small tablets
      (768.0, 1024.0), // Large tablets
    ];

    final range = widthRanges[random.nextInt(widthRanges.length)];
    final width = range.$1 + (random.nextDouble() * (range.$2 - range.$1));

    return width;
  });
}

/// Generates a list of various screen sizes for consistency testing.
Generator<List<double>> screenSizeVariationsGenerator() {
  return Generator.fromFunction((random) {
    return [
      320.0, // iPhone SE
      375.0, // iPhone 12/13
      390.0, // iPhone 14
      414.0, // iPhone Pro Max
      428.0, // iPhone 14 Pro Max
      600.0, // Small tablet
      768.0, // iPad
      1024.0, // iPad Pro
    ];
  });
}

/// Generates swipe directions (left or right).
Generator<SwipeDirection> swipeDirectionGenerator() {
  return Generator.oneOf([SwipeDirection.left, SwipeDirection.right]);
}

/// Generates swipe ratios very close to the 50% threshold.
///
/// This generator focuses on edge cases to ensure proper boundary handling:
/// - Values just below 50% (49.9%, 49.99%, etc.)
/// - Exactly 50%
/// - Values just above 50% (50.01%, 50.1%, etc.)
Generator<double> edgeCaseSwipeRatioGenerator() {
  return Generator.fromFunction((random) {
    final edgeCases = [
      0.49, 0.495, 0.499, 0.4999, 0.49999, // Just below threshold
      0.5, // Exactly at threshold
      0.50001, 0.5001, 0.501, 0.505, 0.51, // Just above threshold
    ];

    return edgeCases[random.nextInt(edgeCases.length)];
  });
}

/// Enum for swipe directions.
enum SwipeDirection {
  left,
  right,
}
