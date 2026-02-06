import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';

// Mock datasource
class MockNoteLocalDataSource extends Mock implements NoteLocalDataSource {}

// Fake Note for fallback value
class FakeNote extends Fake implements Note {}

void main() {
  late NoteRepository repository;
  late MockNoteLocalDataSource mockDataSource;

  // Test data
  final testNote = Note(
    id: 'test-1',
    content: 'Test note',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final testNotes = [
    testNote,
    Note(
      id: 'test-2',
      content: 'Another note',
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
    ),
  ];

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    mockDataSource = MockNoteLocalDataSource();
    repository = NoteRepositoryImpl(dataSource: mockDataSource);
  });

  group('NoteRepository', () {
    group('getAll', () {
      test('should return notes from datasource', () async {
        // Arrange
        when(() => mockDataSource.getAllNotes())
            .thenAnswer((_) async => testNotes);

        // Act
        final result = await repository.getAll();

        // Assert
        expect(result, equals(testNotes));
        verify(() => mockDataSource.getAllNotes()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getAllNotes())
            .thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => repository.getAll(),
          throwsException,
        );
      });
    });

    group('getById', () {
      test('should return note from datasource', () async {
        // Arrange
        when(() => mockDataSource.getNoteById('test-1'))
            .thenAnswer((_) async => testNote);

        // Act
        final result = await repository.getById('test-1');

        // Assert
        expect(result, equals(testNote));
        verify(() => mockDataSource.getNoteById('test-1')).called(1);
      });

      test('should throw exception when note not found', () async {
        // Arrange
        when(() => mockDataSource.getNoteById(any()))
            .thenThrow(Exception('Note not found'));

        // Act & Assert
        expect(
          () => repository.getById('non-existent'),
          throwsException,
        );
      });
    });

    group('create', () {
      test('should create note in datasource', () async {
        // Arrange
        when(() => mockDataSource.createNote(testNote))
            .thenAnswer((_) async {});

        // Act
        await repository.create(testNote);

        // Assert
        verify(() => mockDataSource.createNote(testNote)).called(1);
      });

      test('should throw exception when content exceeds 140 characters',
          () async {
        // Arrange
        final longNote = testNote.copyWith(
          content: 'a' * 141, // 141 characters
        );

        // Act & Assert
        expect(
          () => repository.create(longNote),
          throwsException,
        );
        verifyNever(() => mockDataSource.createNote(any()));
      });

      test('should accept note with exactly 140 characters', () async {
        // Arrange
        final maxLengthNote = testNote.copyWith(
          content: 'a' * 140, // exactly 140 characters
        );
        when(() => mockDataSource.createNote(maxLengthNote))
            .thenAnswer((_) async {});

        // Act
        await repository.create(maxLengthNote);

        // Assert
        verify(() => mockDataSource.createNote(maxLengthNote)).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.createNote(any()))
            .thenThrow(Exception('Create failed'));

        // Act & Assert
        expect(
          () => repository.create(testNote),
          throwsException,
        );
      });
    });

    group('update', () {
      test('should update note in datasource', () async {
        // Arrange
        when(() => mockDataSource.updateNote(testNote))
            .thenAnswer((_) async {});

        // Act
        await repository.update(testNote);

        // Assert
        verify(() => mockDataSource.updateNote(testNote)).called(1);
      });

      test('should throw exception when content exceeds 140 characters',
          () async {
        // Arrange
        final longNote = testNote.copyWith(
          content: 'a' * 141,
        );

        // Act & Assert
        expect(
          () => repository.update(longNote),
          throwsException,
        );
        verifyNever(() => mockDataSource.updateNote(any()));
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.updateNote(any()))
            .thenThrow(Exception('Update failed'));

        // Act & Assert
        expect(
          () => repository.update(testNote),
          throwsException,
        );
      });
    });

    group('delete', () {
      test('should delete note from datasource', () async {
        // Arrange
        when(() => mockDataSource.deleteNote('test-1'))
            .thenAnswer((_) async {});

        // Act
        await repository.delete('test-1');

        // Assert
        verify(() => mockDataSource.deleteNote('test-1')).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.deleteNote(any()))
            .thenThrow(Exception('Delete failed'));

        // Act & Assert
        expect(
          () => repository.delete('test-1'),
          throwsException,
        );
      });
    });

    group('getActive', () {
      test('should return active notes from datasource', () async {
        // Arrange
        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => testNotes);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, equals(testNotes));
        verify(() => mockDataSource.getActiveNotes()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getActiveNotes())
            .thenThrow(Exception('Failed'));

        // Act & Assert
        expect(
          () => repository.getActive(),
          throwsException,
        );
      });
    });

    group('getArchived', () {
      test('should return archived notes from datasource', () async {
        // Arrange
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => testNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result, equals(testNotes));
        verify(() => mockDataSource.getArchivedNotes()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getArchivedNotes())
            .thenThrow(Exception('Failed'));

        // Act & Assert
        expect(
          () => repository.getArchived(),
          throwsException,
        );
      });
    });

    group('getPinned', () {
      test('should return pinned notes from datasource', () async {
        // Arrange
        when(() => mockDataSource.getPinnedNotes())
            .thenAnswer((_) async => testNotes);

        // Act
        final result = await repository.getPinned();

        // Assert
        expect(result, equals(testNotes));
        verify(() => mockDataSource.getPinnedNotes()).called(1);
      });

      test('should throw exception when datasource fails', () async {
        // Arrange
        when(() => mockDataSource.getPinnedNotes())
            .thenThrow(Exception('Failed'));

        // Act & Assert
        expect(
          () => repository.getPinned(),
          throwsException,
        );
      });
    });
  });
}
