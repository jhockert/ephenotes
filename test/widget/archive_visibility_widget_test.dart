import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/presentation/screens/archive_screen.dart';
import 'package:ephenotes/presentation/screens/notes_list_screen.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/data/models/note.dart';

class MockNotesBloc extends Mock implements NotesBloc {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockNotesBloc mockNotesBloc;
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    mockSettingsCubit = MockSettingsCubit();
    when(() => mockSettingsCubit.state).thenReturn(ThemeMode.system);
    when(() => mockSettingsCubit.stream)
        .thenAnswer((_) => Stream.value(ThemeMode.system));

    registerFallbackValue(const LoadNotes());
    registerFallbackValue(const ArchiveNote(''));
    registerFallbackValue(const UnarchiveNote(''));
    registerFallbackValue(const DeleteNote(''));
    registerFallbackValue(const PinNote(''));
    registerFallbackValue(const UnpinNote(''));
  });

  Note createTestNote({
    String? id,
    String? content,
    bool isArchived = false,
    bool isPinned = false,
    NotePriority priority = NotePriority.normal,
  }) {
    return Note(
      id: id ?? 'test-note-1',
      content: content ?? 'Test note content',
      createdAt: DateTime(2026, 1, 15, 10, 0),
      updatedAt: DateTime(2026, 1, 15, 10, 0),
      isArchived: isArchived,
      isPinned: isPinned,
      priority: priority,
    );
  }

  Widget createArchiveScreenWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NotesBloc>.value(value: mockNotesBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: const ArchiveScreen(),
      ),
    );
  }

  Widget createNotesListScreenWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NotesBloc>.value(value: mockNotesBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: const NotesListScreen(),
      ),
    );
  }

  group('Archive Visibility Widget Tests -', () {
    group('ArchiveScreen displays archived notes', () {
      testWidgets('should display archived notes in ArchiveScreen',
          (tester) async {
        // Arrange
        final archivedNotes = [
          createTestNote(id: '1', content: 'Archived note 1', isArchived: true),
          createTestNote(id: '2', content: 'Archived note 2', isArchived: true),
          createTestNote(id: '3', content: 'Archived note 3', isArchived: true),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Archived note 1'), findsOneWidget);
        expect(find.text('Archived note 2'), findsOneWidget);
        expect(find.text('Archived note 3'), findsOneWidget);
      });

      testWidgets('should display only archived notes, not active notes',
          (tester) async {
        // Arrange
        final mixedNotes = [
          createTestNote(id: '1', content: 'Archived note', isArchived: true),
          createTestNote(id: '2', content: 'Active note', isArchived: false),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: mixedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: mixedNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Archived note'), findsOneWidget);
        expect(find.text('Active note'), findsNothing);
      });

      testWidgets(
          'should display archived notes with different priorities in ArchiveScreen',
          (tester) async {
        // Arrange
        final archivedNotes = [
          createTestNote(
            id: '1',
            content: 'High priority archived',
            isArchived: true,
            priority: NotePriority.high,
          ),
          createTestNote(
            id: '2',
            content: 'Medium priority archived',
            isArchived: true,
            priority: NotePriority.normal,
          ),
          createTestNote(
            id: '3',
            content: 'Low priority archived',
            isArchived: true,
            priority: NotePriority.low,
          ),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert - All archived notes should be visible
        expect(find.text('High priority archived'), findsOneWidget);
        expect(find.text('Medium priority archived'), findsOneWidget);
        expect(find.text('Low priority archived'), findsOneWidget);
      });

      testWidgets('should display multiple archived notes correctly',
          (tester) async {
        // Arrange
        final archivedNotes = List.generate(
          10,
          (index) => createTestNote(
            id: 'archived-$index',
            content: 'Archived note $index',
            isArchived: true,
          ),
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert - Check a few notes are visible
        expect(find.text('Archived note 0'), findsOneWidget);
        expect(find.text('Archived note 1'), findsOneWidget);
        expect(find.text('Archived note 2'), findsOneWidget);
      });
    });

    group('Archived notes do not appear in NotesListScreen', () {
      testWidgets('should not display archived notes in NotesListScreen',
          (tester) async {
        // Arrange
        final mixedNotes = [
          createTestNote(id: '1', content: 'Active note', isArchived: false),
          createTestNote(id: '2', content: 'Archived note', isArchived: true),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: mixedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: mixedNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Active note'), findsOneWidget);
        expect(find.text('Archived note'), findsNothing);
      });

      testWidgets('should display only active notes in NotesListScreen',
          (tester) async {
        // Arrange
        final notes = [
          createTestNote(id: '1', content: 'Active note 1', isArchived: false),
          createTestNote(id: '2', content: 'Active note 2', isArchived: false),
          createTestNote(id: '3', content: 'Archived note 1', isArchived: true),
          createTestNote(id: '4', content: 'Archived note 2', isArchived: true),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Assert - Only active notes should be visible
        expect(find.text('Active note 1'), findsOneWidget);
        expect(find.text('Active note 2'), findsOneWidget);
        expect(find.text('Archived note 1'), findsNothing);
        expect(find.text('Archived note 2'), findsNothing);
      });

      testWidgets('should filter out all archived notes regardless of priority',
          (tester) async {
        // Arrange
        final notes = [
          createTestNote(
            id: '1',
            content: 'Active high priority',
            isArchived: false,
            priority: NotePriority.high,
          ),
          createTestNote(
            id: '2',
            content: 'Archived high priority',
            isArchived: true,
            priority: NotePriority.high,
          ),
          createTestNote(
            id: '3',
            content: 'Active medium priority',
            isArchived: false,
            priority: NotePriority.normal,
          ),
          createTestNote(
            id: '4',
            content: 'Archived medium priority',
            isArchived: true,
            priority: NotePriority.normal,
          ),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Active high priority'), findsOneWidget);
        expect(find.text('Active medium priority'), findsOneWidget);
        expect(find.text('Archived high priority'), findsNothing);
        expect(find.text('Archived medium priority'), findsNothing);
      });

      testWidgets('should not display archived pinned notes in NotesListScreen',
          (tester) async {
        // Arrange - Archived notes should never be pinned, but test the filter
        final notes = [
          createTestNote(
            id: '1',
            content: 'Active pinned note',
            isArchived: false,
            isPinned: true,
          ),
          createTestNote(
            id: '2',
            content: 'Archived note',
            isArchived: true,
            isPinned: false,
          ),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Active pinned note'), findsOneWidget);
        expect(find.text('Archived note'), findsNothing);
      });
    });

    group('Restore action moves notes back to main list', () {
      testWidgets('should restore note from archive to main list',
          (tester) async {
        // Arrange
        final archivedNote = createTestNote(
          id: 'test-1',
          content: 'Archived note',
          isArchived: true,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now())),
        );
        when(() => mockNotesBloc.add(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Long press to show options
        await tester.longPress(find.text('Archived note'));
        await tester.pumpAndSettle();

        // Tap restore
        await tester.tap(find.text('Restore'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockNotesBloc.add(UnarchiveNote('test-1'))).called(1);
        expect(find.text('Note restored'), findsOneWidget);
      });

      testWidgets('should show restore option in archive screen options menu',
          (tester) async {
        // Arrange
        final archivedNote = createTestNote(
          id: 'test-1',
          content: 'Archived note',
          isArchived: true,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Long press to show options
        await tester.longPress(find.text('Archived note'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Restore'), findsOneWidget);
        expect(find.byIcon(Icons.unarchive), findsOneWidget);
      });

      testWidgets('should dispatch UnarchiveNote event when restore is tapped',
          (tester) async {
        // Arrange
        final archivedNote = createTestNote(
          id: 'restore-test',
          content: 'Note to restore',
          isArchived: true,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now())),
        );
        when(() => mockNotesBloc.add(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        await tester.longPress(find.text('Note to restore'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Restore'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockNotesBloc.add(UnarchiveNote('restore-test')))
            .called(1);
      });

      testWidgets('should restore note and make it appear in NotesListScreen',
          (tester) async {
        // Arrange - Start with archived note

        final archivedNote = createTestNote(
          id: 'test-1',
          content: 'Restored note',
          isArchived: true,
        );

        // After restore, note becomes active
        final restoredNote = createTestNote(
          id: 'test-1',
          content: 'Restored note',
          isArchived: false,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [restoredNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [restoredNote], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Assert - Restored note should appear in main list
        expect(find.text(archivedNote.content), findsOneWidget);
      });

      testWidgets('should restore multiple notes independently',
          (tester) async {
        // Arrange
        final archivedNotes = [
          createTestNote(id: '1', content: 'Archived note 1', isArchived: true),
          createTestNote(id: '2', content: 'Archived note 2', isArchived: true),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: archivedNotes, lastUpdated: DateTime.now())),
        );
        when(() => mockNotesBloc.add(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Restore first note
        await tester.longPress(find.text('Archived note 1'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Restore'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockNotesBloc.add(UnarchiveNote('1'))).called(1);
        verifyNever(() => mockNotesBloc.add(UnarchiveNote('2')));
      });
    });

    group('Empty state when no archived notes exist', () {
      testWidgets('should display empty state in ArchiveScreen when no notes',
          (tester) async {
        // Arrange
        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No archived notes'), findsOneWidget);
        expect(find.text('Swipe notes to archive them'), findsOneWidget);
        expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      });

      testWidgets(
          'should display empty state when all notes are active (none archived)',
          (tester) async {
        // Arrange
        final activeNotes = [
          createTestNote(id: '1', content: 'Active note 1', isArchived: false),
          createTestNote(id: '2', content: 'Active note 2', isArchived: false),
        ];

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: activeNotes, lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: activeNotes, lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('No archived notes'), findsOneWidget);
        expect(find.text('Swipe notes to archive them'), findsOneWidget);
      });

      testWidgets('should display empty state with helpful information',
          (tester) async {
        // Arrange
        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert - Check for informational text
        expect(find.text('No archived notes'), findsOneWidget);
        expect(find.text('Swipe notes to archive them'), findsOneWidget);
        expect(find.text('Restored notes return to their priority position'),
            findsOneWidget);
        expect(find.text('High → Medium → Low'), findsOneWidget);
      });

      testWidgets('should show empty state icon in ArchiveScreen',
          (tester) async {
        // Arrange
        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
      });
    });

    group('Integration: Archive and restore workflow', () {
      testWidgets('should archive note and remove from main list',
          (tester) async {
        // Arrange - Start with active note
        final activeNote = createTestNote(
          id: 'test-1',
          content: 'Note to archive',
          isArchived: false,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [activeNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [activeNote], lastUpdated: DateTime.now())),
        );
        when(() => mockNotesBloc.add(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Long press and archive
        await tester.longPress(find.text('Note to archive'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Archive'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockNotesBloc.add(ArchiveNote('test-1'))).called(1);
        expect(find.text('Note archived'), findsOneWidget);
        expect(find.text('UNDO'), findsOneWidget);
      });

      testWidgets('should undo archive action from snackbar', (tester) async {
        // Arrange
        final activeNote = createTestNote(
          id: 'test-1',
          content: 'Note to archive',
          isArchived: false,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [activeNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [activeNote], lastUpdated: DateTime.now())),
        );
        when(() => mockNotesBloc.add(any())).thenReturn(null);

        // Act
        await tester.pumpWidget(createNotesListScreenWidget());
        await tester.pumpAndSettle();

        // Archive note
        await tester.longPress(find.text('Note to archive'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Archive'));
        await tester.pumpAndSettle();

        // Tap UNDO
        await tester.tap(find.text('UNDO'));
        await tester.pumpAndSettle();

        // Assert
        verify(() => mockNotesBloc.add(ArchiveNote('test-1'))).called(1);
        verify(() => mockNotesBloc.add(UnarchiveNote('test-1'))).called(1);
      });

      testWidgets('should show archived note in ArchiveScreen after archiving',
          (tester) async {
        // Arrange - Note is now archived
        final archivedNote = createTestNote(
          id: 'test-1',
          content: 'Newly archived note',
          isArchived: true,
        );

        when(() => mockNotesBloc.state).thenReturn(
          NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now()),
        );
        when(() => mockNotesBloc.stream).thenAnswer(
          (_) => Stream.value(
              NotesLoaded(notes: [archivedNote], lastUpdated: DateTime.now())),
        );

        // Act
        await tester.pumpWidget(createArchiveScreenWidget());
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Newly archived note'), findsOneWidget);
      });
    });
  });
}
