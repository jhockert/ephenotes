import 'package:flutter/material.dart';
import 'package:ephenotes/core/constants/app_colors.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/data/models/note.dart';

/// Widget for selecting note color from available options.
///
/// Displays all 10 color options as circular buttons in a grid.
class ColorPicker extends StatelessWidget {
  final NoteColor selectedColor;
  final ValueChanged<NoteColor> onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Semantics(
      label: UiStrings.colorPickerLabel,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                UiStrings.colorSectionTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.noteTextColor(brightness, selectedColor),
                ),
              ),
              const SizedBox(height: 12),
              Semantics(
                label: UiStrings.colorOptionsLabel,
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: NoteColor.values.map((color) {
                    final isSelected = color == selectedColor;
                    return Semantics(
                      label: AccessibilityHelper.getColorSemanticLabel(
                          color, isSelected),
                      button: true,
                      selected: isSelected,
                      child: GestureDetector(
                        onTap: () => onColorSelected(color),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.getNoteColor(color, brightness),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(
                                    color: isDark ? Colors.white : Colors.black,
                                    width: 3,
                                  )
                                : Border.all(
                                    color: isDark
                                        ? Colors.grey[700]!
                                        : Colors.grey[300]!,
                                    width: 1,
                                  ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: isDark ? Colors.white : Colors.black87,
                                  size: 24,
                                )
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              Semantics(
                label: UiStrings.selectedColor(_getColorName(selectedColor)),
                child: Text(
                  _getColorName(selectedColor),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.noteSecondaryTextColor(
                        brightness, selectedColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getColorName(NoteColor color) {
    switch (color) {
      case NoteColor.classicYellow:
        return UiStrings.colorClassicYellow;
      case NoteColor.coralPink:
        return UiStrings.colorCoralPink;
      case NoteColor.skyBlue:
        return UiStrings.colorSkyBlue;
      case NoteColor.mintGreen:
        return UiStrings.colorMintGreen;
      case NoteColor.lavender:
        return UiStrings.colorLavender;
      case NoteColor.peach:
        return UiStrings.colorPeach;
      case NoteColor.teal:
        return UiStrings.colorTeal;
      case NoteColor.lightGray:
        return UiStrings.colorLightGray;
      case NoteColor.lemon:
        return UiStrings.colorLemon;
      case NoteColor.rose:
        return UiStrings.colorRose;
    }
  }
}
