import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';

/// Custom matchers for Note properties used in property-based testing.
///
/// These matchers provide semantic assertions for note-specific business rules
/// and constraints, making property-based tests more readable and maintainable.

/// Matcher that verifies a note's content length is within the valid range
Matcher hasValidContentLength() {
  return _HasValidContentLength();
}

class _HasValidContentLength extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.content.length <= 140;
  }

  @override
  Description describe(Description description) {
    return description.add('has content length <= 140 characters');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('has content length ${item.content.length}');
  }
}

/// Matcher that verifies a note cannot be both archived and pinned
Matcher hasValidArchivePinState() {
  return _HasValidArchivePinState();
}

class _HasValidArchivePinState extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return !(item.isArchived && item.isPinned);
  }

  @override
  Description describe(Description description) {
    return description.add('is not both archived and pinned');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add(
        'is both archived (${item.isArchived}) and pinned (${item.isPinned})');
  }
}

/// Matcher that verifies a note's timestamps follow logical ordering
Matcher hasValidTimestamps() {
  return _HasValidTimestamps();
}

class _HasValidTimestamps extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.updatedAt.isAfter(item.createdAt) ||
        item.updatedAt.isAtSameMomentAs(item.createdAt);
  }

  @override
  Description describe(Description description) {
    return description.add('has updatedAt >= createdAt');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add(
        'has updatedAt (${item.updatedAt}) before createdAt (${item.createdAt})');
  }
}

/// Matcher that verifies a note is active (not archived)
Matcher isActiveNote() {
  return _IsActiveNote();
}

class _IsActiveNote extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return !item.isArchived;
  }

  @override
  Description describe(Description description) {
    return description.add('is an active note (not archived)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('is archived');
  }
}

/// Matcher that verifies a note is archived
Matcher isArchivedNote() {
  return _IsArchivedNote();
}

class _IsArchivedNote extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.isArchived;
  }

  @override
  Description describe(Description description) {
    return description.add('is an archived note');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('is not archived');
  }
}

/// Matcher that verifies a note is pinned
Matcher isPinnedNote() {
  return _IsPinnedNote();
}

class _IsPinnedNote extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.isPinned;
  }

  @override
  Description describe(Description description) {
    return description.add('is a pinned note');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('is not pinned');
  }
}

/// Matcher that verifies a list of notes follows priority-based ordering
Matcher hasValidPriorityOrdering() {
  return _HasValidPriorityOrdering();
}

class _HasValidPriorityOrdering extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<Note>) return false;

    final notes = item;
    if (notes.length <= 1) return true;

    // Find the boundary between pinned and unpinned notes
    int pinnedCount = 0;
    for (final note in notes) {
      if (note.isPinned) {
        pinnedCount++;
      } else {
        break; // All pinned notes should be at the beginning
      }
    }

    // Verify all pinned notes come first
    for (int i = 0; i < pinnedCount; i++) {
      if (!notes[i].isPinned) return false;
    }

    // Verify all unpinned notes come after
    for (int i = pinnedCount; i < notes.length; i++) {
      if (notes[i].isPinned) return false;
    }

    // Verify priority ordering within pinned section
    if (!_hasValidPriorityOrderingInSection(notes.take(pinnedCount).toList())) {
      return false;
    }

    // Verify priority ordering within unpinned section
    if (!_hasValidPriorityOrderingInSection(notes.skip(pinnedCount).toList())) {
      return false;
    }

    return true;
  }

  bool _hasValidPriorityOrderingInSection(List<Note> notes) {
    for (int i = 0; i < notes.length - 1; i++) {
      final current = notes[i];
      final next = notes[i + 1];

      // Higher priority (lower index) should come first
      if (current.priority.index > next.priority.index) {
        return false;
      }

      // Same priority should be ordered by creation date (newer first)
      if (current.priority == next.priority) {
        if (current.createdAt.isBefore(next.createdAt)) {
          return false;
        }
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add(
        'has valid priority-based ordering (pinned first, then by priority High→Medium→Low, then by creation date)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! List<Note>) {
      return mismatchDescription.add('is not a List<Note>');
    }
    return mismatchDescription
        .add('does not follow priority-based ordering rules');
  }
}

/// Matcher that verifies all notes in a list are active (not archived)
Matcher containsOnlyActiveNotes() {
  return _ContainsOnlyActiveNotes();
}

class _ContainsOnlyActiveNotes extends Matcher {
  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<Note>) return false;
    return item.every((note) => !note.isArchived);
  }

  @override
  Description describe(Description description) {
    return description.add('contains only active notes');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! List<Note>) {
      return mismatchDescription.add('is not a List<Note>');
    }
    final archivedCount =
        item.where((note) => note.isArchived).length;
    return mismatchDescription.add('contains $archivedCount archived notes');
  }
}

/// Matcher that verifies a search result is a subset of the original list
Matcher isSubsetOf(List<Note> originalNotes) {
  return _IsSubsetOf(originalNotes);
}

class _IsSubsetOf extends Matcher {
  final List<Note> originalNotes;

  _IsSubsetOf(this.originalNotes);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! List<Note>) return false;

    final searchResults = item;
    for (final result in searchResults) {
      if (!originalNotes.any((note) => note.id == result.id)) {
        return false;
      }
    }
    return true;
  }

  @override
  Description describe(Description description) {
    return description.add('is a subset of the original notes list');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! List<Note>) {
      return mismatchDescription.add('is not a List<Note>');
    }
    return mismatchDescription.add('contains notes not in the original list');
  }
}

/// Matcher that verifies a note has specific priority
Matcher hasPriority(NotePriority priority) {
  return _HasPriority(priority);
}

class _HasPriority extends Matcher {
  final NotePriority expectedPriority;

  _HasPriority(this.expectedPriority);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.priority == expectedPriority;
  }

  @override
  Description describe(Description description) {
    return description.add('has priority $expectedPriority');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('has priority ${item.priority}');
  }
}

/// Matcher that verifies a note contains specific text (case-insensitive)
Matcher containsText(String text) {
  return _ContainsText(text);
}

class _ContainsText extends Matcher {
  final String expectedText;

  _ContainsText(this.expectedText);

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is! Note) return false;
    return item.content.toLowerCase().contains(expectedText.toLowerCase());
  }

  @override
  Description describe(Description description) {
    return description.add('contains text "$expectedText" (case-insensitive)');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    if (item is! Note) {
      return mismatchDescription.add('is not a Note');
    }
    return mismatchDescription.add('has content "${item.content}"');
  }
}
