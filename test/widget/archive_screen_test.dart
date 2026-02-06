import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/presentation/screens/archive_screen.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';

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

    registerFallbackValue(const UnarchiveNote(''));
    registerFallbackValue(const DeleteNote(''));
  });

  Widget createWidgetUnderTest() {
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

  Note createTestNote({
    String? id,
    String? content,
    bool isArchived = true,
  }) {
    return Note(
      id: id ?? 'test-note-1',
      content: content ?? 'Archived note',
      createdAt: DateTime(2026, 1, 15, 10, 0),
      updatedAt: DateTime(2026, 1, 15, 10, 0),
      isArchived: isArchived,
    );
  }

  group('ArchiveScreen -', () {
    testWidgets('displays app bar with title and back button', (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Archive'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays empty state when no archived notes exist',
        (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No archived notes'), findsOneWidget);
      expect(find.text('Swipe notes to archive them'), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('displays list of archived notes', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Archived note 1'),
        createTestNote(id: '2', content: 'Archived note 2'),
        createTestNote(id: '3', content: 'Archived note 3'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Archived note 1'), findsOneWidget);
      expect(find.text('Archived note 2'), findsOneWidget);
      expect(find.text('Archived note 3'), findsOneWidget);
    });

    testWidgets('filters out active notes from archive list', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Archived note', isArchived: true),
        createTestNote(id: '2', content: 'Active note', isArchived: false),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Archived note'), findsOneWidget);
      expect(find.text('Active note'), findsNothing);
    });

    testWidgets('shows options menu when note is long-pressed', (tester) async {
      final note = createTestNote();

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press on the note
      await tester.longPress(find.text('Archived note'));
      await tester.pumpAndSettle();

      // Bottom sheet should appear with options
      expect(find.text('Restore'), findsOneWidget);
      expect(find.text('Delete permanently'), findsOneWidget);
      expect(find.byIcon(Icons.unarchive), findsOneWidget);
      expect(find.byIcon(Icons.delete_forever), findsOneWidget);
    });

    testWidgets('restores note when restore option is tapped', (tester) async {
      final note = createTestNote();

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );
      when(() => mockNotesBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press and tap Restore
      await tester.longPress(find.text('Archived note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      // Verify UnarchiveNote event was dispatched
      verify(() => mockNotesBloc.add(UnarchiveNote(note.id))).called(1);

      // Should show snackbar
      expect(find.text('Note restored'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when delete is tapped',
        (tester) async {
      final note = createTestNote();

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press and tap Delete permanently
      await tester.longPress(find.text('Archived note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();

      // Confirmation dialog should appear
      expect(find.text('Delete Note?'), findsOneWidget);
      expect(
          find.text(
              'This note will be permanently deleted. This action cannot be undone.'),
          findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deletes note when delete is confirmed', (tester) async {
      final note = createTestNote();

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );
      when(() => mockNotesBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press, tap Delete permanently, then confirm
      await tester.longPress(find.text('Archived note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify DeleteNote event was dispatched
      verify(() => mockNotesBloc.add(DeleteNote(note.id))).called(1);

      // Should show snackbar
      expect(find.text('Note deleted permanently'), findsOneWidget);
    });

    testWidgets('cancels delete when cancel is tapped', (tester) async {
      final note = createTestNote();

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );
      when(() => mockNotesBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press, tap Delete permanently, then cancel
      await tester.longPress(find.text('Archived note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete permanently'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify DeleteNote event was NOT dispatched
      verifyNever(() => mockNotesBloc.add(DeleteNote(note.id)));

      // Dialog should be closed
      expect(find.text('Delete Note?'), findsNothing);
    });
  });
}
