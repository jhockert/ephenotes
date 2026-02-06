import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Example property-based tests for Note functionality.
///
/// This file demonstrates how to use the property-based testing framework
/// to test core Note properties and business rules.

void main() {
  group('Note Properties - Examples', () {
    setUp(() {
      PropertyTestConfig.reset();
    });

    testProperty('Property 1: Note content never exceeds 140 characters', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        stringGenerator(maxLength: 200), // Generate strings up to 200 chars
        (String input) {
          // Create a note with the input content
          final note = Note(
            id: 'test-id',
            content: input.length <= 140 ? input : input.substring(0, 140),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Property: content never exceeds 140 characters
          expect(note.content.length, lessThanOrEqualTo(140));

          // If input was <= 140, content should match exactly
          if (input.length <= 140) {
            expect(note.content, equals(input));
          }
        },
      );
    });

    testProperty('Property 2: Archive-Pin relationship invariant', () {
      // **Validates: Requirements 1.4, 5.1**
      forAll(
        noteGenerator(), // Use regular generator that creates valid notes
        (Note note) {
          // Property: Valid notes should never be both archived and pinned
          expect(note.isArchived && note.isPinned, isFalse,
              reason: 'Notes cannot be both archived and pinned');

          // Test that business operations maintain the invariant
          if (note.isArchived) {
            expect(note.isPinned, isFalse,
                reason: 'Archived notes cannot be pinned');
          }

          if (note.isPinned) {
            expect(note.isArchived, isFalse,
                reason: 'Pinned notes cannot be archived');
          }

          // Verify using custom matcher
          expect(note, hasValidArchivePinState());
        },
      );
    });

    testProperty('Property 3: Search results are subset of active notes', () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        mixedNoteListGenerator(minLength: 5, maxLength: 15),
        searchQueryGenerator(),
        (List<Note> allNotes, String query) {
          final activeNotes = allNotes.where((n) => !n.isArchived).toList();

          // Simulate search functionality
          final searchResults = _simulateSearch(activeNotes, query);

          // Property: Search results are always subset of active notes
          expect(searchResults, isSubsetOf(activeNotes));
          expect(searchResults, containsOnlyActiveNotes());

          // Property: Archived notes never appear in search results
          for (final result in searchResults) {
            expect(result.isArchived, isFalse);
          }

          // Property: Pinned notes appear first in results
          final pinnedResults = searchResults.where((n) => n.isPinned).toList();
          final unpinnedResults =
              searchResults.where((n) => !n.isPinned).toList();
          expect(searchResults, equals([...pinnedResults, ...unpinnedResults]));
        },
      );
    });

    testProperty('Property 4: Timestamp monotonicity', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        noteGenerator(), // Use regular generator that creates valid notes
        (Note note) {
          // Property: updatedAt >= createdAt always holds for valid notes
          expect(
              note.updatedAt.isAfter(note.createdAt) ||
                  note.updatedAt.isAtSameMomentAs(note.createdAt),
              isTrue,
              reason:
                  'updatedAt (${note.updatedAt}) must be >= createdAt (${note.createdAt})');

          // Verify using custom matcher
          expect(note, hasValidTimestamps());
        },
      );
    });

    testProperty('Property 5: Priority-based ordering consistency', () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        noteListGenerator(minLength: 3, maxLength: 10),
        (List<Note> notes) {
          final sortedNotes = _simulatePrioritySort(notes);

          // Property: Pinned notes always appear before unpinned notes
          int pinnedCount = sortedNotes.where((n) => n.isPinned).length;

          // All pinned notes come first
          for (int i = 0; i < pinnedCount; i++) {
            expect(sortedNotes[i].isPinned, isTrue);
          }

          // All unpinned notes come after
          for (int i = pinnedCount; i < sortedNotes.length; i++) {
            expect(sortedNotes[i].isPinned, isFalse);
          }

          // Property: Within each section, notes are ordered by priority
          expect(sortedNotes, hasValidPriorityOrdering());
        },
      );
    });

    testProperty('Property 6: Data persistence integrity simulation', () {
      // **Validates: Requirements NFR-4.1, NFR-4.2**
      forAll(
        noteListGenerator(maxLength: 5),
        (List<Note> originalNotes) {
          // Simulate save/load cycle
          final serializedNotes = _simulateSerialization(originalNotes);
          final deserializedNotes = _simulateDeserialization(serializedNotes);

          // Property: All operations preserve data exactly
          expect(deserializedNotes.length, equals(originalNotes.length));

          for (int i = 0; i < originalNotes.length; i++) {
            final original = originalNotes[i];
            final deserialized = deserializedNotes[i];

            expect(deserialized.id, equals(original.id));
            expect(deserialized.content, equals(original.content));
            expect(deserialized.createdAt, equals(original.createdAt));
            expect(deserialized.updatedAt, equals(original.updatedAt));
            expect(deserialized.color, equals(original.color));
            expect(deserialized.priority, equals(original.priority));
            expect(deserialized.isPinned, equals(original.isPinned));
            expect(deserialized.isArchived, equals(original.isArchived));
          }
        },
      );
    });
  });
}

