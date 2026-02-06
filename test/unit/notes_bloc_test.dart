import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';

// Mock repository
class MockNoteRepository extends Mock implements NoteRepository {}

// Fake Note for fallback value
class FakeNote extends Fake implements Note {}

void main() {
  late NotesBloc bloc;
  late MockNoteRepository mockRepository;

  // Test data
  final testNote1 = Note(
    id: 'test-1',
    content: 'Buy groceries',
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    color: NoteColor.classicYellow,
    priority: NotePriority.high,
  );

  final testNote2 = Note(
    id: 'test-2',
    content: 'Finish project',
    createdAt: DateTime(2026, 1, 2),
    updatedAt: DateTime(2026, 1, 2),
    color: NoteColor.skyBlue,
    priority: NotePriority.normal,
    isPinned: true,
  );

  final testNote3 = Note(
    id: 'test-3',
    content: 'Archived note',
    createdAt: DateTime(2026, 1, 3),
    updatedAt: DateTime(2026, 1, 3),
    color: NoteColor.mintGreen,
    priority: NotePriority.low,
    isArchived: true,
  );

  final testNotes = [testNote1, testNote2];

  setUpAll(() {
    registerFallbackValue(FakeNote());
  });

  setUp(() {
    mockRepository = MockNoteRepository();
    bloc = NotesBloc(repository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  group('NotesBloc', () {
    test('initial state is NotesInitial', () {
      expect(bloc.state, equals(const NotesInitial()));
    });

    group('LoadNotes', () {
      blocTest<NotesBloc, NotesState>(
        'emits [NotesLoading, NotesLoaded] when loading succeeds',
        build: () {
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => testNotes);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadNotes()),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', testNotes)
              .having((s) => s.searchQuery, 'searchQuery', null)
              .having((s) => s.showingArchived, 'showingArchived', false),
        ],
        verify: (_) {
          verify(() => mockRepository.getActive()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emits [NotesLoading, NotesError] when loading fails',
        build: () {
          when(() => mockRepository.getActive())
              .thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadNotes()),
        expect: () => [
          const NotesLoading(),
          isA<NotesError>()
              .having((s) => s.type, 'type', NotesErrorType.storage)
              .having((s) => s.message, 'message', contains('Failed to load')),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'loads active notes by default',
        build: () {
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => testNotes);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadNotes()),
        verify: (_) {
          verify(() => mockRepository.getActive()).called(1);
          verifyNever(() => mockRepository.getArchived());
        },
      );
    });

    group('RefreshNotes', () {
      blocTest<NotesBloc, NotesState>(
        'emits [NotesLoading, NotesLoaded] when refresh succeeds',
        build: () {
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => testNotes);
          return bloc;
        },
        act: (bloc) => bloc.add(const RefreshNotes()),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>().having((s) => s.notes, 'notes', testNotes),
        ],
      );
    });

    group('CreateNote', () {
      blocTest<NotesBloc, NotesState>(
        'creates note and reloads list',
        build: () {
          when(() => mockRepository.create(testNote1)).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote1]);
          return bloc;
        },
        act: (bloc) => bloc.add(CreateNote(testNote1)),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', contains(testNote1)),
        ],
        verify: (_) {
          verify(() => mockRepository.create(testNote1)).called(1);
          verify(() => mockRepository.getActive()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emits error when creation fails due to validation',
        build: () {
          when(() => mockRepository.create(any()))
              .thenThrow(Exception('Note content exceeds 140 character limit'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateNote(testNote1)),
        expect: () => [
          isA<NotesError>()
              .having((s) => s.type, 'type', NotesErrorType.validation)
              .having((s) => s.message, 'message', contains('140 character')),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'emits error when creation fails due to storage',
        build: () {
          when(() => mockRepository.create(any()))
              .thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateNote(testNote1)),
        expect: () => [
          isA<NotesError>()
              .having((s) => s.type, 'type', NotesErrorType.storage)
              .having(
                  (s) => s.message, 'message', contains('Failed to create')),
        ],
      );
    });

    group('UpdateNote', () {
      blocTest<NotesBloc, NotesState>(
        'updates note and reloads list',
        build: () {
          when(() => mockRepository.update(testNote1)).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote1]);
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateNote(testNote1)),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.update(testNote1)).called(1);
          verify(() => mockRepository.getActive()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emits error when update fails',
        build: () {
          when(() => mockRepository.update(any()))
              .thenThrow(Exception('Note not found'));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateNote(testNote1)),
        expect: () => [
          isA<NotesError>().having(
              (s) => s.message, 'message', contains('Failed to update')),
        ],
      );
    });

    group('DeleteNote', () {
      blocTest<NotesBloc, NotesState>(
        'deletes note and reloads list',
        build: () {
          when(() => mockRepository.delete('test-1')).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteNote('test-1')),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes.length, 'notes length', 1)
              .having((s) => s.notes, 'notes', isNot(contains(testNote1))),
        ],
        verify: (_) {
          verify(() => mockRepository.delete('test-1')).called(1);
          verify(() => mockRepository.getActive()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emits error when delete fails',
        build: () {
          when(() => mockRepository.delete(any()))
              .thenThrow(Exception('Note not found'));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteNote('test-1')),
        expect: () => [
          isA<NotesError>().having(
              (s) => s.message, 'message', contains('Failed to delete')),
        ],
      );
    });

    group('ArchiveNote', () {
      blocTest<NotesBloc, NotesState>(
        'archives note by updating isArchived to true',
        build: () {
          when(() => mockRepository.getById('test-1'))
              .thenAnswer((_) async => testNote1);
          when(() => mockRepository.update(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const ArchiveNote('test-1')),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>(),
        ],
        verify: (_) {
          verify(() => mockRepository.getById('test-1')).called(1);
          verify(() => mockRepository.update(any())).called(1);
          verify(() => mockRepository.getActive()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'removes pin status when archiving pinned note',
        build: () {
          when(() => mockRepository.getById('test-2'))
              .thenAnswer((_) async => testNote2);
          when(() => mockRepository.update(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActive()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(const ArchiveNote('test-2')),
        verify: (_) {
          // Verify the note was updated with isArchived=true and isPinned=false
          final captured = verify(() => mockRepository.update(captureAny()))
              .captured
              .single as Note;
          expect(captured.isArchived, true);
          expect(captured.isPinned, false);
        },
      );
    });

    group('UnarchiveNote', () {
      blocTest<NotesBloc, NotesState>(
        'unarchives note by updating isArchived to false',
        build: () {
          when(() => mockRepository.getById('test-3'))
              .thenAnswer((_) async => testNote3);
          when(() => mockRepository.update(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote1, testNote2, testNote3]);
          return bloc;
        },
        act: (bloc) => bloc.add(const UnarchiveNote('test-3')),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>(),
        ],
        verify: (_) {
          final captured = verify(() => mockRepository.update(captureAny()))
              .captured
              .single as Note;
          expect(captured.isArchived, false);
        },
      );
    });

    group('PinNote', () {
      blocTest<NotesBloc, NotesState>(
        'pins note by updating isPinned to true',
        build: () {
          when(() => mockRepository.getById('test-1'))
              .thenAnswer((_) async => testNote1);
          when(() => mockRepository.update(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote1, testNote2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const PinNote('test-1')),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>(),
        ],
        verify: (_) {
          final captured = verify(() => mockRepository.update(captureAny()))
              .captured
              .single as Note;
          expect(captured.isPinned, true);
        },
      );
    });

    group('UnpinNote', () {
      blocTest<NotesBloc, NotesState>(
        'unpins note by updating isPinned to false',
        build: () {
          when(() => mockRepository.getById('test-2'))
              .thenAnswer((_) async => testNote2);
          when(() => mockRepository.update(any())).thenAnswer((_) async {});
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => [testNote1, testNote2]);
          return bloc;
        },
        act: (bloc) => bloc.add(const UnpinNote('test-2')),
        verify: (_) {
          final captured = verify(() => mockRepository.update(captureAny()))
              .captured
              .single as Note;
          expect(captured.isPinned, false);
        },
      );
    });

    group('SearchNotes', () {
      blocTest<NotesBloc, NotesState>(
        'filters notes by search query (case-insensitive)',
        seed: () => NotesLoaded(notes: testNotes, lastUpdated: DateTime.now()),
        build: () => bloc,
        act: (bloc) => bloc.add(const SearchNotes('project')),
        expect: () => [
          isA<NotesLoaded>()
              .having((s) => s.notes.length, 'notes length', 1)
              .having((s) => s.notes.first.content, 'content', 'Finish project')
              .having((s) => s.searchQuery, 'searchQuery', 'project'),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'returns empty list when no matches found',
        seed: () => NotesLoaded(notes: testNotes, lastUpdated: DateTime.now()),
        build: () => bloc,
        act: (bloc) => bloc.add(const SearchNotes('nonexistent')),
        expect: () => [
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', isEmpty)
              .having((s) => s.searchQuery, 'searchQuery', 'nonexistent'),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'handles empty search query',
        seed: () => NotesLoaded(notes: testNotes, lastUpdated: DateTime.now()),
        build: () => bloc,
        act: (bloc) => bloc.add(const SearchNotes('')),
        expect: () => [
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', testNotes)
              .having((s) => s.searchQuery, 'searchQuery', ''),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'requires NotesLoaded state to search',
        build: () => bloc,
        act: (bloc) => bloc.add(const SearchNotes('test')),
        expect: () => [],
      );
    });

    group('ClearSearch', () {
      blocTest<NotesBloc, NotesState>(
        'clears search query and shows all notes',
        seed: () => NotesLoaded(
          notes: [testNote2],
          searchQuery: 'project',
          lastUpdated: DateTime.now(),
        ),
        build: () {
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => testNotes);
          return bloc;
        },
        act: (bloc) => bloc.add(const ClearSearch()),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', testNotes)
              .having((s) => s.searchQuery, 'searchQuery', null),
        ],
      );
    });

    group('ToggleArchiveView', () {
      blocTest<NotesBloc, NotesState>(
        'loads archived notes when toggled to true',
        build: () {
          when(() => mockRepository.getArchived())
              .thenAnswer((_) async => [testNote3]);
          return bloc;
        },
        act: (bloc) => bloc.add(const ToggleArchiveView(true)),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', [testNote3]).having(
                  (s) => s.showingArchived, 'showingArchived', true),
        ],
        verify: (_) {
          verify(() => mockRepository.getArchived()).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'loads active notes when toggled to false',
        build: () {
          when(() => mockRepository.getActive())
              .thenAnswer((_) async => testNotes);
          return bloc;
        },
        act: (bloc) => bloc.add(const ToggleArchiveView(false)),
        expect: () => [
          const NotesLoading(),
          isA<NotesLoaded>()
              .having((s) => s.notes, 'notes', testNotes)
              .having((s) => s.showingArchived, 'showingArchived', false),
        ],
        verify: (_) {
          verify(() => mockRepository.getActive()).called(1);
        },
      );
    });
  });
}
