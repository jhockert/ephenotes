import 'package:flutter/material.dart';
import 'package:ephenotes/core/constants/app_colors.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/core/utils/contrast_checker.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:intl/intl.dart';

/// Widget displaying a single note card in the list view.
///
/// Features:
/// - Visual representation of note content
/// - Color-coded background
/// - Priority indicator
/// - Icon category
/// - Timestamp
/// - Pin indicator
class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onArchive;
  final bool showMetadata;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onArchive,
    this.showMetadata = true,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final backgroundColor = AppColors.getNoteColor(note.color, brightness);
    final textColor = AppColors.noteTextColor(brightness, note.color);
    final secondaryColor =
        AppColors.noteSecondaryTextColor(brightness, note.color);

    // Ensure WCAG AA compliance for text colors
    final accessibleTextColor =
        ContrastChecker.meetsWCAGAANormalText(textColor, backgroundColor)
            ? textColor
            : ContrastChecker.suggestAccessibleForeground(
                textColor, backgroundColor);

    final accessibleSecondaryColor =
        ContrastChecker.meetsWCAGAANormalText(secondaryColor, backgroundColor)
            ? secondaryColor
            : ContrastChecker.suggestAccessibleForeground(
                secondaryColor, backgroundColor);

    return Semantics(
      label: AccessibilityHelper.getNoteCardSemanticLabel(note),
      hint: AccessibilityHelper.getNoteCardSemanticHint(),
      button: true,
      enabled: true,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 2,
        color: backgroundColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and priority (only in list view)
                if (showMetadata) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon category
                      if (note.iconCategory != null)
                        Semantics(
                          label:
                              'Category: ${AccessibilityHelper.getIconCategoryText(note.iconCategory!)}',
                          child: Icon(
                            _getIconData(note.iconCategory!),
                            size: 20,
                            color: accessibleTextColor,
                          ),
                        ),
                      if (note.iconCategory == null) const SizedBox(width: 20),

                      const Spacer(),

                      // Pin indicator
                      if (note.isPinned)
                        Semantics(
                          label: UiStrings.thisNoteIsPinned,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Icon(
                              Icons.push_pin,
                              size: 16,
                              color: accessibleSecondaryColor,
                            ),
                          ),
                        ),

                      // Priority label
                      _buildPriorityLabel(brightness, accessibleTextColor),
                    ],
                  ),

                  const SizedBox(height: 8),
                ],

                // Note content
                Semantics(
                  label: UiStrings.noteContent(note.content),
                  child: Text(
                    note.content,
                    style: TextStyle(
                      fontSize: _getFontSize(note.fontSize),
                      fontWeight:
                          note.isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle:
                          note.isItalic ? FontStyle.italic : FontStyle.normal,
                      decoration: note.isUnderlined
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      color: accessibleTextColor,
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 8),

                // Timestamp
                Semantics(
                  label: AccessibilityHelper.getTimestampText(note.createdAt),
                  child: Text(
                    _formatTimestamp(note.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: accessibleSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityLabel(Brightness brightness, Color accessibleTextColor) {
    String text;
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (note.priority) {
      case NotePriority.high:
        text = UiStrings.priorityHighBadge;
        backgroundColor = brightness == Brightness.dark
            ? const Color(0xFFD32F2F) // Darker red for dark mode
            : const Color(0xFFE53935); // Bright red for light mode
        textColor = Colors.white;
        icon = Icons.keyboard_double_arrow_up;
        break;
      case NotePriority.normal:
        // Normal priority is not displayed
        return const SizedBox.shrink();
      case NotePriority.low:
        text = UiStrings.priorityLowBadge;
        backgroundColor = brightness == Brightness.dark
            ? const Color(0xFF388E3C) // Darker green for dark mode
            : const Color(0xFF4CAF50); // Bright green for light mode
        textColor = Colors.white;
        icon = Icons.keyboard_double_arrow_down;
        break;
    }

    // Ensure WCAG AA compliance for priority badge
    final accessibleBadgeTextColor =
        ContrastChecker.meetsWCAGAANormalText(textColor, backgroundColor)
            ? textColor
            : ContrastChecker.suggestAccessibleForeground(
                textColor, backgroundColor);

    return Semantics(
      label: 'Priority: ${AccessibilityHelper.getPriorityText(note.priority)}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: accessibleBadgeTextColor,
            ),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: accessibleBadgeTextColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(IconCategory category) {
    switch (category) {
      case IconCategory.work:
        return Icons.work_outline;
      case IconCategory.personal:
        return Icons.home_outlined;
      case IconCategory.shopping:
        return Icons.shopping_cart_outlined;
      case IconCategory.health:
        return Icons.favorite_outline;
      case IconCategory.finance:
        return Icons.attach_money;
      case IconCategory.important:
        return Icons.star_outline;
      case IconCategory.ideas:
        return Icons.lightbulb_outline;
    }
  }

  double _getFontSize(FontSize size) {
    switch (size) {
      case FontSize.small:
        return 12.0;
      case FontSize.medium:
        return 14.0;
      case FontSize.large:
        return 16.0;
    }
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return UiStrings.timestampJustNow;
    } else if (difference.inHours < 1) {
      return UiStrings.timestampMinutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return UiStrings.timestampHoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return UiStrings.timestampDaysAgo(difference.inDays);
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
