import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:uuid/uuid.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_matchers.dart';

/// Property-based test for timestamp monotonicity.
///
/// **Validates: Requirements 1.1, 1.2**
///
/// This test verifies that note timestamps follow logical ordering:
/// - createdAt never changes after creation
/// - updatedAt >= createdAt always holds
/// - updatedAt advances with each update operation

void main() {
  group('Property Test: Timestamp Monotonicity', () {
    late NoteRepository repository;
    const uuid = Uuid();

    setUp(() {
      PropertyTestConfig.reset();
      // Use a fake datasource for testing
      repository = NoteRepositoryImpl(
        dataSource: _FakeNoteDataSource(),
      );
    });

    testProperty(
        'Property 4.1: createdAt remains immutable across all operations', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate a simple note with short content to avoid validation issues
          final now = DateTime.now();
          return Note(
            id: uuid.v4(),
            content: 'Test note ${random.nextInt(1000)}',
            createdAt: now,
            updatedAt: now,
            color: NoteColor.classicYellow,
            priority: NotePriority.normal,
          );
        }),
        (Note originalNote) async {
          // Create the note
          await repository.create(originalNote);

          // Perform various update operations
          final operations = [
            // Content update
            originalNote.copyWith(
              content:
                  'Updated content ${DateTime.now().millisecondsSinceEpoch}',
              updatedAt: DateTime.now().add(Duration(milliseconds: 100)),
            ),
            // Priority update
            originalNote.copyWith(
              priority: originalNote.priority == NotePriority.high
                  ? NotePriority.low
                  : NotePriority.high,
              updatedAt: DateTime.now().add(Duration(milliseconds: 200)),
            ),
            // Color update
            originalNote.copyWith(
              color: originalNote.color == NoteColor.classicYellow
                  ? NoteColor.skyBlue
                  : NoteColor.classicYellow,
              updatedAt: DateTime.now().add(Duration(milliseconds: 300)),
            ),
            // Pin/unpin operation
            originalNote.copyWith(
              isPinned: !originalNote.isPinned,
              updatedAt: DateTime.now().add(Duration(milliseconds: 400)),
            ),
          ];

          for (final updatedNote in operations) {
            await repository.update(updatedNote);

            // Retrieve the updated note from repository
            final retrievedNote = await repository.getById(originalNote.id);

            // Verify createdAt never changes
            expect(
              retrievedNote.createdAt,
              equals(originalNote.createdAt),
              reason:
                  'createdAt must remain immutable: original=${originalNote.createdAt}, retrieved=${retrievedNote.createdAt}',
            );

            // Verify the note still has valid timestamps
            expect(retrievedNote, hasValidTimestamps());
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 4.2: updatedAt progresses monotonically with updates', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        Generator.fromFunction((random) {
          final now = DateTime.now();
          return Note(
            id: uuid.v4(),
            content: 'Test note ${random.nextInt(1000)}',
            createdAt: now,
            updatedAt: now,
            color: NoteColor.classicYellow,
            priority: NotePriority.normal,
          );
        }),
        (Note originalNote) async {
          // Create the note
          await repository.create(originalNote);

          DateTime lastUpdatedAt = originalNote.updatedAt;

          // Perform a series of updates with advancing timestamps
          for (int i = 1; i <= 5; i++) {
            // Wait a small amount to ensure timestamp progression
            await Future.delayed(Duration(milliseconds: 10));

            final newUpdatedAt = DateTime.now();
            final updatedNote = originalNote.copyWith(
              content: 'Update $i: ${newUpdatedAt.millisecondsSinceEpoch}',
              updatedAt: newUpdatedAt,
            );

            await repository.update(updatedNote);
            final retrievedNote = await repository.getById(originalNote.id);

            // Verify updatedAt has progressed
            expect(
              retrievedNote.updatedAt.isAfter(lastUpdatedAt) ||
                  retrievedNote.updatedAt.isAtSameMomentAs(newUpdatedAt),
              isTrue,
              reason:
                  'updatedAt must progress: previous=$lastUpdatedAt, current=$retrievedNote.updatedAt',
            );

            // Verify updatedAt >= createdAt still holds
            expect(retrievedNote, hasValidTimestamps());

            lastUpdatedAt = retrievedNote.updatedAt;
          }
        },
        iterations: 100,
      );
    });

    testProperty('Property 4.3: updatedAt >= createdAt invariant always holds',
        () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        Generator.fromFunction((random) {
          final now = DateTime.now();
          final createdAt = DateTime.fromMillisecondsSinceEpoch(
              now.millisecondsSinceEpoch - random.nextInt(1000000));
          final updatedAt = DateTime.fromMillisecondsSinceEpoch(
              createdAt.millisecondsSinceEpoch + random.nextInt(1000000));

          return Note(
            id: uuid.v4(),
            content: 'Test note ${random.nextInt(1000)}',
            createdAt: createdAt,
            updatedAt: updatedAt,
            color: NoteColor.classicYellow,
            priority: NotePriority.normal,
          );
        }),
        (Note noteWithVariousTimestamps) async {
          // Test the invariant regardless of how the note was constructed
          if (noteWithVariousTimestamps.updatedAt
                  .isAfter(noteWithVariousTimestamps.createdAt) ||
              noteWithVariousTimestamps.updatedAt
                  .isAtSameMomentAs(noteWithVariousTimestamps.createdAt)) {
            // Valid timestamp relationship - should be accepted
            await expectLater(
              repository.create(noteWithVariousTimestamps),
              completes,
              reason: 'Note with valid timestamps should be accepted',
            );

            expect(noteWithVariousTimestamps, hasValidTimestamps());

            // Test that updates maintain the invariant
            final futureUpdate = noteWithVariousTimestamps.copyWith(
              content: 'Updated content',
              updatedAt:
                  noteWithVariousTimestamps.updatedAt.add(Duration(minutes: 1)),
            );

            await repository.update(futureUpdate);
            final retrievedNote =
                await repository.getById(noteWithVariousTimestamps.id);
            expect(retrievedNote, hasValidTimestamps());
          } else {
            // Invalid timestamp relationship - create a corrected version
            final correctedNote = noteWithVariousTimestamps.copyWith(
              updatedAt: noteWithVariousTimestamps.createdAt,
            );

            await repository.create(correctedNote);
            final retrievedNote = await repository.getById(correctedNote.id);
            expect(retrievedNote, hasValidTimestamps());
          }
        },
        iterations: 100,
      );
    });
  });
}

