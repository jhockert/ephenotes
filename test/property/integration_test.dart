import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Integration test to verify the property-based testing framework
/// works correctly with the existing ephenotes codebase.

void main() {
  group('Property-Based Testing Integration', () {
    testProperty('Framework integrates with existing Note model', () {
      forAll(
        noteGenerator(),
        (Note note) {
          // Verify the generated note is valid according to existing model
          expect(note, isA<Note>());
          expect(note.id, isNotEmpty);
          expect(note.content, isA<String>());
          expect(note.createdAt, isA<DateTime>());
          expect(note.updatedAt, isA<DateTime>());
          expect(note.color, isA<NoteColor>());
          expect(note.priority, isA<NotePriority>());
          expect(note.isPinned, isA<bool>());
          expect(note.isArchived, isA<bool>());

          // Test custom matchers work with real Note objects
          expect(note, hasValidContentLength());
          expect(note, hasValidTimestamps());
          expect(note, hasValidArchivePinState());
        },
      );
    });

    testProperty('Generated notes can be copied and modified', () {
      forAll(
        noteGenerator(),
        (Note originalNote) {
          // Test copyWith functionality with generated notes
          final modifiedNote = originalNote.copyWith(
            content: 'Modified content',
            isPinned: !originalNote.isPinned,
          );

          expect(modifiedNote.id, equals(originalNote.id));
          expect(modifiedNote.content, equals('Modified content'));
          expect(modifiedNote.isPinned, equals(!originalNote.isPinned));
          expect(modifiedNote.createdAt, equals(originalNote.createdAt));

          // Verify the modified note still passes validation
          expect(modifiedNote, hasValidContentLength());
          expect(modifiedNote, hasValidTimestamps());
        },
      );
    });

    testProperty('Note equality works with generated notes', () {
      forAll(
        noteGenerator(),
        (Note note) {
          // Test that identical notes are equal
          final identicalNote = Note(
            id: note.id,
            content: note.content,
            createdAt: note.createdAt,
            updatedAt: note.updatedAt,
            color: note.color,
            priority: note.priority,
            iconCategory: note.iconCategory,
            isPinned: note.isPinned,
            isArchived: note.isArchived,
            isBold: note.isBold,
            isItalic: note.isItalic,
            isUnderlined: note.isUnderlined,
            fontSize: note.fontSize,
            listType: note.listType,
          );

          expect(note, equals(identicalNote));
          expect(note.hashCode, equals(identicalNote.hashCode));

          // Test that different notes are not equal
          final differentNote = note.copyWith(content: 'Different content');
          expect(note, isNot(equals(differentNote)));
        },
      );
    });

    test('Property test configuration works correctly', () {
      // Test that we can configure iterations
      int executionCount = 0;

      forAll(
        Generator.constant('test'),
        (String value) {
          executionCount++;
        },
        iterations: 25,
      );

      expect(executionCount, equals(25));
    });

    test('Custom matchers provide meaningful error messages', () {
      final invalidNote = Note(
        id: 'test',
        content: 'x' * 141, // Too long
        createdAt: DateTime.now(),
        updatedAt:
            DateTime.now().subtract(Duration(hours: 1)), // Invalid timestamp
        isArchived: true,
        isPinned: true, // Invalid combination
      );

      // Test that matchers fail with descriptive messages
      expect(
        () => expect(invalidNote, hasValidContentLength()),
        throwsA(isA<TestFailure>()),
      );

      expect(
        () => expect(invalidNote, hasValidTimestamps()),
        throwsA(isA<TestFailure>()),
      );

      expect(
        () => expect(invalidNote, hasValidArchivePinState()),
        throwsA(isA<TestFailure>()),
      );
    });

    testProperty('Framework handles edge cases gracefully', () {
      // Test with empty content
      forAll(
        Generator.constant(''),
        (String emptyContent) {
          final note = Note(
            id: 'test',
            content: emptyContent,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          expect(note.content, isEmpty);
          expect(note, hasValidContentLength());
        },
      );
    });

    testProperty('List generators work with existing collection operations',
        () {
      forAll(
        noteListGenerator(minLength: 1, maxLength: 5),
        (List<Note> notes) {
          // Test that generated lists work with standard operations
          expect(notes, isA<List<Note>>());
          expect(notes.length, greaterThanOrEqualTo(1));
          expect(notes.length, lessThanOrEqualTo(5));

          // Test filtering operations
          final pinnedNotes = notes.where((n) => n.isPinned).toList();
          final archivedNotes = notes.where((n) => n.isArchived).toList();

          expect(pinnedNotes, everyElement(isPinnedNote()));
          expect(archivedNotes, everyElement(isArchivedNote()));

          // Test that we can sort the generated notes
          final sortedNotes = List<Note>.from(notes)
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          expect(sortedNotes.length, equals(notes.length));
        },
      );
    });
  });
}
