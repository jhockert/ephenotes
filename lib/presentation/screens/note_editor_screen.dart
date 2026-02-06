import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:ephenotes/core/constants/app_colors.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/core/utils/contrast_checker.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/widgets/color_picker.dart';
import 'package:ephenotes/presentation/widgets/priority_selector.dart';
import 'package:ephenotes/presentation/widgets/icon_selector.dart';

/// Screen for creating or editing notes.
///
/// Features:
/// - Text input with 140 character limit
/// - Character counter with color feedback
/// - Color picker
/// - Priority selector
/// - Icon category selector
/// - Text formatting options
/// - Save and cancel actions
class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _textController;
  late NoteColor _selectedColor;
  late NotePriority _selectedPriority;
  late IconCategory? _selectedIcon;
  late FontSize _selectedFontSize;
  late ListType _selectedListType;
  late bool _isBold;
  late bool _isItalic;
  late bool _isUnderlined;

  int _characterCount = 0;
  static const int _maxCharacters = 140;

  @override
  void initState() {
    super.initState();

    // Initialize with existing note data or defaults
    if (widget.note != null) {
      _textController = TextEditingController(text: widget.note!.content);
      _selectedColor = widget.note!.color;
      _selectedPriority = widget.note!.priority;
      _selectedIcon = widget.note!.iconCategory;
      _selectedFontSize = widget.note!.fontSize;
      _selectedListType = widget.note!.listType;
      _isBold = widget.note!.isBold;
      _isItalic = widget.note!.isItalic;
      _isUnderlined = widget.note!.isUnderlined;
      _characterCount = widget.note!.content.length;
    } else {
      _textController = TextEditingController();
      _selectedColor = NoteColor.classicYellow;
      _selectedPriority = NotePriority.normal;
      _selectedIcon = null;
      _selectedFontSize = FontSize.medium;
      _selectedListType = ListType.none;
      _isBold = false;
      _isItalic = false;
      _isUnderlined = false;
    }

    _textController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _textController.text.length;
    });
  }

  Color _getCounterColor() {
    if (_characterCount >= 140) {
      return Colors.red;
    } else if (_characterCount >= 135) {
      return Colors.orange;
    } else if (_characterCount >= 130) {
      return Colors.yellow[700]!;
    }
    return Colors.grey;
  }

  void _saveNote() {
    final content = _textController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(UiStrings.noteCannotBeEmpty),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (widget.note == null) {
      // Create new note
      final newNote = Note(
        id: const Uuid().v4(),
        content: content,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: _selectedColor,
        priority: _selectedPriority,
        iconCategory: _selectedIcon,
        fontSize: _selectedFontSize,
        listType: _selectedListType,
        isBold: _isBold,
        isItalic: _isItalic,
        isUnderlined: _isUnderlined,
      );

      context.read<NotesBloc>().add(CreateNote(newNote));
    } else {
      // Update existing note
      final updatedNote = widget.note!.copyWith(
        content: content,
        color: _selectedColor,
        priority: _selectedPriority,
        iconCategory: _selectedIcon,
        fontSize: _selectedFontSize,
        listType: _selectedListType,
        isBold: _isBold,
        isItalic: _isItalic,
        isUnderlined: _isUnderlined,
        updatedAt: DateTime.now(),
      );

      context.read<NotesBloc>().add(UpdateNote(updatedNote));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.note == null ? UiStrings.newNote : UiStrings.editNote),
        actions: [
          Semantics(
            label: UiStrings.saveNoteLabel,
            hint: UiStrings.saveNoteHint,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
              tooltip: UiStrings.save,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Note content text field
            Builder(
              builder: (context) {
                final brightness = Theme.of(context).brightness;
                final backgroundColor =
                    AppColors.getNoteColor(_selectedColor, brightness);
                final textColor =
                    AppColors.noteTextColor(brightness, _selectedColor);
                final secondaryColor = AppColors.noteSecondaryTextColor(
                    brightness, _selectedColor);

                // Ensure WCAG AA compliance
                final accessibleTextColor =
                    ContrastChecker.meetsWCAGAANormalText(
                            textColor, backgroundColor)
                        ? textColor
                        : ContrastChecker.suggestAccessibleForeground(
                            textColor, backgroundColor);

                final accessibleSecondaryColor =
                    ContrastChecker.meetsWCAGAANormalText(
                            secondaryColor, backgroundColor)
                        ? secondaryColor
                        : ContrastChecker.suggestAccessibleForeground(
                            secondaryColor, backgroundColor);

                return Semantics(
                  label: UiStrings.noteContentFieldLabel,
                  hint: UiStrings.noteContentFieldHint,
                  textField: true,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textController,
                      maxLength: _maxCharacters,
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: UiStrings.enterNotePlaceholder,
                        border: InputBorder.none,
                        counterText: '',
                        hintStyle: TextStyle(
                          color: accessibleSecondaryColor,
                        ),
                      ),
                      style: TextStyle(
                        fontSize: _getFontSize(_selectedFontSize),
                        fontWeight:
                            _isBold ? FontWeight.bold : FontWeight.normal,
                        fontStyle:
                            _isItalic ? FontStyle.italic : FontStyle.normal,
                        decoration: _isUnderlined
                            ? TextDecoration.underline
                            : TextDecoration.none,
                        color: accessibleTextColor,
                      ),
                      onChanged: (text) {
                        if (text.length == _maxCharacters) {
                          HapticFeedback.lightImpact();
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            // Character counter
            Semantics(
              label: AccessibilityHelper.getCharacterCounterSemanticLabel(
                  _characterCount, _maxCharacters),
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 4),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '$_characterCount/$_maxCharacters',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getCounterColor(),
                      fontWeight: _characterCount >= 130
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Text formatting options
            Semantics(
              label: UiStrings.textFormattingLabel,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        UiStrings.textFormattingTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Semantics(
                            label:
                                AccessibilityHelper.getFormattingSemanticLabel(
                                    UiStrings.bold, _isBold),
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.format_bold),
                              isSelected: _isBold,
                              onPressed: () {
                                setState(() {
                                  _isBold = !_isBold;
                                });
                              },
                              tooltip: UiStrings.bold,
                            ),
                          ),
                          Semantics(
                            label:
                                AccessibilityHelper.getFormattingSemanticLabel(
                                    UiStrings.italic, _isItalic),
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.format_italic),
                              isSelected: _isItalic,
                              onPressed: () {
                                setState(() {
                                  _isItalic = !_isItalic;
                                });
                              },
                              tooltip: UiStrings.italic,
                            ),
                          ),
                          Semantics(
                            label:
                                AccessibilityHelper.getFormattingSemanticLabel(
                                    UiStrings.underline, _isUnderlined),
                            button: true,
                            child: IconButton(
                              icon: const Icon(Icons.format_underline),
                              isSelected: _isUnderlined,
                              onPressed: () {
                                setState(() {
                                  _isUnderlined = !_isUnderlined;
                                });
                              },
                              tooltip: UiStrings.underline,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Semantics(
                            label: UiStrings.fontSize(_selectedFontSize.name),
                            button: true,
                            child: DropdownButton<FontSize>(
                              value: _selectedFontSize,
                              items: const [
                                DropdownMenuItem(
                                  value: FontSize.small,
                                  child: Text(UiStrings.fontSizeSmall),
                                ),
                                DropdownMenuItem(
                                  value: FontSize.medium,
                                  child: Text(UiStrings.fontSizeMedium),
                                ),
                                DropdownMenuItem(
                                  value: FontSize.large,
                                  child: Text(UiStrings.fontSizeLarge),
                                ),
                              ],
                              onChanged: (size) {
                                if (size != null) {
                                  setState(() {
                                    _selectedFontSize = size;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Color picker
            ColorPicker(
              selectedColor: _selectedColor,
              onColorSelected: (color) {
                setState(() {
                  _selectedColor = color;
                });
              },
            ),

            const SizedBox(height: 16),

            // Priority selector
            PrioritySelector(
              selectedPriority: _selectedPriority,
              onPrioritySelected: (priority) {
                setState(() {
                  _selectedPriority = priority;
                });
              },
            ),

            const SizedBox(height: 16),

            // Icon category selector
            IconSelector(
              selectedIcon: _selectedIcon,
              onIconSelected: (icon) {
                setState(() {
                  _selectedIcon = icon;
                });
              },
            ),
          ],
        ),
      ),
    );
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
}
