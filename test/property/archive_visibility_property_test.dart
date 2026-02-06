import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';

/// Property-based tests for archive visibility consistency.
///
/// **Validates: Requirements 1.3**
///
/// This test suite validates Property 7 from the design document:
/// Archive Visibility Consistency - Archived notes must always be visible
/// in the archive list and maintain proper ordering.

void main() {
  group('Property Test: Archive Visibility Consistency', () {
    setUp(() {
      PropertyTestConfig.reset();
    });

    testProperty(
      'Property 7: Archived notes always appear in archive list',
      () {
        // **Validates: Requirements 1.3**
        forAll(
          noteListGenerator(
            minLength: 5,
            maxLength: 50,
            allowLongContent: false,
            ensureValidTimestamps: true,
          ),
          (List<Note> notes) async {
            // Create a fresh in-memory repository for each test iteration
            final repository = InMemoryNoteRepository();

            // Ensure all generated notes start as non-archived
            final activeNotes = notes.map((note) => note.copyWith(
              isArchived: false,
            )).toList();

            // Create all notes
            for (final note in activeNotes) {
              await repository.create(note);
            }

            // Archive some notes (approximately half)
            final notesToArchive = activeNotes.take(activeNotes.length ~/ 2).toList();
            for (final note in notesToArchive) {
              final archivedNote = note.copyWith(
                isArchived: true,
                isPinned: false, // Archived notes cannot be pinned
              );
              await repository.update(archivedNote);
            }

            // Get archived notes from repository
            final archivedNotes = await repository.getArchived();

            // Property 1: All archived notes appear in archive list
            expect(
              archivedNotes.length,
              equals(notesToArchive.length),
              reason: 'Archive list must contain all archived notes',
            );

            // Property 2: All notes in archive list are archived
            for (final archivedNote in archivedNotes) {
              expect(
                archivedNote.isArchived,
                isTrue,
                reason: 'All notes in archive list must have isArchived=true',
              );
            }

            // Property 3: All archived notes are in the archive list
            for (final originalNote in notesToArchive) {
              final foundInArchive = archivedNotes.any(
                (n) => n.id == originalNote.id,
              );
              expect(
                foundInArchive,
                isTrue,
                reason:
                    'Archived note ${originalNote.id} must appear in archive list',
              );
            }

            // Property 4: Archive list maintains priority ordering
            // Verify notes are ordered by priority (High -> Medium -> Low)
            for (int i = 0; i < archivedNotes.length - 1; i++) {
              final current = archivedNotes[i];
              final next = archivedNotes[i + 1];

              // Priority ordering: High (0) -> Medium (1) -> Low (2)
              expect(
                current.priority.index,
                lessThanOrEqualTo(next.priority.index),
                reason:
                    'Archive list must maintain priority ordering (High -> Medium -> Low)',
              );

              // Within same priority, verify creation date ordering (newest first)
              if (current.priority == next.priority) {
                expect(
                  current.createdAt.isAfter(next.createdAt) ||
                      current.createdAt.isAtSameMomentAs(next.createdAt),
                  isTrue,
                  reason:
                      'Notes with same priority must be ordered by creation date (newest first)',
                );
              }
            }

            // Property 5: Archived notes are not pinned
            for (final archivedNote in archivedNotes) {
              expect(
                archivedNote.isPinned,
                isFalse,
                reason: 'Archived notes cannot be pinned',
              );
            }

            // Property 6: Unarchiving removes notes from archive list
            if (notesToArchive.isNotEmpty) {
              final noteToUnarchive = notesToArchive.first;
              final unarchivedNote = noteToUnarchive.copyWith(
                isArchived: false,
              );
              await repository.update(unarchivedNote);

              final updatedArchivedNotes = await repository.getArchived();

              expect(
                updatedArchivedNotes.length,
                equals(notesToArchive.length - 1),
                reason: 'Unarchiving should remove note from archive list',
              );

              expect(
                updatedArchivedNotes.any((n) => n.id == noteToUnarchive.id),
                isFalse,
                reason: 'Unarchived note should not appear in archive list',
              );
            }
          },
          iterations: 100,
        );
      },
    );

    testProperty(
      'Property 7.1: Archive list consistency across multiple operations',
      () {
        // **Validates: Requirements 1.3**
        forAll(
          noteListGenerator(
            minLength: 10,
            maxLength: 30,
            allowLongContent: false,
            ensureValidTimestamps: true,
          ),
          (List<Note> notes) async {
            // Create a fresh in-memory repository for each test iteration
            final repository = InMemoryNoteRepository();

            // Ensure all generated notes start as non-archived
            final activeNotes = notes.map((note) => note.copyWith(
              isArchived: false,
            )).toList();

            // Create all notes
            for (final note in activeNotes) {
              await repository.create(note);
            }

            // Perform multiple archive/unarchive operations
            final operations = activeNotes.length ~/ 3;
            for (int i = 0; i < operations; i++) {
              final note = activeNotes[i];

              // Archive the note
              final archivedNote = note.copyWith(
                isArchived: true,
                isPinned: false,
              );
              await repository.update(archivedNote);

              // Verify it appears in archive list
              var archivedNotes = await repository.getArchived();
              expect(
                archivedNotes.any((n) => n.id == note.id),
                isTrue,
                reason: 'Note should appear in archive list after archiving',
              );

              // Unarchive the note
              final unarchivedNote = archivedNote.copyWith(
                isArchived: false,
              );
              await repository.update(unarchivedNote);

              // Verify it's removed from archive list
              archivedNotes = await repository.getArchived();
              expect(
                archivedNotes.any((n) => n.id == note.id),
                isFalse,
                reason:
                    'Note should not appear in archive list after unarchiving',
              );
            }

            // Final consistency check
            final finalArchivedNotes = await repository.getArchived();
            final allNotes = await repository.getAll();

            // Count archived notes in all notes
            final archivedCount =
                allNotes.where((n) => n.isArchived).length;

            expect(
              finalArchivedNotes.length,
              equals(archivedCount),
              reason:
                  'Archive list count must match archived notes count in database',
            );
          },
          iterations: 50,
        );
      },
    );

    testProperty(
      'Property 7.2: Archive list maintains ordering with random priorities',
      () {
        // **Validates: Requirements 1.3**
        forAll2(
          noteListGenerator(
            minLength: 10,
            maxLength: 40,
            allowLongContent: false,
            ensureValidTimestamps: true,
          ),
          Generator.fromFunction((random) => random.nextDouble()),
          (List<Note> notes, double archiveRatio) async {
            // Create a fresh in-memory repository for each test iteration
            final repository = InMemoryNoteRepository();

            // Ensure all generated notes start as non-archived
            final activeNotes = notes.map((note) => note.copyWith(
              isArchived: false,
            )).toList();

            // Create all notes
            for (final note in activeNotes) {
              await repository.create(note);
            }

            // Archive a random portion of notes
            final archiveCount = (activeNotes.length * archiveRatio).round();
            for (int i = 0; i < archiveCount && i < activeNotes.length; i++) {
              final note = activeNotes[i];
              final archivedNote = note.copyWith(
                isArchived: true,
                isPinned: false,
              );
              await repository.update(archivedNote);
            }

            // Get archived notes
            final archivedNotes = await repository.getArchived();

            // Verify priority ordering is maintained
            if (archivedNotes.length > 1) {
              for (int i = 0; i < archivedNotes.length - 1; i++) {
                final current = archivedNotes[i];
                final next = archivedNotes[i + 1];

                // Verify priority ordering
                expect(
                  current.priority.index,
                  lessThanOrEqualTo(next.priority.index),
                  reason:
                      'Archive list must maintain priority ordering regardless of archive order',
                );

                // Within same priority, verify creation date ordering
                if (current.priority == next.priority) {
                  expect(
                    current.createdAt.isAfter(next.createdAt) ||
                        current.createdAt.isAtSameMomentAs(next.createdAt),
                    isTrue,
                    reason:
                        'Same priority notes must be ordered by creation date',
                  );
                }
              }
            }
          },
          iterations: 100,
        );
      },
    );
  });
}

