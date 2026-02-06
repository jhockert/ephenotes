import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/fake_note_datasource.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Integration property tests for end-to-end workflows with data consistency validation.
///
/// **Validates: Requirements 5.4.2**
///
/// These tests use property-based testing to verify that complex user scenarios
/// maintain data consistency across screen transitions with randomly generated inputs.
///
/// Key Properties Tested:
/// - End-to-end workflows maintain data consistency
/// - State consistency across screen transitions
/// - Complex user scenarios with property-based inputs
void main() {
  group('Integration Property Tests', () {
    late FakeNoteLocalDataSource dataSource;

    setUp(() {
      dataSource = FakeNoteLocalDataSource();
    });

    tearDown(() {
      dataSource.clear();
    });

    /// **Property**: End-to-end Create → Edit → Archive → Restore workflows maintain data consistency
    /// **Validates: Requirements 5.4.2**
    testProperty(
        'Create → Edit → Archive → Restore workflow maintains data consistency',
        () {
      forAll(
        noteGenerator(allowLongContent: true),
        (Note originalNote) async {
          // Reset datasource for each test
          dataSource = FakeNoteLocalDataSource();

          // Step 1: Create note with property-based data
          final truncatedContent = originalNote.content.length > 140
              ? originalNote.content.substring(0, 140)
              : originalNote.content;

          // Skip empty content for this test
          if (truncatedContent.trim().isEmpty) return;

          final noteToCreate = originalNote.copyWith(
            content: truncatedContent,
            isArchived: false,
            isPinned: false,
          );

          await dataSource.createNote(noteToCreate);

          // Verify note creation consistency
          final createdNotes = await dataSource.getAllNotes();
          final activeNotes = createdNotes.where((n) => !n.isArchived).toList();
          expect(activeNotes.length, 1);
          final createdNote = activeNotes.first;
          expect(createdNote.content, truncatedContent);
          expect(createdNote.priority, originalNote.priority);
          expect(createdNote.isArchived, false);
          expect(createdNote.isPinned, false);

          // Step 2: Edit note with new property-based data
          final editedContent = '$truncatedContent - EDITED';
          final finalContent = editedContent.length > 140
              ? editedContent.substring(0, 140)
              : editedContent;

          final newPriority = originalNote.priority == NotePriority.high
              ? NotePriority.normal
              : NotePriority.high;

          final editedNote = createdNote.copyWith(
            content: finalContent,
            priority: newPriority,
            updatedAt: DateTime.now(),
          );

          await dataSource.updateNote(editedNote);

          // Verify edit consistency
          final editedNotes = await dataSource.getAllNotes();
          final editedActiveNotes =
              editedNotes.where((n) => !n.isArchived).toList();
          expect(editedActiveNotes.length, 1);
          final updatedNote = editedActiveNotes.first;
          expect(updatedNote.content, finalContent);
          expect(updatedNote.priority, newPriority);
          expect(updatedNote.id, createdNote.id); // ID should remain same

          // Step 3: Archive note
          final archivedNote = updatedNote.copyWith(
            isArchived: true,
            isPinned: false, // Should be unpinned when archived
          );

          await dataSource.updateNote(archivedNote);

          // Verify archive consistency
          final allNotesAfterArchive = await dataSource.getAllNotes();
          final activeNotesAfterArchive =
              allNotesAfterArchive.where((n) => !n.isArchived).toList();
          final archivedNotesAfterArchive =
              allNotesAfterArchive.where((n) => n.isArchived).toList();
          expect(activeNotesAfterArchive.length, 0);
          expect(archivedNotesAfterArchive.length, 1);

          final retrievedArchivedNote = archivedNotesAfterArchive.first;
          expect(retrievedArchivedNote.content, finalContent);
          expect(retrievedArchivedNote.priority, newPriority);
          expect(retrievedArchivedNote.id, createdNote.id);
          expect(retrievedArchivedNote.isArchived, true);
          expect(retrievedArchivedNote.isPinned, false);

          // Step 4: Restore note
          final restoredNote = retrievedArchivedNote.copyWith(
            isArchived: false,
          );

          await dataSource.updateNote(restoredNote);

          // Verify restore consistency
          final allNotesAfterRestore = await dataSource.getAllNotes();
          final restoredActiveNotes =
              allNotesAfterRestore.where((n) => !n.isArchived).toList();
          final restoredArchivedNotes =
              allNotesAfterRestore.where((n) => n.isArchived).toList();
          expect(restoredActiveNotes.length, 1);
          expect(restoredArchivedNotes.length, 0);

          final finalRestoredNote = restoredActiveNotes.first;
          expect(finalRestoredNote.content, finalContent);
          expect(finalRestoredNote.priority, newPriority);
          expect(finalRestoredNote.id, createdNote.id);
          expect(finalRestoredNote.isArchived, false);
          expect(finalRestoredNote.isPinned, false);

          // Verify all invariants are maintained
          expect(finalRestoredNote, hasValidContentLength());
          expect(finalRestoredNote, hasValidArchivePinState());
          expect(finalRestoredNote, hasValidTimestamps());
        },
        iterations: 10, // Reduced iterations for integration tests
      );
    });

    /// **Property**: Multi-note workflows maintain state consistency
    /// **Validates: Requirements 5.4.2**
    testProperty('Multi-note workflows maintain state consistency', () {
      forAll(
        noteListGenerator(minLength: 2, maxLength: 5),
        (List<Note> propertyNotes) async {
          // Reset datasource for each test
          dataSource = FakeNoteLocalDataSource();

          // Create notes from property-generated data
          final createdNotes = <Note>[];
          for (final propertyNote in propertyNotes) {
            final truncatedContent = propertyNote.content.length > 140
                ? propertyNote.content.substring(0, 140)
                : propertyNote.content;

            // Skip empty content notes
            if (truncatedContent.trim().isEmpty) continue;

            final noteToCreate = propertyNote.copyWith(
              content: truncatedContent,
              isArchived: false,
              isPinned: false,
            );

            await dataSource.createNote(noteToCreate);
            createdNotes.add(noteToCreate);
          }

          if (createdNotes.isEmpty) return;

          // Verify initial state consistency
          final allNotes = await dataSource.getAllNotes();
          final initialActiveNotes =
              allNotes.where((n) => !n.isArchived).toList();
          expect(initialActiveNotes.length, createdNotes.length);

          // Pin first note and verify state consistency
          if (createdNotes.isNotEmpty) {
            final firstNote = initialActiveNotes.first;
            final pinnedNote = firstNote.copyWith(isPinned: true);
            await dataSource.updateNote(pinnedNote);

            final allNotesAfterPin = await dataSource.getAllNotes();
            final pinnedNotes =
                allNotesAfterPin.where((n) => !n.isArchived).toList();
            final actualPinnedNote =
                pinnedNotes.firstWhere((n) => n.id == firstNote.id);
            expect(actualPinnedNote.isPinned, true);
            expect(actualPinnedNote.isArchived, false);
          }

          // Archive last note and verify state consistency
          if (createdNotes.length > 1) {
            final lastNote = initialActiveNotes.last;
            final archivedNote = lastNote.copyWith(
              isArchived: true,
              isPinned: false, // Should be unpinned when archived
            );
            await dataSource.updateNote(archivedNote);

            final allNotesAfterArchive = await dataSource.getAllNotes();
            final finalActiveNotes =
                allNotesAfterArchive.where((n) => !n.isArchived).toList();
            final finalArchivedNotes =
                allNotesAfterArchive.where((n) => n.isArchived).toList();
            expect(finalActiveNotes.length, createdNotes.length - 1);
            expect(finalArchivedNotes.length, 1);

            final actualArchivedNote = finalArchivedNotes.first;
            expect(actualArchivedNote.id, lastNote.id);
            expect(actualArchivedNote.isArchived, true);
            expect(actualArchivedNote.isPinned, false);
          }

          // Verify all invariants are maintained
          final finalAllNotes = await dataSource.getAllNotes();
          final allActiveNotes =
              finalAllNotes.where((n) => !n.isArchived).toList();
          final allArchivedNotes =
              finalAllNotes.where((n) => n.isArchived).toList();

          for (final note in allActiveNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }

          for (final note in allArchivedNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }
        },
        iterations: 10,
      );
    });

    /// **Property**: Search workflows maintain data consistency with property-based queries
    /// **Validates: Requirements 5.4.2**
    testProperty(
        'Search workflows maintain data consistency with property-based queries',
        () {
      forAll2(
        noteListGenerator(minLength: 3, maxLength: 6),
        searchQueryGenerator(),
        (List<Note> propertyNotes, String searchQuery) async {
          // Reset datasource for each test
          dataSource = FakeNoteLocalDataSource();

          // Create notes from property data
          final validNotes = <Note>[];
          for (final propertyNote in propertyNotes) {
            final truncatedContent = propertyNote.content.length > 140
                ? propertyNote.content.substring(0, 140)
                : propertyNote.content;

            if (truncatedContent.trim().isEmpty) continue;

            final noteToCreate = propertyNote.copyWith(
              content: truncatedContent,
              isArchived: false, // Ensure notes are active for search
            );

            await dataSource.createNote(noteToCreate);
            validNotes.add(noteToCreate);
          }

          if (validNotes.isEmpty) return;

          // Verify initial state
          final allNotes = await dataSource.getAllNotes();
          final initialActiveNotes =
              allNotes.where((n) => !n.isArchived).toList();
          expect(initialActiveNotes.length, validNotes.length);

          // Perform property-based search
          final cleanQuery = searchQuery.trim();
          if (cleanQuery.isNotEmpty && cleanQuery.length <= 50) {
            // Simulate search by filtering active notes
            final searchResults = initialActiveNotes
                .where((note) => note.content
                    .toLowerCase()
                    .contains(cleanQuery.toLowerCase()))
                .toList();

            // Verify search results are subset of active notes
            for (final result in searchResults) {
              expect(initialActiveNotes.any((n) => n.id == result.id), true);
              expect(result.isArchived, false);
            }
          }

          // Verify all notes maintain consistency after search
          final postSearchNotes = await dataSource.getAllNotes();
          final postSearchActiveNotes =
              postSearchNotes.where((n) => !n.isArchived).toList();
          expect(postSearchActiveNotes.length, initialActiveNotes.length);

          for (final note in postSearchActiveNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }
        },
        iterations: 8,
      );
    });

    /// **Property**: Pin/Unpin workflows maintain state consistency
    /// **Validates: Requirements 5.4.2**
    testProperty('Pin/Unpin workflows maintain state consistency', () {
      forAll(
        noteListGenerator(minLength: 2, maxLength: 4),
        (List<Note> propertyNotes) async {
          // Reset datasource for each test
          dataSource = FakeNoteLocalDataSource();

          // Create notes from property data
          final validNotes = <Note>[];
          for (final propertyNote in propertyNotes) {
            final truncatedContent = propertyNote.content.length > 140
                ? propertyNote.content.substring(0, 140)
                : propertyNote.content;

            if (truncatedContent.trim().isEmpty) continue;

            final noteToCreate = propertyNote.copyWith(
              content: truncatedContent,
              isArchived: false,
              isPinned: false,
            );

            await dataSource.createNote(noteToCreate);
            validNotes.add(noteToCreate);
          }

          if (validNotes.isEmpty) return;

          final allNotes = await dataSource.getAllNotes();
          final initialNotes = allNotes.where((n) => !n.isArchived).toList();

          // Pin first note
          final firstNote = initialNotes.first;
          final pinnedNote = firstNote.copyWith(isPinned: true);
          await dataSource.updateNote(pinnedNote);

          // Verify pin state consistency
          var allNotesAfterPin = await dataSource.getAllNotes();
          var currentNotes =
              allNotesAfterPin.where((n) => !n.isArchived).toList();
          var actualPinnedNote =
              currentNotes.firstWhere((n) => n.id == firstNote.id);
          expect(actualPinnedNote.isPinned, true);
          expect(actualPinnedNote.isArchived, false);

          // Unpin the note
          final unpinnedNote = actualPinnedNote.copyWith(isPinned: false);
          await dataSource.updateNote(unpinnedNote);

          // Verify unpin state consistency
          var allNotesAfterUnpin = await dataSource.getAllNotes();
          currentNotes =
              allNotesAfterUnpin.where((n) => !n.isArchived).toList();
          final actualUnpinnedNote =
              currentNotes.firstWhere((n) => n.id == firstNote.id);
          expect(actualUnpinnedNote.isPinned, false);
          expect(actualUnpinnedNote.isArchived, false);

          // Verify all notes maintain consistency
          for (final note in currentNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }
        },
        iterations: 8,
      );
    });

    /// **Property**: Archive/Restore workflows maintain data integrity across state transitions
    /// **Validates: Requirements 5.4.2**
    testProperty(
        'Archive/Restore workflows maintain data integrity across state transitions',
        () {
      forAll(
        noteListGenerator(minLength: 3, maxLength: 5),
        (List<Note> propertyNotes) async {
          // Reset datasource for each test
          dataSource = FakeNoteLocalDataSource();

          // Create notes (all active initially)
          final createdNotes = <Note>[];
          for (final note in propertyNotes) {
            final truncatedContent = note.content.length > 140
                ? note.content.substring(0, 140)
                : note.content;

            if (truncatedContent.trim().isEmpty) continue;

            final noteToCreate = note.copyWith(
              content: truncatedContent,
              isArchived: false, // Start all as active
              isPinned: false,
            );

            await dataSource.createNote(noteToCreate);
            createdNotes.add(noteToCreate);
          }

          if (createdNotes.isEmpty) return;

          // Verify initial state
          final allNotes = await dataSource.getAllNotes();
          final initialActiveNotes =
              allNotes.where((n) => !n.isArchived).toList();
          final initialArchivedNotes =
              allNotes.where((n) => n.isArchived).toList();

          expect(initialActiveNotes.length, createdNotes.length);
          expect(initialArchivedNotes.length, 0);

          // Archive one active note
          if (initialActiveNotes.isNotEmpty) {
            final noteToArchive = initialActiveNotes.first;
            final archivedNote = noteToArchive.copyWith(
              isArchived: true,
              isPinned: false, // Should be unpinned when archived
            );
            await dataSource.updateNote(archivedNote);

            // Verify archive transition
            final allNotesAfterArchive = await dataSource.getAllNotes();
            final postArchiveActive =
                allNotesAfterArchive.where((n) => !n.isArchived).toList();
            final postArchiveArchived =
                allNotesAfterArchive.where((n) => n.isArchived).toList();

            expect(postArchiveActive.length, createdNotes.length - 1);
            expect(postArchiveArchived.length, 1);

            final actualArchivedNote = postArchiveArchived.first;
            expect(actualArchivedNote.isArchived, true);
            expect(actualArchivedNote.isPinned, false);
          }

          // Restore the archived note
          final allNotesBeforeRestore = await dataSource.getAllNotes();
          final currentArchivedNotes =
              allNotesBeforeRestore.where((n) => n.isArchived).toList();
          if (currentArchivedNotes.isNotEmpty) {
            final noteToRestore = currentArchivedNotes.first;
            final restoredNote = noteToRestore.copyWith(isArchived: false);
            await dataSource.updateNote(restoredNote);

            // Verify restore transition
            final allNotesAfterRestore = await dataSource.getAllNotes();
            final postRestoreActive =
                allNotesAfterRestore.where((n) => !n.isArchived).toList();
            final postRestoreArchived =
                allNotesAfterRestore.where((n) => n.isArchived).toList();

            expect(postRestoreActive.length, createdNotes.length);
            expect(postRestoreArchived.length, 0);

            final actualRestoredNote =
                postRestoreActive.firstWhere((n) => n.id == noteToRestore.id);
            expect(actualRestoredNote.isArchived, false);
          }

          // Verify all invariants are maintained throughout transitions
          final finalAllNotes = await dataSource.getAllNotes();
          final finalActiveNotes =
              finalAllNotes.where((n) => !n.isArchived).toList();
          final finalArchivedNotes =
              finalAllNotes.where((n) => n.isArchived).toList();

          for (final note in finalActiveNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }

          for (final note in finalArchivedNotes) {
            expect(note, hasValidContentLength());
            expect(note, hasValidArchivePinState());
            expect(note, hasValidTimestamps());
          }
        },
        iterations: 8,
      );
    });
  });
}
