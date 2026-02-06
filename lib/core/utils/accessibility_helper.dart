import 'package:flutter/material.dart';
import 'package:ephenotes/data/models/note.dart';

/// Utility class for accessibility-related functionality.
///
/// Provides semantic labels, descriptions, and accessibility helpers
/// for VoiceOver (iOS) and TalkBack (Android) screen readers.
class AccessibilityHelper {
  AccessibilityHelper._();

  /// Generates semantic label for a note card.
  ///
  /// Format: "Note: [content]. Priority: [priority]. [pinned status]. [timestamp]"
  static String getNoteCardSemanticLabel(Note note) {
    final buffer = StringBuffer();

    // Note content (truncated if too long)
    final content = note.content.length > 50
        ? '${note.content.substring(0, 50)}...'
        : note.content;
    buffer.write('Note: $content. ');

    // Priority
    buffer.write('Priority: ${_getPriorityText(note.priority)}. ');

    // Pinned status
    if (note.isPinned) {
      buffer.write('Pinned. ');
    }

    // Icon category
    if (note.iconCategory != null) {
      buffer.write('Category: ${_getIconCategoryText(note.iconCategory!)}. ');
    }

    // Timestamp
    buffer.write(_getTimestampText(note.createdAt));

    return buffer.toString();
  }

  /// Generates semantic hint for a note card.
  static String getNoteCardSemanticHint() {
    return 'Double tap to edit note. Swipe left or right to archive.';
  }

  /// Generates semantic label for priority selector.
  static String getPrioritySemanticLabel(
      NotePriority priority, bool isSelected) {
    final priorityText = _getPriorityText(priority);
    final status = isSelected ? 'selected' : 'not selected';
    return '$priorityText priority, $status';
  }

  /// Generates semantic label for color picker.
  static String getColorSemanticLabel(NoteColor color, bool isSelected) {
    final colorText = _getColorText(color);
    final status = isSelected ? 'selected' : 'not selected';
    return '$colorText color, $status';
  }

  /// Generates semantic label for icon category selector.
  static String getIconSemanticLabel(IconCategory? category, bool isSelected) {
    if (category == null) {
      final status = isSelected ? 'selected' : 'not selected';
      return 'No icon, $status';
    }

    final categoryText = _getIconCategoryText(category);
    final status = isSelected ? 'selected' : 'not selected';
    return '$categoryText icon, $status';
  }

  /// Generates semantic label for floating action button.
  static String getFabSemanticLabel() {
    return 'Create new note';
  }

  /// Generates semantic label for search results.
  static String getSearchResultsSemanticLabel(int count) {
    if (count == 0) {
      return 'No search results found';
    } else if (count == 1) {
      return '1 search result found';
    } else {
      return '$count search results found';
    }
  }

  /// Generates semantic label for archive action.
  static String getArchiveActionSemanticLabel() {
    return 'Archive note';
  }

  /// Generates semantic label for pin/unpin action.
  static String getPinActionSemanticLabel(bool isPinned) {
    return isPinned ? 'Unpin note' : 'Pin note';
  }

  /// Generates semantic label for character counter.
  static String getCharacterCounterSemanticLabel(int current, int max) {
    final remaining = max - current;
    if (remaining <= 0) {
      return 'Character limit reached. $current of $max characters used.';
    } else if (remaining <= 10) {
      return '$remaining characters remaining. $current of $max characters used.';
    } else {
      return '$current of $max characters used';
    }
  }

  /// Generates semantic label for text formatting buttons.
  static String getFormattingSemanticLabel(String type, bool isActive) {
    final status = isActive ? 'enabled' : 'disabled';
    return '$type formatting $status';
  }

  /// Generates semantic label for empty state.
  static String getEmptyStateSemanticLabel() {
    return 'No notes available. Tap the create note button to add your first note.';
  }

  /// Generates semantic label for loading state.
  static String getLoadingSemanticLabel() {
    return 'Loading notes';
  }

  /// Generates semantic label for error state.
  static String getErrorSemanticLabel(String error) {
    return 'Error loading notes: $error';
  }

  /// Generates semantic label for undo action.
  static String getUndoSemanticLabel() {
    return 'Undo archive action';
  }

  /// Generates semantic label for theme toggle.
  static String getThemeToggleSemanticLabel(ThemeMode currentMode) {
    return switch (currentMode) {
      ThemeMode.system => 'Theme mode: System. Tap to switch to light mode.',
      ThemeMode.light => 'Theme mode: Light. Tap to switch to dark mode.',
      ThemeMode.dark => 'Theme mode: Dark. Tap to switch to system mode.',
    };
  }

  // Helper methods for external access

  static String getPriorityText(NotePriority priority) {
    return _getPriorityText(priority);
  }

  static String getColorText(NoteColor color) {
    return _getColorText(color);
  }

  static String getIconCategoryText(IconCategory category) {
    return _getIconCategoryText(category);
  }

  static String getTimestampText(DateTime dateTime) {
    return _getTimestampText(dateTime);
  }

  // Private helper methods

  static String _getPriorityText(NotePriority priority) {
    return switch (priority) {
      NotePriority.high => 'High',
      NotePriority.normal => 'Normal',
      NotePriority.low => 'Low',
    };
  }

  static String _getColorText(NoteColor color) {
    return switch (color) {
      NoteColor.classicYellow => 'Classic Yellow',
      NoteColor.coralPink => 'Coral Pink',
      NoteColor.skyBlue => 'Sky Blue',
      NoteColor.mintGreen => 'Mint Green',
      NoteColor.lavender => 'Lavender',
      NoteColor.peach => 'Peach',
      NoteColor.teal => 'Teal',
      NoteColor.lightGray => 'Light Gray',
      NoteColor.lemon => 'Lemon',
      NoteColor.rose => 'Rose',
    };
  }

  static String _getIconCategoryText(IconCategory category) {
    return switch (category) {
      IconCategory.work => 'Work',
      IconCategory.personal => 'Personal',
      IconCategory.shopping => 'Shopping',
      IconCategory.health => 'Health',
      IconCategory.finance => 'Finance',
      IconCategory.important => 'Important',
      IconCategory.ideas => 'Ideas',
    };
  }

  static String _getTimestampText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Created just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'Created $minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'Created $hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return 'Created $days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return 'Created on ${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