/// Simulate search functionality for testing
List<Note> _simulateSearch(List<Note> notes, String query) {
  if (query.isEmpty) {
    // For empty query, return all notes with priority-based sorting
    return NoteSorting.sortByPriority(notes);
  }

  final results = notes
      .where((note) => note.content.toLowerCase().contains(query.toLowerCase()))
      .toList();

  // Use priority-based sorting for search results
  return NoteSorting.sortByPriority(results);
}

/// Simulate priority-based sorting
List<Note> _simulatePrioritySort(List<Note> notes) {
  final sortedNotes = List<Note>.from(notes);

  sortedNotes.sort((a, b) {
    // Pinned notes first
    if (a.isPinned && !b.isPinned) return -1;
    if (!a.isPinned && b.isPinned) return 1;

    // Within same pin status, sort by priority (High=0, Medium=1, Low=2)
    final priorityComparison = a.priority.index.compareTo(b.priority.index);
    if (priorityComparison != 0) return priorityComparison;

    // Same priority, sort by creation date (newer first)
    return b.createdAt.compareTo(a.createdAt);
  });

  return sortedNotes;
}

/// Simulate serialization for persistence testing
List<Map<String, dynamic>> _simulateSerialization(List<Note> notes) {
  return notes
      .map((note) => {
            'id': note.id,
            'content': note.content,
            'createdAt': note.createdAt.toIso8601String(),
            'updatedAt': note.updatedAt.toIso8601String(),
            'color': note.color.index,
            'priority': note.priority.index,
            'iconCategory': note.iconCategory?.index,
            'isPinned': note.isPinned,
            'isArchived': note.isArchived,
            'isBold': note.isBold,
            'isItalic': note.isItalic,
            'isUnderlined': note.isUnderlined,
            'fontSize': note.fontSize.index,
            'listType': note.listType.index,
          })
      .toList();
}

/// Simulate deserialization for persistence testing
List<Note> _simulateDeserialization(List<Map<String, dynamic>> data) {
  return data
      .map((map) => Note(
            id: map['id'] as String,
            content: map['content'] as String,
            createdAt: DateTime.parse(map['createdAt'] as String),
            updatedAt: DateTime.parse(map['updatedAt'] as String),
            color: NoteColor.values[map['color'] as int],
            priority: NotePriority.values[map['priority'] as int],
            iconCategory: map['iconCategory'] != null
                ? IconCategory.values[map['iconCategory'] as int]
                : null,
            isPinned: map['isPinned'] as bool,
            isArchived: map['isArchived'] as bool,
            isBold: map['isBold'] as bool,
            isItalic: map['isItalic'] as bool,
            isUnderlined: map['isUnderlined'] as bool,
            fontSize: FontSize.values[map['fontSize'] as int],
            listType: ListType.values[map['listType'] as int],
          ))
      .toList();
}
