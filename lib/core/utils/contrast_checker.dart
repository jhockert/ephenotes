import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for checking color contrast ratios to ensure WCAG AA compliance.
///
/// WCAG AA requires:
/// - Normal text: 4.5:1 contrast ratio minimum
/// - Large text (18pt+ or 14pt+ bold): 3:1 contrast ratio minimum
/// - UI components and graphics: 3:1 contrast ratio minimum
class ContrastChecker {
  ContrastChecker._();

  /// Calculates the contrast ratio between two colors.
  ///
  /// Returns a value between 1 and 21, where:
  /// - 1 = no contrast (same color)
  /// - 21 = maximum contrast (black on white or white on black)
  ///
  /// WCAG AA compliance:
  /// - Normal text: >= 4.5
  /// - Large text: >= 3.0
  /// - UI components: >= 3.0
  static double getContrastRatio(Color foreground, Color background) {
    final foregroundLuminance = _getLuminance(foreground);
    final backgroundLuminance = _getLuminance(background);

    final lighter = math.max(foregroundLuminance, backgroundLuminance);
    final darker = math.min(foregroundLuminance, backgroundLuminance);

    return (lighter + 0.05) / (darker + 0.05);
  }

  /// Checks if the contrast ratio meets WCAG AA standards for normal text.
  ///
  /// Normal text requires a minimum contrast ratio of 4.5:1.
  static bool meetsWCAGAANormalText(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }

  /// Checks if the contrast ratio meets WCAG AA standards for large text.
  ///
  /// Large text requires a minimum contrast ratio of 3:1.
  static bool meetsWCAGAALargeText(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 3.0;
  }

  /// Checks if the contrast ratio meets WCAG AA standards for UI components.
  ///
  /// UI components require a minimum contrast ratio of 3:1.
  static bool meetsWCAGAAUIComponents(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 3.0;
  }

  /// Gets the WCAG compliance level for the given contrast ratio.
  ///
  /// Returns:
  /// - 'AAA' for ratios >= 7.0 (normal text) or >= 4.5 (large text)
  /// - 'AA' for ratios >= 4.5 (normal text) or >= 3.0 (large text)
  /// - 'Fail' for ratios below AA standards
  static String getWCAGLevel(Color foreground, Color background,
      {bool isLargeText = false}) {
    final ratio = getContrastRatio(foreground, background);

    if (isLargeText) {
      if (ratio >= 4.5) return 'AAA';
      if (ratio >= 3.0) return 'AA';
      return 'Fail';
    } else {
      if (ratio >= 7.0) return 'AAA';
      if (ratio >= 4.5) return 'AA';
      return 'Fail';
    }
  }

  /// Suggests an alternative color that meets WCAG AA standards.
  ///
  /// If the current combination doesn't meet standards, this method
  /// will darken or lighten the foreground color to achieve compliance.
  static Color suggestAccessibleForeground(Color foreground, Color background,
      {bool isLargeText = false}) {
    final targetRatio = isLargeText ? 3.0 : 4.5;
    final currentRatio = getContrastRatio(foreground, background);

    if (currentRatio >= targetRatio) {
      return foreground; // Already compliant
    }

    final backgroundLuminance = _getLuminance(background);

    // Try darkening the foreground first
    Color adjusted = _adjustColorForContrast(
        foreground, background, targetRatio,
        darken: true);
    if (getContrastRatio(adjusted, background) >= targetRatio) {
      return adjusted;
    }

    // If darkening doesn't work, try lightening
    adjusted = _adjustColorForContrast(foreground, background, targetRatio,
        darken: false);
    if (getContrastRatio(adjusted, background) >= targetRatio) {
      return adjusted;
    }

    // If neither works, use high contrast fallback
    return backgroundLuminance > 0.5 ? Colors.black : Colors.white;
  }

  /// Validates all color combinations in the app for WCAG AA compliance.
  ///
  /// Returns a map of color combination descriptions to their compliance status.
  static Map<String, bool> validateAppColors() {
    final results = <String, bool>{};

    // Test common app color combinations
    const lightBackground = Color(0xFFFFFFFF);
    const darkBackground = Color(0xFF121212);
    const primaryText = Color(0xDD000000);
    const secondaryText = Color(0x99000000);
    const primaryTextDark = Color(0xDDFFFFFF);
    const secondaryTextDark = Color(0x99FFFFFF);

    // Light mode combinations
    results['Light mode - Primary text on white'] =
        meetsWCAGAANormalText(primaryText, lightBackground);
    results['Light mode - Secondary text on white'] =
        meetsWCAGAANormalText(secondaryText, lightBackground);

    // Dark mode combinations
    results['Dark mode - Primary text on dark'] =
        meetsWCAGAANormalText(primaryTextDark, darkBackground);
    results['Dark mode - Secondary text on dark'] =
        meetsWCAGAANormalText(secondaryTextDark, darkBackground);

    // Priority badge combinations
    const highPriorityBg = Color(0xFFE53935);
    const mediumPriorityBg = Color(0xFFFF9800);
    const lowPriorityBg = Color(0xFF4CAF50);
    const whiteText = Colors.white;

    results['High priority badge - White text on red'] =
        meetsWCAGAANormalText(whiteText, highPriorityBg);
    results['Medium priority badge - White text on orange'] =
        meetsWCAGAANormalText(whiteText, mediumPriorityBg);
    results['Low priority badge - White text on green'] =
        meetsWCAGAANormalText(whiteText, lowPriorityBg);

    return results;
  }

  // Private helper methods

  /// Calculates the relative luminance of a color according to WCAG standards.
  static double _getLuminance(Color color) {
    final r = _getLinearRGB((color.r * 255.0).round().clamp(0, 255) / 255.0);
    final g = _getLinearRGB((color.g * 255.0).round().clamp(0, 255) / 255.0);
    final b = _getLinearRGB((color.b * 255.0).round().clamp(0, 255) / 255.0);

    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Converts sRGB color component to linear RGB.
  static double _getLinearRGB(double colorComponent) {
    if (colorComponent <= 0.03928) {
      return colorComponent / 12.92;
    } else {
      return math.pow((colorComponent + 0.055) / 1.055, 2.4).toDouble();
    }
  }

  /// Adjusts a color to meet the target contrast ratio.
  static Color _adjustColorForContrast(
      Color foreground, Color background, double targetRatio,
      {required bool darken}) {
    final hsl = HSLColor.fromColor(foreground);
    double lightness = hsl.lightness;

    const step = 0.05;
    const maxIterations = 20;
    int iterations = 0;

    while (iterations < maxIterations) {
      if (darken) {
        lightness = math.max(0.0, lightness - step);
      } else {
        lightness = math.min(1.0, lightness + step);
      }

      final adjustedColor = hsl.withLightness(lightness).toColor();
      final ratio = getContrastRatio(adjustedColor, background);

      if (ratio >= targetRatio) {
        return adjustedColor;
      }

      iterations++;
    }

    return foreground; // Return original if adjustment fails
  }
}
