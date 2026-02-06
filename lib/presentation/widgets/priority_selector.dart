import 'package:flutter/material.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/data/models/note.dart';

/// Widget for selecting note priority level.
///
/// Displays three priority options: High, Normal (default), Low.
/// Normal priority is not displayed on notes.
class PrioritySelector extends StatelessWidget {
  final NotePriority selectedPriority;
  final ValueChanged<NotePriority> onPrioritySelected;

  const PrioritySelector({
    super.key,
    required this.selectedPriority,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: UiStrings.prioritySelectorLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                UiStrings.prioritySectionTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: UiStrings.priorityOptionsLabel,
                child: Row(
                  children: [
                    _buildPriorityButton(
                      context,
                      NotePriority.high,
                      UiStrings.priorityHigh,
                      Colors.red,
                      Icons.keyboard_double_arrow_up,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityButton(
                      context,
                      NotePriority.normal,
                      UiStrings.priorityNormal,
                      Colors.grey,
                      Icons.remove,
                    ),
                    const SizedBox(width: 12),
                    _buildPriorityButton(
                      context,
                      NotePriority.low,
                      UiStrings.priorityLow,
                      Colors.green,
                      Icons.keyboard_double_arrow_down,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityButton(
    BuildContext context,
    NotePriority priority,
    String label,
    Color color,
    IconData icon,
  ) {
    final isSelected = priority == selectedPriority;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use enhanced colors that match the note card badges
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      switch (priority) {
        case NotePriority.high:
          backgroundColor =
              isDark ? const Color(0xFFD32F2F) : const Color(0xFFE53935);
          textColor = Colors.white;
          borderColor = backgroundColor;
          break;
        case NotePriority.normal:
          backgroundColor =
              isDark ? Colors.grey[700]! : Colors.grey[300]!;
          textColor = isDark ? Colors.grey[300]! : Colors.grey[700]!;
          borderColor = backgroundColor;
          break;
        case NotePriority.low:
          backgroundColor =
              isDark ? const Color(0xFF388E3C) : const Color(0xFF4CAF50);
          textColor = Colors.white;
          borderColor = backgroundColor;
          break;
      }
    } else {
      backgroundColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;
      textColor = color;
      borderColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    }

    return Expanded(
      child: Semantics(
        label:
            AccessibilityHelper.getPrioritySemanticLabel(priority, isSelected),
        button: true,
        selected: isSelected,
        child: GestureDetector(
          onTap: () => onPrioritySelected(priority),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderColor,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 26,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