/// In-memory implementation of NoteRepository for property testing.
///
/// This implementation provides a simple in-memory storage for notes
/// without requiring ObjectBox or other external dependencies.
class InMemoryNoteRepository implements NoteRepository {
  final Map<String, Note> _notes = {};

  @override
  Future<List<Note>> getAll() async {
    return _notes.values.toList();
  }

  @override
  Future<Note> getById(String id) async {
    final note = _notes[id];
    if (note == null) {
      throw Exception('Note not found: $id');
    }
    return note;
  }

  @override
  Future<void> create(Note note) async {
    if (_notes.containsKey(note.id)) {
      throw Exception('Note already exists: ${note.id}');
    }
    _notes[note.id] = note;
  }

  @override
  Future<void> update(Note note) async {
    if (!_notes.containsKey(note.id)) {
      throw Exception('Note not found: ${note.id}');
    }
    _notes[note.id] = note;
  }

  @override
  Future<void> delete(String id) async {
    if (!_notes.containsKey(id)) {
      throw Exception('Note not found: $id');
    }
    _notes.remove(id);
  }

  @override
  Future<List<Note>> getActive() async {
    final activeNotes = _notes.values.where((note) => !note.isArchived).toList();
    return _sortNotesByPriority(activeNotes);
  }

  @override
  Future<List<Note>> getArchived() async {
    final archivedNotes = _notes.values.where((note) => note.isArchived).toList();
    return _sortNotesByPriority(archivedNotes);
  }

  @override
  Future<List<Note>> getPinned() async {
    final pinnedNotes = _notes.values
        .where((note) => note.isPinned && !note.isArchived)
        .toList();
    return _sortNotesByPriority(pinnedNotes);
  }

  /// Sort notes by priority (High -> Medium -> Low) and then by creation date (newest first)
  List<Note> _sortNotesByPriority(List<Note> notes) {
    final sorted = List<Note>.from(notes);
    sorted.sort((a, b) {
      // First, sort by priority (High=0, Medium=1, Low=2)
      final priorityComparison = a.priority.index.compareTo(b.priority.index);
      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // If same priority, sort by creation date (newest first)
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }
}
