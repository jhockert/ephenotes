import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/fake_note_datasource.dart';

/// Property-based test for data persistence integrity.
///
/// **Validates: Requirements NFR-4.1, NFR-4.2**
///
/// This test verifies that all note operations are persistent and recoverable:
/// - Save/load cycles preserve data exactly
/// - Data integrity is maintained across all operations
/// - CRUD operations work correctly
///
/// Note: These tests use FakeNoteLocalDataSource for unit testing.
/// ObjectBox-specific persistence is tested in integration tests.

void main() {
  group('Property Test: Data Persistence Integrity', () {
    const uuid = Uuid();

    // Helper function to create a fresh test environment for each property test
    NoteRepository createTestRepository() {
      final dataSource = FakeNoteLocalDataSource();
      return NoteRepositoryImpl(dataSource: dataSource);
    }

    setUp(() async {
      PropertyTestConfig.reset();
    });

    // Helper function to create valid notes with content <= 140 characters
    Note createValidNote({String? content}) {
      final noteContent =
          content ?? 'Test note ${DateTime.now().millisecondsSinceEpoch}';
      // Ensure content is <= 140 characters
      final validContent = noteContent.length > 140
          ? noteContent.substring(0, 140)
          : noteContent;

      return Note(
        id: uuid.v4(),
        content: validContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.normal,
      );
    }

    testProperty('Property 6.1: Save/load cycles preserve data exactly', () {
      // **Validates: Requirements NFR-4.1, NFR-4.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate a list of valid notes with content <= 140 characters
          final count = 1 + random.nextInt(20); // 1-20 notes
          return List.generate(
              count,
              (i) => createValidNote(
                  content: 'Note $i content ${random.nextInt(1000)}'));
        }),
        (List<Note> originalNotes) async {
          // Create fresh test repository for this iteration
          final repository = createTestRepository();

          // Save all notes to repository
          for (final note in originalNotes) {
            await repository.create(note);
          }

          // Load all notes from repository
          final loadedNotes = await repository.getAll();

          // Verify all notes were persisted correctly
          expect(loadedNotes.length, equals(originalNotes.length),
              reason: 'All notes should be persisted');

          // Verify each note was preserved exactly
          for (final originalNote in originalNotes) {
            final loadedNote = loadedNotes.firstWhere(
              (n) => n.id == originalNote.id,
              orElse: () => throw Exception(
                  'Note ${originalNote.id} not found after save/load'),
            );

            // Verify all fields are preserved exactly
            expect(loadedNote.id, equals(originalNote.id));
            expect(loadedNote.content, equals(originalNote.content));
            expect(loadedNote.createdAt, equals(originalNote.createdAt));
            expect(loadedNote.updatedAt, equals(originalNote.updatedAt));
            expect(loadedNote.color, equals(originalNote.color));
            expect(loadedNote.priority, equals(originalNote.priority));
            expect(loadedNote.iconCategory, equals(originalNote.iconCategory));
            expect(loadedNote.isPinned, equals(originalNote.isPinned));
            expect(loadedNote.isArchived, equals(originalNote.isArchived));
            expect(loadedNote.isBold, equals(originalNote.isBold));
            expect(loadedNote.isItalic, equals(originalNote.isItalic));
            expect(loadedNote.isUnderlined, equals(originalNote.isUnderlined));
            expect(loadedNote.fontSize, equals(originalNote.fontSize));
            expect(loadedNote.listType, equals(originalNote.listType));

            // Verify complete object equality
            expect(loadedNote, equals(originalNote));
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 6.2: CRUD operations maintain data consistency', () {
      // **Validates: Requirements NFR-4.1, NFR-4.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate a list of valid notes
          final count = 5 + random.nextInt(15); // 5-20 notes
          return List.generate(
              count,
              (i) => createValidNote(
                  content: 'CRUD test note $i ${random.nextInt(1000)}'));
        }),
        (List<Note> notes) async {
          // Create fresh test repository for this iteration
          final repository = createTestRepository();

          // Track expected state
          final expectedNotes = <String, Note>{};

          // Create all notes
          for (final note in notes) {
            await repository.create(note);
            expectedNotes[note.id] = note;
          }

          // Verify create operations
          var loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(expectedNotes.length));
          for (final note in loadedNotes) {
            expect(expectedNotes[note.id], equals(note));
          }

          // Update some notes
          final notesToUpdate = notes.take(notes.length ~/ 3).toList();
          for (final note in notesToUpdate) {
            final updatedNote = note.copyWith(
              content: '${note.content} (updated)',
              updatedAt: DateTime.now(),
            );
            await repository.update(updatedNote);
            expectedNotes[note.id] = updatedNote;
          }

          // Verify update operations
          loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(expectedNotes.length));
          for (final note in loadedNotes) {
            expect(expectedNotes[note.id], equals(note));
          }

          // Delete some notes
          final notesToDelete =
              notes.skip(notes.length ~/ 2).take(notes.length ~/ 4).toList();
          for (final note in notesToDelete) {
            await repository.delete(note.id);
            expectedNotes.remove(note.id);
          }

          // Verify delete operations
          loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(expectedNotes.length));
          for (final note in loadedNotes) {
            expect(expectedNotes[note.id], equals(note));
          }

          // Verify deleted notes are actually gone
          for (final deletedNote in notesToDelete) {
            expect(
              () => repository.getById(deletedNote.id),
              throwsException,
              reason: 'Deleted note should not be retrievable',
            );
          }
        },
        iterations: 50,
      );
    });

    testProperty(
        'Property 6.3: Data integrity across create/update/delete operations',
        () {
      // **Validates: Requirements NFR-4.1, NFR-4.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate notes with various properties to test data integrity
          final count = 3 + random.nextInt(10); // 3-12 notes
          return List.generate(count, (i) {
            final baseNote = noteGenerator().generate(random);
            // Ensure content is valid
            final validContent = baseNote.content.length > 140
                ? baseNote.content.substring(0, 140)
                : baseNote.content;
            return baseNote.copyWith(content: validContent);
          });
        }),
        (List<Note> notes) async {
          // Create fresh test repository for this iteration
          final repository = createTestRepository();

          // Test data integrity through various operations
          final operations = <String>[];
          final currentNotes = <String, Note>{};

          // Create notes
          for (final note in notes) {
            await repository.create(note);
            currentNotes[note.id] = note;
            operations.add('CREATE ${note.id}');
          }

          // Verify data integrity after creates
          var loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(currentNotes.length),
              reason: 'Create operations should preserve count');

          for (final note in loadedNotes) {
            expect(currentNotes.containsKey(note.id), isTrue,
                reason: 'All loaded notes should exist in expected set');
            expect(currentNotes[note.id], equals(note),
                reason: 'Loaded note should match expected note exactly');
          }

          // Perform random updates
          final notesToUpdate = notes.take(notes.length ~/ 2).toList();
          for (final note in notesToUpdate) {
            final updatedNote = note.copyWith(
              content:
                  '${note.content.substring(0, min(note.content.length, 130))} (upd)',
              updatedAt: DateTime.now(),
              // Only toggle isPinned if note is not archived
              isPinned: note.isArchived ? false : !note.isPinned,
              priority: NotePriority.values[
                  (note.priority.index + 1) % NotePriority.values.length],
            );
            await repository.update(updatedNote);
            currentNotes[note.id] = updatedNote;
            operations.add('UPDATE ${note.id}');
          }

          // Verify data integrity after updates
          loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(currentNotes.length),
              reason: 'Update operations should preserve count');

          for (final note in loadedNotes) {
            expect(currentNotes[note.id], equals(note),
                reason: 'Updated note should match expected state');
          }

          // Perform random deletes
          final notesToDelete =
              notes.skip(notes.length ~/ 2).take(notes.length ~/ 4).toList();
          for (final note in notesToDelete) {
            await repository.delete(note.id);
            currentNotes.remove(note.id);
            operations.add('DELETE ${note.id}');
          }

          // Verify data integrity after deletes
          loadedNotes = await repository.getAll();
          expect(loadedNotes.length, equals(currentNotes.length),
              reason: 'Delete operations should reduce count correctly');

          for (final note in loadedNotes) {
            expect(currentNotes.containsKey(note.id), isTrue,
                reason: 'Remaining notes should still exist');
            expect(currentNotes[note.id], equals(note),
                reason: 'Remaining notes should be unchanged');
          }

          // Verify deleted notes are gone
          for (final deletedNote in notesToDelete) {
            expect(loadedNotes.any((n) => n.id == deletedNote.id), isFalse,
                reason:
                    'Deleted note ${deletedNote.id} should not appear in results');
          }
        },
        iterations: 50,
      );
    });
  });
}
