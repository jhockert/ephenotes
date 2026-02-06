import '../../data/models/note.dart';

/// Utility class for sorting notes according to priority-based rules.
class NoteSorting {
  /// Sorts notes with priority-based ordering:
  /// 1. Pinned notes appear first, ordered by priority (High → Normal → Low), then by creation date (newest first)
  /// 2. Unpinned notes appear second, ordered by priority (High → Normal → Low), then by creation date (newest first)
  static List<Note> sortByPriority(List<Note> notes) {
    final sortedNotes = List<Note>.from(notes);

    sortedNotes.sort((a, b) {
      // Pinned notes first
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;

      // Within same pin status, sort by priority (High=0, Normal=1, Low=2)
      final priorityComparison = a.priority.index.compareTo(b.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Same priority, sort by creation date (newer first)
      return b.createdAt.compareTo(a.createdAt);
    });

    return sortedNotes;
  }
}
