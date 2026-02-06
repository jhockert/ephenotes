import 'package:flutter/material.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/data/models/note.dart';

/// Widget for selecting note icon category.
///
/// Displays all available icon categories including None option.
class IconSelector extends StatelessWidget {
  final IconCategory? selectedIcon;
  final ValueChanged<IconCategory?> onIconSelected;

  const IconSelector({
    super.key,
    required this.selectedIcon,
    required this.onIconSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: UiStrings.iconSelectorLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                UiStrings.categoryIconTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: UiStrings.iconOptionsLabel,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    // None option (null value)
                    _buildIconOption(context, null, selectedIcon == null),
                    // All IconCategory values
                    ...IconCategory.values.map((category) {
                      final isSelected = category == selectedIcon;
                      return _buildIconOption(context, category, isSelected);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconOption(
    BuildContext context,
    IconCategory? category,
    bool isSelected,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return Semantics(
      label: AccessibilityHelper.getIconSemanticLabel(category, isSelected),
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: () => onIconSelected(category),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.2)
                    : isDark
                        ? Colors.grey[800]
                        : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Icon(
                _getIconData(category),
                size: 28,
                color: isSelected
                    ? primaryColor
                    : isDark
                        ? Colors.grey[400]
                        : Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getIconLabel(category),
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? isDark
                        ? Colors.white
                        : Colors.black87
                    : isDark
                        ? Colors.grey[500]
                        : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(IconCategory? category) {
    if (category == null) return Icons.block;
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

  String _getIconLabel(IconCategory? category) {
    if (category == null) return UiStrings.iconNone;
    switch (category) {
      case IconCategory.work:
        return UiStrings.iconWork;
      case IconCategory.personal:
        return UiStrings.iconPersonal;
      case IconCategory.shopping:
        return UiStrings.iconShopping;
      case IconCategory.health:
        return UiStrings.iconHealth;
      case IconCategory.finance:
        return UiStrings.iconFinance;
      case IconCategory.important:
        return UiStrings.iconImportant;
      case IconCategory.ideas:
        return UiStrings.iconIdeas;
    }
  }
}
