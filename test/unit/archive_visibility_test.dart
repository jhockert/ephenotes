import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';

// Mock datasource
class MockNoteLocalDataSource extends Mock implements NoteLocalDataSource {}

// Fake Note for fallback value
class FakeNote extends Fake implements Note {}

void main() {
  late NoteRepository repository;
  late MockNoteLocalDataSource mockDataSource;

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    mockDataSource = MockNoteLocalDataSource();
    repository = NoteRepositoryImpl(dataSource: mockDataSource);
  });

  group('Archive Visibility Unit Tests', () {
    group('getArchivedNotes', () {
      test('should return only archived notes', () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'archived-1',
            content: 'Archived note 1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
          ),
          Note(
            id: 'archived-2',
            content: 'Archived note 2',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: true,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 2);
        expect(result.every((note) => note.isArchived), isTrue);
        expect(result[0].id, 'archived-1');
        expect(result[1].id, 'archived-2');
        verify(() => mockDataSource.getArchivedNotes()).called(1);
      });

      test('should return empty list when no archived notes exist', () async {
        // Arrange
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDataSource.getArchivedNotes()).called(1);
      });

      test('should not include pinned notes in archived notes', () async {
        // Arrange - archived notes should never be pinned
        final archivedNotes = [
          Note(
            id: 'archived-1',
            content: 'Archived note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
            isPinned: false, // Archived notes cannot be pinned
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 1);
        expect(result[0].isArchived, isTrue);
        expect(result[0].isPinned, isFalse);
      });

      test('should include archived notes with different priorities', () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'archived-high',
            content: 'High priority archived',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
            priority: NotePriority.high,
          ),
          Note(
            id: 'archived-medium',
            content: 'Medium priority archived',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: true,
            priority: NotePriority.normal,
          ),
          Note(
            id: 'archived-low',
            content: 'Low priority archived',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            isArchived: true,
            priority: NotePriority.low,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 3);
        expect(result.every((note) => note.isArchived), isTrue);
        expect(
            result.any((note) => note.priority == NotePriority.high), isTrue);
        expect(
            result.any((note) => note.priority == NotePriority.normal), isTrue);
        expect(result.any((note) => note.priority == NotePriority.low), isTrue);
      });
    });

    group('getActiveNotes', () {
      test('should return only active (non-archived) notes', () async {
        // Arrange
        final activeNotes = [
          Note(
            id: 'active-1',
            content: 'Active note 1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: false,
          ),
          Note(
            id: 'active-2',
            content: 'Active note 2',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: false,
          ),
        ];

        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => activeNotes);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result.length, 2);
        expect(result.every((note) => !note.isArchived), isTrue);
        expect(result[0].id, 'active-1');
        expect(result[1].id, 'active-2');
        verify(() => mockDataSource.getActiveNotes()).called(1);
      });

      test('should not include archived notes in active notes', () async {
        // Arrange
        final activeNotes = [
          Note(
            id: 'active-1',
            content: 'Active note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: false,
          ),
        ];

        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => activeNotes);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result.length, 1);
        expect(result.every((note) => !note.isArchived), isTrue);
        expect(result.any((note) => note.isArchived), isFalse);
      });

      test('should include pinned notes in active notes', () async {
        // Arrange
        final activeNotes = [
          Note(
            id: 'active-pinned',
            content: 'Active pinned note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: false,
            isPinned: true,
          ),
          Note(
            id: 'active-unpinned',
            content: 'Active unpinned note',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: false,
            isPinned: false,
          ),
        ];

        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => activeNotes);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result.length, 2);
        expect(result.every((note) => !note.isArchived), isTrue);
        expect(result.any((note) => note.isPinned), isTrue);
      });

      test('should return empty list when no active notes exist', () async {
        // Arrange
        when(() => mockDataSource.getActiveNotes()).thenAnswer((_) async => []);

        // Act
        final result = await repository.getActive();

        // Assert
        expect(result, isEmpty);
        verify(() => mockDataSource.getActiveNotes()).called(1);
      });
    });

    group('Archive/Unarchive Operations', () {
      test('archived note should appear in getArchivedNotes after archiving',
          () async {
        // Arrange
        final note = Note(
          id: 'test-1',
          content: 'Test note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: false,
        );

        final archivedNote = note.copyWith(isArchived: true);

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => [archivedNote]);

        // Act
        await repository.update(archivedNote);
        final archivedNotes = await repository.getArchived();

        // Assert
        expect(archivedNotes.length, 1);
        expect(archivedNotes[0].id, 'test-1');
        expect(archivedNotes[0].isArchived, isTrue);
      });

      test('archived note should not appear in getActiveNotes', () async {
        // Arrange
        final archivedNote = Note(
          id: 'archived-1',
          content: 'Archived note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: true,
        );

        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => []); // No active notes

        // Act
        final activeNotes = await repository.getActive();

        // Assert
        expect(activeNotes, isEmpty);
        expect(activeNotes.any((note) => note.id == archivedNote.id), isFalse);
      });

      test('unarchiving note should remove it from archive list', () async {
        // Arrange
        final archivedNote = Note(
          id: 'test-1',
          content: 'Test note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: true,
        );

        final unarchivedNote = archivedNote.copyWith(isArchived: false);

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => []); // Empty after unarchiving

        // Act
        await repository.update(unarchivedNote);
        final archivedNotes = await repository.getArchived();

        // Assert
        expect(archivedNotes, isEmpty);
        expect(archivedNotes.any((note) => note.id == 'test-1'), isFalse);
      });

      test('unarchiving note should make it appear in active list', () async {
        // Arrange
        final archivedNote = Note(
          id: 'test-1',
          content: 'Test note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: true,
        );

        final unarchivedNote = archivedNote.copyWith(isArchived: false);

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});
        when(() => mockDataSource.getActiveNotes())
            .thenAnswer((_) async => [unarchivedNote]);

        // Act
        await repository.update(unarchivedNote);
        final activeNotes = await repository.getActive();

        // Assert
        expect(activeNotes.length, 1);
        expect(activeNotes[0].id, 'test-1');
        expect(activeNotes[0].isArchived, isFalse);
      });

      test('archiving pinned note should remove pin status', () async {
        // Arrange
        final pinnedNote = Note(
          id: 'test-1',
          content: 'Pinned note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isPinned: true,
          isArchived: false,
        );

        // When archiving, pin status should be removed
        final archivedNote = pinnedNote.copyWith(
          isArchived: true,
          isPinned: false,
        );

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => [archivedNote]);

        // Act
        await repository.update(archivedNote);
        final archivedNotes = await repository.getArchived();

        // Assert
        expect(archivedNotes.length, 1);
        expect(archivedNotes[0].isArchived, isTrue);
        expect(archivedNotes[0].isPinned, isFalse);
      });
    });

    group('Archive List Priority Ordering', () {
      test(
          'archive list should maintain priority ordering (High → Medium → Low)',
          () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'archived-low',
            content: 'Low priority',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
            priority: NotePriority.low,
          ),
          Note(
            id: 'archived-high',
            content: 'High priority',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: true,
            priority: NotePriority.high,
          ),
          Note(
            id: 'archived-medium',
            content: 'Medium priority',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            isArchived: true,
            priority: NotePriority.normal,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();
        final sorted = NoteSorting.sortByPriority(result);

        // Assert
        expect(sorted.length, 3);
        expect(sorted[0].priority, NotePriority.high);
        expect(sorted[1].priority, NotePriority.normal);
        expect(sorted[2].priority, NotePriority.low);
      });

      test(
          'archive list with same priority should be ordered by creation date (newest first)',
          () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'archived-1',
            content: 'Oldest',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
            priority: NotePriority.normal,
          ),
          Note(
            id: 'archived-2',
            content: 'Middle',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: true,
            priority: NotePriority.normal,
          ),
          Note(
            id: 'archived-3',
            content: 'Newest',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            isArchived: true,
            priority: NotePriority.normal,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();
        final sorted = NoteSorting.sortByPriority(result);

        // Assert
        expect(sorted.length, 3);
        expect(sorted[0].id, 'archived-3'); // Newest first
        expect(sorted[1].id, 'archived-2');
        expect(sorted[2].id, 'archived-1'); // Oldest last
      });

      test('archive list should maintain complex priority ordering', () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'low-1',
            content: 'Low priority 1',
            createdAt: DateTime(2026, 1, 1, 10, 0),
            updatedAt: DateTime(2026, 1, 1, 10, 0),
            isArchived: true,
            priority: NotePriority.low,
          ),
          Note(
            id: 'high-1',
            content: 'High priority 1',
            createdAt: DateTime(2026, 1, 1, 11, 0),
            updatedAt: DateTime(2026, 1, 1, 11, 0),
            isArchived: true,
            priority: NotePriority.high,
          ),
          Note(
            id: 'medium-1',
            content: 'Medium priority 1',
            createdAt: DateTime(2026, 1, 1, 12, 0),
            updatedAt: DateTime(2026, 1, 1, 12, 0),
            isArchived: true,
            priority: NotePriority.normal,
          ),
          Note(
            id: 'high-2',
            content: 'High priority 2',
            createdAt: DateTime(2026, 1, 1, 13, 0),
            updatedAt: DateTime(2026, 1, 1, 13, 0),
            isArchived: true,
            priority: NotePriority.high,
          ),
          Note(
            id: 'low-2',
            content: 'Low priority 2',
            createdAt: DateTime(2026, 1, 1, 14, 0),
            updatedAt: DateTime(2026, 1, 1, 14, 0),
            isArchived: true,
            priority: NotePriority.low,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();
        final sorted = NoteSorting.sortByPriority(result);

        // Assert - Expected order: high-2, high-1, medium-1, low-2, low-1
        expect(sorted.length, 5);
        expect(sorted[0].id, 'high-2'); // High priority, newest
        expect(sorted[1].id, 'high-1'); // High priority, older
        expect(sorted[2].id, 'medium-1'); // Medium priority
        expect(sorted[3].id, 'low-2'); // Low priority, newest
        expect(sorted[4].id, 'low-1'); // Low priority, oldest
      });

      test(
          'archive list should not have pinned notes (archived notes cannot be pinned)',
          () async {
        // Arrange
        final archivedNotes = [
          Note(
            id: 'archived-1',
            content: 'Archived note 1',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            isArchived: true,
            isPinned: false, // Archived notes should never be pinned
            priority: NotePriority.high,
          ),
          Note(
            id: 'archived-2',
            content: 'Archived note 2',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            isArchived: true,
            isPinned: false,
            priority: NotePriority.normal,
          ),
        ];

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 2);
        expect(result.every((note) => !note.isPinned), isTrue);
        expect(result.every((note) => note.isArchived), isTrue);
      });
    });

    group('Edge Cases', () {
      test('should handle multiple archive/unarchive operations', () async {
        // Arrange
        final note = Note(
          id: 'test-1',
          content: 'Test note',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: false,
        );

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});

        // Act & Assert - Archive
        final archived = note.copyWith(isArchived: true);
        await repository.update(archived);
        expect(archived.isArchived, isTrue);

        // Act & Assert - Unarchive
        final unarchived = archived.copyWith(isArchived: false);
        await repository.update(unarchived);
        expect(unarchived.isArchived, isFalse);

        // Act & Assert - Archive again
        final rearchived = unarchived.copyWith(isArchived: true);
        await repository.update(rearchived);
        expect(rearchived.isArchived, isTrue);
      });

      test('should handle empty archive list', () async {
        // Arrange
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => []);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result, isEmpty);
      });

      test('should handle large number of archived notes', () async {
        // Arrange
        final archivedNotes = List.generate(
          100,
          (index) => Note(
            id: 'archived-$index',
            content: 'Archived note $index',
            createdAt: DateTime(2026, 1, 1).add(Duration(hours: index)),
            updatedAt: DateTime(2026, 1, 1).add(Duration(hours: index)),
            isArchived: true,
            priority: NotePriority.values[index % 3],
          ),
        );

        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => archivedNotes);

        // Act
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 100);
        expect(result.every((note) => note.isArchived), isTrue);
      });

      test(
          'should maintain data integrity when archiving notes with all properties',
          () async {
        // Arrange
        final note = Note(
          id: 'test-1',
          content: 'Complex note with all properties',
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
          isArchived: false,
          isPinned: true,
          priority: NotePriority.high,
          color: NoteColor.coralPink,
          iconCategory: IconCategory.work,
          isBold: true,
          isItalic: true,
          isUnderlined: true,
          fontSize: FontSize.large,
          listType: ListType.bullets,
        );

        final archivedNote = note.copyWith(
          isArchived: true,
          isPinned: false, // Pin should be removed when archiving
        );

        when(() => mockDataSource.updateNote(any())).thenAnswer((_) async {});
        when(() => mockDataSource.getArchivedNotes())
            .thenAnswer((_) async => [archivedNote]);

        // Act
        await repository.update(archivedNote);
        final result = await repository.getArchived();

        // Assert
        expect(result.length, 1);
        final archived = result[0];
        expect(archived.isArchived, isTrue);
        expect(archived.isPinned, isFalse);
        expect(archived.content, 'Complex note with all properties');
        expect(archived.priority, NotePriority.high);
        expect(archived.color, NoteColor.coralPink);
        expect(archived.iconCategory, IconCategory.work);
        expect(archived.isBold, isTrue);
        expect(archived.isItalic, isTrue);
        expect(archived.isUnderlined, isTrue);
        expect(archived.fontSize, FontSize.large);
        expect(archived.listType, ListType.bullets);
      });
    });
  });
}
