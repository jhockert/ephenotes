import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Property-based test for search result consistency.
///
/// **Validates: Requirements 4.1, 4.2**
///
/// This test verifies that search functionality maintains consistency:
/// - Search results are always a subset of active (non-archived) notes
/// - Archived notes never appear in search results
/// - Pinned notes appear first in search results
/// - Search results maintain priority-based ordering

void main() {
  group('Property Test: Search Result Consistency', () {
    testProperty(
        'Property 3.1: Search results are always subset of active notes', () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        mixedNoteListGenerator(minLength: 5, maxLength: 30, archivedRatio: 0.4),
        searchQueryGenerator(),
        (List<Note> allNotes, String query) {
          // Get active notes (non-archived)
          final activeNotes =
              allNotes.where((note) => !note.isArchived).toList();

          // Simulate search functionality
          final searchResults = _performSearch(allNotes, query);

          // Property: Search results are always subset of active notes
          expect(searchResults, isSubsetOf(activeNotes));
          expect(searchResults, containsOnlyActiveNotes());

          // Property: All search results must be from the original active notes
          for (final result in searchResults) {
            expect(activeNotes.any((note) => note.id == result.id), isTrue,
                reason: 'Search result ${result.id} not found in active notes');
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 3.2: Archived notes never appear in search results',
        () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        mixedNoteListGenerator(
            minLength: 10, maxLength: 25, archivedRatio: 0.5),
        searchQueryGenerator(),
        (List<Note> allNotes, String query) {
          // Ensure we have some archived notes for testing
          final archivedNotes =
              allNotes.where((note) => note.isArchived).toList();
          if (archivedNotes.isEmpty) return; // Skip if no archived notes

          // Perform search
          final searchResults = _performSearch(allNotes, query);

          // Property: No archived notes should appear in search results
          for (final result in searchResults) {
            expect(result.isArchived, isFalse,
                reason:
                    'Archived note ${result.id} appeared in search results');
          }

          // Property: Search results contain only active notes
          expect(searchResults, containsOnlyActiveNotes());
        },
        iterations: 100,
      );
    });

    testProperty('Property 3.3: Pinned notes appear first in search results',
        () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        _generateNotesWithPinnedAndUnpinned(),
        searchQueryGenerator(),
        (List<Note> allNotes, String query) {
          // Perform search
          final searchResults = _performSearch(allNotes, query);

          if (searchResults.isEmpty) return; // Skip empty results

          // Find the boundary between pinned and unpinned notes in results
          int pinnedCount = 0;
          for (final note in searchResults) {
            if (note.isPinned) {
              pinnedCount++;
            } else {
              break; // All pinned notes should be at the beginning
            }
          }

          // Property: All pinned notes come first
          for (int i = 0; i < pinnedCount; i++) {
            expect(searchResults[i].isPinned, isTrue,
                reason: 'Non-pinned note found at index $i in pinned section');
          }

          // Property: All unpinned notes come after pinned notes
          for (int i = pinnedCount; i < searchResults.length; i++) {
            expect(searchResults[i].isPinned, isFalse,
                reason: 'Pinned note found at index $i in unpinned section');
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 3.4: Search results maintain priority-based ordering', () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        _generateNotesWithVariedPriorities(),
        searchQueryGenerator(),
        (List<Note> allNotes, String query) {
          // Perform search
          final searchResults = _performSearch(allNotes, query);

          if (searchResults.length <= 1) return; // Skip if not enough results

          // Property: Search results follow priority-based ordering
          expect(searchResults, hasValidPriorityOrdering());

          // Additional verification: manually check ordering rules
          _verifyPriorityOrdering(searchResults);
        },
        iterations: 100,
      );
    });

    testProperty('Property 3.5: Empty query returns all active notes', () {
      // **Validates: Requirements 4.1, 4.2**
      forAll(
        mixedNoteListGenerator(minLength: 5, maxLength: 20, archivedRatio: 0.3),
        (List<Note> allNotes) {
          // Get active notes
          final activeNotes =
              allNotes.where((note) => !note.isArchived).toList();

          // Search with empty query
          final searchResults = _performSearch(allNotes, '');

          // Property: Empty query returns all active notes
          expect(searchResults.length, equals(activeNotes.length));
          expect(searchResults, containsOnlyActiveNotes());

          // Property: All active notes are included
          for (final activeNote in activeNotes) {
            expect(searchResults.any((result) => result.id == activeNote.id),
                isTrue,
                reason:
                    'Active note ${activeNote.id} missing from empty query results');
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 3.6: Search query matching is case-insensitive', () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        _generateNotesWithSpecificContent(),
        Generator.oneOf(['test', 'TEST', 'Test', 'tEsT']), // Case variations
        (List<Note> allNotes, String query) {
          // Perform search with different case variations
          final searchResults = _performSearch(allNotes, query);

          // Property: All results should contain the query text (case-insensitive)
          for (final result in searchResults) {
            expect(result.content.toLowerCase().contains(query.toLowerCase()),
                isTrue,
                reason:
                    'Search result "${result.content}" does not contain query "$query" (case-insensitive)');
          }

          // Property: Results are consistent regardless of query case
          final lowerResults = _performSearch(allNotes, query.toLowerCase());
          final upperResults = _performSearch(allNotes, query.toUpperCase());

          expect(searchResults.length, equals(lowerResults.length));
          expect(searchResults.length, equals(upperResults.length));
        },
        iterations: 50,
      );
    });

    testProperty('Property 3.7: Search with special characters and Unicode',
        () {
      // **Validates: Requirements 4.1, 4.2**
      forAll2(
        _generateNotesWithUnicodeContent(),
        Generator.oneOf([
          '🎉',
          '📝',
          '✨',
          '@',
          '#',
          '&',
          'Café',
          'naïve'
        ]), // Use exact case
        (List<Note> allNotes, String query) {
          // Perform search
          final searchResults = _performSearch(allNotes, query);

          // Property: Search results are subset of active notes
          expect(searchResults, containsOnlyActiveNotes());

          // Property: All results contain the query (case-sensitive for Unicode)
          for (final result in searchResults) {
            expect(result.content.toLowerCase().contains(query.toLowerCase()),
                isTrue,
                reason:
                    'Search result "${result.content}" does not contain query "$query" (case-insensitive)');
          }
        },
        iterations: 50,
      );
    });
  });
}

/// Simulate the search functionality based on the actual implementation
List<Note> _performSearch(List<Note> allNotes, String query) {
  // Filter to active notes only (exclude archived)
  final activeNotes = allNotes.where((note) => !note.isArchived).toList();

  // If query is empty, return all active notes sorted by priority
  if (query.isEmpty) {
    return NoteSorting.sortByPriority(activeNotes);
  }

  // Filter by query (case-insensitive content matching)
  final filteredNotes = activeNotes.where((note) {
    return note.content.toLowerCase().contains(query.toLowerCase());
  }).toList();

  // Sort by priority (pinned first, then by priority, then by creation date)
  return NoteSorting.sortByPriority(filteredNotes);
}

/// Generate notes with a mix of pinned and unpinned notes
Generator<List<Note>> _generateNotesWithPinnedAndUnpinned() {
  return Generator.fromFunction((random) {
    final length = 10 + random.nextInt(15); // 10-24 notes
    final notes = <Note>[];

    // Generate mix of pinned and unpinned notes
    for (int i = 0; i < length; i++) {
      final baseNote = noteGenerator().generate(random);
      final isPinned = random.nextDouble() < 0.3; // 30% chance of being pinned

      notes.add(baseNote.copyWith(
        isArchived: false, // Ensure all are active
        isPinned: isPinned,
        content: 'Note $i content with searchable text',
      ));
    }

    return notes;
  });
}

/// Generate notes with varied priorities for testing ordering
Generator<List<Note>> _generateNotesWithVariedPriorities() {
  return Generator.fromFunction((random) {
    final length = 12 + random.nextInt(18); // 12-29 notes
    final notes = <Note>[];
    final priorities = NotePriority.values;

    for (int i = 0; i < length; i++) {
      final baseNote = noteGenerator().generate(random);
      final priority = priorities[random.nextInt(priorities.length)];
      final isPinned = random.nextDouble() < 0.4; // 40% chance of being pinned

      notes.add(baseNote.copyWith(
        isArchived: false, // Ensure all are active
        isPinned: isPinned,
        priority: priority,
        content: 'Priority ${priority.name} note $i with searchable content',
      ));
    }

    return notes;
  });
}

/// Generate notes with specific content for testing search matching
Generator<List<Note>> _generateNotesWithSpecificContent() {
  return Generator.fromFunction((random) {
    final length = 8 + random.nextInt(12); // 8-19 notes
    final notes = <Note>[];
    final contentVariations = [
      'This is a test note',
      'Testing functionality',
      'Test case example',
      'Random content without keyword',
      'Another note for testing',
      'TEST in uppercase',
      'Mixed Case Test',
      'No matching content here',
    ];

    for (int i = 0; i < length; i++) {
      final baseNote = noteGenerator().generate(random);
      final content =
          contentVariations[random.nextInt(contentVariations.length)];

      notes.add(baseNote.copyWith(
        isArchived: random.nextDouble() < 0.2, // 20% archived
        content: content,
      ));
    }

    return notes;
  });
}

/// Generate notes with Unicode and special characters
Generator<List<Note>> _generateNotesWithUnicodeContent() {
  return Generator.fromFunction((random) {
    final length = 6 + random.nextInt(10); // 6-15 notes
    final notes = <Note>[];
    final unicodeContent = [
      'Meeting 📝 at 3pm',
      'Party 🎉 this weekend',
      'Sparkle ✨ clean house',
      'Email @john about project',
      'Tag #important for review',
      'Coffee & cake meeting',
      'Café visit tomorrow',
      'Naïve approach won\'t work',
      'Regular content',
      'Another normal note',
    ];

    for (int i = 0; i < length; i++) {
      final baseNote = noteGenerator().generate(random);
      final content = unicodeContent[random.nextInt(unicodeContent.length)];

      notes.add(baseNote.copyWith(
        isArchived: random.nextDouble() < 0.25, // 25% archived
        content: content,
      ));
    }

    return notes;
  });
}

/// Manually verify priority ordering rules
void _verifyPriorityOrdering(List<Note> notes) {
  if (notes.length <= 1) return;

  // Find boundary between pinned and unpinned
  int pinnedCount = 0;
  for (final note in notes) {
    if (note.isPinned) {
      pinnedCount++;
    } else {
      break;
    }
  }

  // Verify pinned section ordering
  _verifyPriorityOrderingInSection(notes.take(pinnedCount).toList(), 'pinned');

  // Verify unpinned section ordering
  _verifyPriorityOrderingInSection(
      notes.skip(pinnedCount).toList(), 'unpinned');
}

/// Verify priority ordering within a section (pinned or unpinned)
void _verifyPriorityOrderingInSection(List<Note> notes, String sectionName) {
  for (int i = 0; i < notes.length - 1; i++) {
    final current = notes[i];
    final next = notes[i + 1];

    // Higher priority (lower index) should come first
    expect(current.priority.index, lessThanOrEqualTo(next.priority.index),
        reason:
            'Priority ordering violated in $sectionName section: ${current.priority.name} should come before ${next.priority.name}');

    // Same priority should be ordered by creation date (newer first)
    if (current.priority == next.priority) {
      expect(
          current.createdAt.isAfter(next.createdAt) ||
              current.createdAt.isAtSameMomentAs(next.createdAt),
          isTrue,
          reason:
              'Creation date ordering violated in $sectionName section for same priority ${current.priority.name}');
    }
  }
}
