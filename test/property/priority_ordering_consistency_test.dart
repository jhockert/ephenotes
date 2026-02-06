import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Property-based test for priority-based ordering consistency.
///
/// **Validates: Requirements 3.1, 3.2**
///
/// This test verifies that note ordering follows priority rules consistently:
/// - Pinned notes always appear first, ordered by priority
/// - Unpinned notes appear second, ordered by priority
/// - Same-priority notes ordered by creation date (newest first)

void main() {
  group('Property Test: Priority-Based Ordering Consistency', () {
    setUp(() {
      PropertyTestConfig.reset();
    });

    testProperty(
        'Property 3.1: Note ordering follows priority rules consistently', () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        noteListGenerator(
          minLength: 0,
          maxLength: 50,
          allowLongContent: false,
          allowArchivedAndPinned: false,
          ensureValidTimestamps: true,
        ),
        (List<Note> notes) {
          // Sort the notes using the priority-based sorting algorithm
          final sortedNotes = NoteSorting.sortByPriority(notes);

          // Verify the sorted list follows priority ordering rules
          expect(sortedNotes, hasValidPriorityOrdering());

          // Verify all original notes are preserved (no notes lost or added)
          expect(sortedNotes.length, equals(notes.length));
          for (final originalNote in notes) {
            expect(
              sortedNotes.any((sorted) => sorted.id == originalNote.id),
              isTrue,
              reason:
                  'Note ${originalNote.id} should be preserved in sorted list',
            );
          }

          // Verify no duplicate notes in result
          final uniqueIds = sortedNotes.map((note) => note.id).toSet();
          expect(uniqueIds.length, equals(sortedNotes.length));
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 3.1.1: Pinned notes always appear before unpinned notes', () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate a mix of pinned and unpinned notes
          final pinnedNotes = noteListGenerator(
            minLength: 1,
            maxLength: 10,
            allowLongContent: false,
            allowArchivedAndPinned: false,
            ensureValidTimestamps: true,
          )
              .generate(random)
              .map((note) => note.copyWith(isPinned: true))
              .toList();

          final unpinnedNotes = noteListGenerator(
            minLength: 1,
            maxLength: 10,
            allowLongContent: false,
            allowArchivedAndPinned: false,
            ensureValidTimestamps: true,
          )
              .generate(random)
              .map((note) => note.copyWith(isPinned: false))
              .toList();

          // Shuffle the combined list to test sorting
          final allNotes = [...pinnedNotes, ...unpinnedNotes];
          allNotes.shuffle(random);
          return allNotes;
        }),
        (List<Note> mixedNotes) {
          final sortedNotes = NoteSorting.sortByPriority(mixedNotes);

          // Find the boundary between pinned and unpinned notes
          int pinnedCount = sortedNotes.where((note) => note.isPinned).length;

          // All pinned notes should come first
          for (int i = 0; i < pinnedCount; i++) {
            expect(
              sortedNotes[i].isPinned,
              isTrue,
              reason: 'Note at index $i should be pinned',
            );
          }

          // All unpinned notes should come after
          for (int i = pinnedCount; i < sortedNotes.length; i++) {
            expect(
              sortedNotes[i].isPinned,
              isFalse,
              reason: 'Note at index $i should be unpinned',
            );
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 3.1.2: Priority ordering within pinned and unpinned sections',
        () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate notes with all priority combinations
          final notes = <Note>[];

          // Create pinned notes with different priorities
          for (final priority in NotePriority.values) {
            final count = 1 + random.nextInt(3); // 1-3 notes per priority
            for (int i = 0; i < count; i++) {
              final note = noteGenerator(
                allowLongContent: false,
                allowArchivedAndPinned: false,
                ensureValidTimestamps: true,
              ).generate(random);
              notes.add(note.copyWith(
                isPinned: true,
                priority: priority,
                isArchived: false,
              ));
            }
          }

          // Create unpinned notes with different priorities
          for (final priority in NotePriority.values) {
            final count = 1 + random.nextInt(3); // 1-3 notes per priority
            for (int i = 0; i < count; i++) {
              final note = noteGenerator(
                allowLongContent: false,
                allowArchivedAndPinned: false,
                ensureValidTimestamps: true,
              ).generate(random);
              notes.add(note.copyWith(
                isPinned: false,
                priority: priority,
                isArchived: false,
              ));
            }
          }

          // Shuffle to test sorting
          notes.shuffle(random);
          return notes;
        }),
        (List<Note> notes) {
          final sortedNotes = NoteSorting.sortByPriority(notes);

          // Separate pinned and unpinned notes
          final pinnedNotes =
              sortedNotes.where((note) => note.isPinned).toList();
          final unpinnedNotes =
              sortedNotes.where((note) => !note.isPinned).toList();

          // Verify priority ordering within pinned section
          _verifyPriorityOrderingInSection(pinnedNotes, 'pinned');

          // Verify priority ordering within unpinned section
          _verifyPriorityOrderingInSection(unpinnedNotes, 'unpinned');
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 3.1.3: Same-priority notes ordered by creation date (newest first)',
        () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate notes with same priority but different creation dates
          final priority = notePriorityGenerator().generate(random);
          final isPinned = boolGenerator().generate(random);

          final notes = <Note>[];
          final baseDate = DateTime(2026, 1, 1);

          // Create 3-8 notes with same priority but different creation dates
          final count = 3 + random.nextInt(6);
          for (int i = 0; i < count; i++) {
            final createdAt = baseDate.add(Duration(hours: i));
            final note = noteGenerator(
              allowLongContent: false,
              allowArchivedAndPinned: false,
              ensureValidTimestamps: false,
            ).generate(random);

            notes.add(note.copyWith(
              priority: priority,
              isPinned: isPinned,
              isArchived: false,
              createdAt: createdAt,
              updatedAt: createdAt.add(Duration(minutes: random.nextInt(60))),
            ));
          }

          // Shuffle to test sorting
          notes.shuffle(random);
          return notes;
        }),
        (List<Note> samePriorityNotes) {
          final sortedNotes = NoteSorting.sortByPriority(samePriorityNotes);

          // Verify all notes have the same priority and pin status
          final firstNote = sortedNotes.first;
          for (final note in sortedNotes) {
            expect(note.priority, equals(firstNote.priority));
            expect(note.isPinned, equals(firstNote.isPinned));
          }

          // Verify creation date ordering (newest first)
          for (int i = 0; i < sortedNotes.length - 1; i++) {
            final current = sortedNotes[i];
            final next = sortedNotes[i + 1];

            expect(
              current.createdAt.isAfter(next.createdAt) ||
                  current.createdAt.isAtSameMomentAs(next.createdAt),
              isTrue,
              reason:
                  'Note at index $i (created ${current.createdAt}) should be newer than or equal to note at index ${i + 1} (created ${next.createdAt})',
            );
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 3.1.4: Ordering consistency across different note operations',
        () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        noteListGenerator(
          minLength: 5,
          maxLength: 20,
          allowLongContent: false,
          allowArchivedAndPinned: false,
          ensureValidTimestamps: true,
        ),
        (List<Note> originalNotes) {
          // Test that multiple sorts produce the same result
          final sorted1 = NoteSorting.sortByPriority(originalNotes);
          final sorted2 = NoteSorting.sortByPriority(originalNotes);
          final sorted3 =
              NoteSorting.sortByPriority(List.from(originalNotes.reversed));

          // All sorts should produce identical results
          expect(sorted1.length, equals(sorted2.length));
          expect(sorted1.length, equals(sorted3.length));

          for (int i = 0; i < sorted1.length; i++) {
            expect(sorted1[i].id, equals(sorted2[i].id));
            expect(sorted1[i].id, equals(sorted3[i].id));
          }

          // Test that sorting an already sorted list doesn't change it
          final sortedAgain = NoteSorting.sortByPriority(sorted1);
          expect(sortedAgain.length, equals(sorted1.length));
          for (int i = 0; i < sorted1.length; i++) {
            expect(sortedAgain[i].id, equals(sorted1[i].id));
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 3.1.5: Edge cases - empty and single note lists',
        () {
      // **Validates: Requirements 3.1, 3.2**
      forAll(
        Generator.fromFunction((random) {
          final edgeCases = [
            // Empty list
            <Note>[],
            // Single note
            [noteGenerator().generate(random)],
          ];
          return edgeCases[random.nextInt(edgeCases.length)];
        }),
        (List<Note> edgeCaseNotes) {
          final sortedNotes = NoteSorting.sortByPriority(edgeCaseNotes);

          // Should handle edge cases gracefully
          expect(sortedNotes.length, equals(edgeCaseNotes.length));

          if (edgeCaseNotes.isNotEmpty) {
            expect(sortedNotes.first.id, equals(edgeCaseNotes.first.id));
          }

          // Should still follow ordering rules (even though trivial)
          expect(sortedNotes, hasValidPriorityOrdering());
        },
        iterations: 50,
      );
    });
  });
}

/// Helper function to verify priority ordering within a section of notes
void _verifyPriorityOrderingInSection(List<Note> notes, String sectionName) {
  for (int i = 0; i < notes.length - 1; i++) {
    final current = notes[i];
    final next = notes[i + 1];

    // Higher priority (lower index) should come first
    expect(
      current.priority.index,
      lessThanOrEqualTo(next.priority.index),
      reason:
          'In $sectionName section: note at index $i (priority ${current.priority}) should have higher or equal priority than note at index ${i + 1} (priority ${next.priority})',
    );

    // Same priority should be ordered by creation date (newer first)
    if (current.priority == next.priority) {
      expect(
        current.createdAt.isAfter(next.createdAt) ||
            current.createdAt.isAtSameMomentAs(next.createdAt),
        isTrue,
        reason:
            'In $sectionName section: same priority notes should be ordered by creation date (newer first)',
      );
    }
  }
}
