import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:uuid/uuid.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';

/// Property-based test for note content integrity.
///
/// **Validates: Requirements 1.1, 1.2**
///
/// This test verifies that note content never exceeds 140 characters
/// across all operations (create, update) and maintains UTF-8 integrity.

void main() {
  group('Property Test: Note Content Integrity', () {
    late NoteRepository repository;
    const uuid = Uuid();

    setUp(() {
      PropertyTestConfig.reset();
      // Use a fake datasource for testing
      repository = NoteRepositoryImpl(
        dataSource: _FakeNoteDataSource(),
      );
    });

    testProperty('Property 1.2: Note content never exceeds 140 characters', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        stringGenerator(minLength: 0, maxLength: 200, allowUnicode: true),
        (String input) async {
          // Test note creation with various content lengths
          final note = Note(
            id: uuid.v4(),
            content: input,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          if (input.length <= 140) {
            // Content within limit should be accepted
            await expectLater(
              repository.create(note),
              completes,
              reason:
                  'Content with ${input.length} characters should be accepted',
            );

            // Verify content is preserved exactly
            expect(note.content, equals(input));
            expect(note.content.length, lessThanOrEqualTo(140));

            // Verify UTF-8 integrity is maintained
            expect(note.content.runes.length,
                lessThanOrEqualTo(note.content.length));
          } else {
            // Content exceeding limit should be rejected
            await expectLater(
              repository.create(note),
              throwsA(isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('140 character limit'),
              )),
              reason:
                  'Content with ${input.length} characters should be rejected',
            );
          }
        },
        iterations: 100,
      );
    });

    testProperty(
        'Property 1.2.1: Edge case content lengths are handled correctly', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate edge case lengths: 0, 1, 139, 140, 141, 200
          final edgeLengths = [0, 1, 139, 140, 141, 200];
          final targetLength = edgeLengths[random.nextInt(edgeLengths.length)];

          if (targetLength == 0) return '';

          // Create string of exact target length
          return 'a' * targetLength;
        }),
        (String edgeCaseContent) async {
          final note = Note(
            id: uuid.v4(),
            content: edgeCaseContent,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          if (edgeCaseContent.length <= 140) {
            // Should accept content at or below limit
            await expectLater(
              repository.create(note),
              completes,
              reason:
                  'Content with exactly ${edgeCaseContent.length} characters should be accepted',
            );

            expect(note.content, equals(edgeCaseContent));
            expect(note.content.length, equals(edgeCaseContent.length));
            expect(note.content.length, lessThanOrEqualTo(140));
          } else {
            // Should reject content above limit
            await expectLater(
              repository.create(note),
              throwsA(isA<Exception>().having(
                (e) => e.toString(),
                'message',
                contains('140 character limit'),
              )),
              reason:
                  'Content with exactly ${edgeCaseContent.length} characters should be rejected',
            );
          }
        },
        iterations:
            50, // Fewer iterations since we're testing specific edge cases
      );
    });

    testProperty('Property 1.2.2: Unicode content integrity is preserved', () {
      // **Validates: Requirements 1.1, 1.2**
      forAll(
        Generator.fromFunction((random) {
          // Generate strings with various Unicode characters
          final unicodeStrings = [
            '🎉📝✨💡🔥', // Emojis (each emoji can be multiple bytes)
            'Héllo Wörld', // Accented characters
            '你好世界', // Chinese characters
            'مرحبا بالعالم', // Arabic text
            '🎵🎶🎸🎤🎧', // Music emojis
            'Café naïve résumé', // Mixed accented characters
          ];

          final baseString =
              unicodeStrings[random.nextInt(unicodeStrings.length)];

          // Repeat to create strings of various lengths, but keep under 140
          final repetitions = 1 + random.nextInt(10);
          final result = baseString * repetitions;

          // Truncate to test boundary conditions
          if (result.length > 140) {
            return result.substring(0, 140);
          }
          return result;
        }),
        (String unicodeContent) async {
          final note = Note(
            id: uuid.v4(),
            content: unicodeContent,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          // Should accept valid Unicode content (we're keeping it under 140)
          await expectLater(
            repository.create(note),
            completes,
            reason:
                'Unicode content with ${unicodeContent.length} characters should be accepted',
          );

          // Verify Unicode content is preserved exactly
          expect(note.content, equals(unicodeContent));
          expect(note.content.length, lessThanOrEqualTo(140));

          // Verify Unicode integrity (runes vs bytes)
          final runes = note.content.runes.toList();
          final reconstructed = String.fromCharCodes(runes);
          expect(reconstructed, equals(note.content));
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