/// Fake datasource for testing that doesn't require Hive initialization
class _FakeNoteDataSource implements NoteLocalDataSource {
  final Map<String, Note> _notes = {};

  @override
  Future<void> createNote(Note note) async {
    if (_notes.containsKey(note.id)) {
      throw Exception('Note with id ${note.id} already exists');
    }
    _notes[note.id] = note;
  }

  @override
  Future<void> updateNote(Note note) async {
    if (!_notes.containsKey(note.id)) {
      throw Exception('Note with id ${note.id} not found');
    }
    _notes[note.id] = note;
  }

  @override
  Future<void> deleteNote(String id) async {
    if (!_notes.containsKey(id)) {
      throw Exception('Note with id $id not found');
    }
    _notes.remove(id);
  }

  @override
  Future<Note> getNoteById(String id) async {
    final note = _notes[id];
    if (note == null) {
      throw Exception('Note with id $id not found');
    }
    return note;
  }

  @override
  Future<List<Note>> getAllNotes() async {
    return _notes.values.toList();
  }

  @override
  Future<List<Note>> getActiveNotes() async {
    return _notes.values.where((note) => !note.isArchived).toList();
  }

  @override
  Future<List<Note>> getArchivedNotes() async {
    return _notes.values.where((note) => note.isArchived).toList();
  }

  @override
  Future<List<Note>> getPinnedNotes() async {
    return _notes.values
        .where((note) => note.isPinned && !note.isArchived)
        .toList();
  }
}
