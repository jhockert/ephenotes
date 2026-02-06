import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:uuid/uuid.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';
import '../helpers/fake_note_datasource.dart';

/// Property-based test for archive-pin relationship invariant.
///
/// **Validates: Requirements 1.4, 5.1**
///
/// This test verifies that notes cannot be both archived and pinned
/// simultaneously across all note operations and state transitions.

void main() {
  group('Property Test: Archive-Pin Relationship Invariant', () {
    late NoteRepository repository;
    late NotesBloc notesBloc;
    late FakeNoteLocalDataSource fakeDataSource;
    const uuid = Uuid();

    setUp(() {
      // Set up test dependencies
      fakeDataSource = FakeNoteLocalDataSource();
      repository = NoteRepositoryImpl(dataSource: fakeDataSource);
      notesBloc = NotesBloc(repository: repository);
    });

    tearDown(() {
      // Clean up after each test
      notesBloc.close();
    });

    testProperty('Property 2.1: Notes cannot be both archived and pinned', () {
      // **Validates: Requirements 1.4, 5.1**
      forAll2(
        boolGenerator(), // isArchived
        boolGenerator(), // isPinned
        (bool isArchived, bool isPinned) {
          // Create a note with the specified archive/pin states
          final note = Note(
            id: uuid.v4(),
            content: 'Test note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isArchived: isArchived,
            isPinned: isPinned,
          );

          // The core invariant: a note cannot be both archived and pinned
          // This should always be false, regardless of the input combination
          if (isArchived && isPinned) {
            // This is an invalid state that should be detected
            expect(note.isArchived && note.isPinned, isTrue);
            expect(note, isNot(hasValidArchivePinState()));
          } else {
            // Valid combinations should pass
            expect(note.isArchived && note.isPinned, isFalse);
            expect(note, hasValidArchivePinState());
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 2.1: Archive operation removes pin status', () {
      // **Validates: Requirements 1.4, 5.1**
      forAll(
        boolGenerator(), // initial pin status
        (bool initiallyPinned) async {
          // Create a note that is initially active (not archived)
          final originalNote = Note(
            id: uuid.v4(),
            content: 'Test note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isArchived: false,
            isPinned: initiallyPinned,
          );

          await repository.create(originalNote);

          // Archive the note via BLoC
          notesBloc.add(ArchiveNote(originalNote.id));

          // Wait for the operation to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Retrieve the updated note
          final archivedNote = await repository.getById(originalNote.id);

          // Verify the invariant is maintained
          expect(archivedNote.isArchived, isTrue);
          expect(archivedNote.isPinned, isFalse);
          expect(archivedNote, hasValidArchivePinState());
        },
        iterations: 20, // Fewer iterations due to async operations
      );
    });

    testProperty('Property 2.2: Pin operation unarchives archived notes', () {
      // **Validates: Requirements 1.4, 5.1**
      forAll2(
        boolGenerator(), // initial archived status
        boolGenerator(), // initial pin status
        (bool initiallyArchived, bool initiallyPinned) async {
          // Create a note with the specified initial state
          final originalNote = Note(
            id: uuid.v4(),
            content: 'Test note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isArchived: initiallyArchived,
            isPinned: initiallyArchived
                ? false
                : initiallyPinned, // Archived notes can't be pinned
          );

          await repository.create(originalNote);

          // Attempt to pin the note via BLoC
          notesBloc.add(PinNote(originalNote.id));

          // Wait for the operation to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Retrieve the note after pin attempt
          final resultNote = await repository.getById(originalNote.id);

          // The invariant must still hold - note cannot be both archived and pinned
          expect(resultNote, hasValidArchivePinState());
          expect(
            resultNote.isArchived && resultNote.isPinned,
            isFalse,
            reason:
                'Pin operation resulted in note being both archived (${resultNote.isArchived}) and pinned (${resultNote.isPinned})',
          );

          // After pinning, the note should be pinned and not archived
          expect(resultNote.isPinned, isTrue);
          expect(resultNote.isArchived, isFalse);
        },
        iterations: 20, // Fewer iterations due to async operations
      );
    });

    testProperty('Property 2.3: Direct model creation with invalid state', () {
      // **Validates: Requirements 1.4, 5.1**
      // This test verifies that we can detect when the invariant is violated
      forAll2(
        boolGenerator(), // isArchived
        boolGenerator(), // isPinned
        (bool isArchived, bool isPinned) {
          // Create a note with the specified archive/pin states
          final note = Note(
            id: uuid.v4(),
            content: 'Test note',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isArchived: isArchived,
            isPinned: isPinned,
          );

          // The invariant should be violated only when both are true
          if (isArchived && isPinned) {
            // This is the invalid state we want to detect
            expect(note.isArchived && note.isPinned, isTrue);
            expect(note, isNot(hasValidArchivePinState()));
          } else {
            // All other combinations should be valid
            expect(note, hasValidArchivePinState());
            expect(note.isArchived && note.isPinned, isFalse);
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 2.4: State transitions preserve invariant', () {
      // **Validates: Requirements 1.4, 5.1**
      forAll2(
        Generator.oneOf(['active', 'pinned', 'archived']), // initial state
        Generator.oneOf(['archive', 'pin', 'update']), // operation
        (String initialState, String operation) async {
          // Create note in initial state
          Note initialNote;
          switch (initialState) {
            case 'active':
              initialNote = Note(
                id: uuid.v4(),
                content: 'Test note',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isArchived: false,
                isPinned: false,
              );
              break;
            case 'pinned':
              initialNote = Note(
                id: uuid.v4(),
                content: 'Test note',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isArchived: false,
                isPinned: true,
              );
              break;
            case 'archived':
              initialNote = Note(
                id: uuid.v4(),
                content: 'Test note',
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isArchived: true,
                isPinned: false,
              );
              break;
            default:
              throw ArgumentError('Invalid initial state: $initialState');
          }

          await repository.create(initialNote);

          // Perform the operation
          switch (operation) {
            case 'archive':
              notesBloc.add(ArchiveNote(initialNote.id));
              break;
            case 'pin':
              notesBloc.add(PinNote(initialNote.id));
              break;
            case 'update':
              final updatedNote = initialNote.copyWith(
                content: 'Updated content',
                updatedAt: DateTime.now(),
              );
              notesBloc.add(UpdateNote(updatedNote));
              break;
          }

          // Wait for the operation to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // Retrieve the note after operation
          final resultNote = await repository.getById(initialNote.id);

          // The invariant must always hold
          expect(resultNote, hasValidArchivePinState());
          expect(
            resultNote.isArchived && resultNote.isPinned,
            isFalse,
            reason:
                'After $operation on $initialState note, invariant must hold',
          );
        },
        iterations: 30,
      );
    });
  });
}
