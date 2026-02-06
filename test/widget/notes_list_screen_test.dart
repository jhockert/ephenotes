import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
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

    // Stub settings cubit to provide a ThemeMode stream
    when(() => mockSettingsCubit.state).thenReturn(ThemeMode.system);
    when(() => mockSettingsCubit.stream)
        .thenAnswer((_) => Stream.value(ThemeMode.system));

    registerFallbackValue(const LoadNotes());
    registerFallbackValue(const ArchiveNote(''));
    registerFallbackValue(const UnarchiveNote(''));
    registerFallbackValue(const PinNote(''));
    registerFallbackValue(const UnpinNote(''));
  });

  Widget createWidgetUnderTest() {
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

  Note createTestNote({
    String? id,
    String? content,
    bool isPinned = false,
    bool isArchived = false,
  }) {
    return Note(
      id: id ?? 'test-note-1',
      content: content ?? 'Test note content',
      createdAt: DateTime(2026, 1, 15, 10, 0),
      updatedAt: DateTime(2026, 1, 15, 10, 0),
      isPinned: isPinned,
      isArchived: isArchived,
    );
  }

  group('NotesListScreen -', () {
    testWidgets('displays app bar with title and action buttons',
        (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('ephenotes'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.archive_outlined), findsOneWidget);
    });

    testWidgets('displays floating action button', (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('displays empty state when no notes exist', (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No notes yet'), findsOneWidget);
      expect(find.text('Tap + to create your first note'), findsOneWidget);
      expect(find.byIcon(Icons.note_add_outlined), findsOneWidget);
    });

    testWidgets('displays loading indicator when state is NotesLoading',
        (tester) async {
      when(() => mockNotesBloc.state).thenReturn(const NotesLoading());
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(const NotesLoading()),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is NotesError',
        (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        const NotesError(message: 'Test error message'),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(const NotesError(message: 'Test error message')),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error: Test error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays list of active notes', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Note 1'),
        createTestNote(id: '2', content: 'Note 2'),
        createTestNote(id: '3', content: 'Note 3'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Note 1'), findsOneWidget);
      expect(find.text('Note 2'), findsOneWidget);
      expect(find.text('Note 3'), findsOneWidget);
    });

    testWidgets('filters out archived notes from main list', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Active note', isArchived: false),
        createTestNote(id: '2', content: 'Archived note', isArchived: true),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Active note'), findsOneWidget);
      expect(find.text('Archived note'), findsNothing);
    });

    testWidgets('displays pinned notes before unpinned notes', (tester) async {
      final notes = [
        createTestNote(
            id: '1',
            content: 'Unpinned note',
            isPinned: false,
            isArchived: false),
        createTestNote(
            id: '2', content: 'Pinned note', isPinned: true, isArchived: false),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Find all text widgets
      final textWidgets = find.byType(Text);
      final textList = textWidgets.evaluate().map((e) {
        final widget = e.widget as Text;
        return widget.data;
      }).toList();

      // Pinned note should appear before unpinned note in the list
      final pinnedIndex = textList.indexOf('Pinned note');
      final unpinnedIndex = textList.indexOf('Unpinned note');

      expect(pinnedIndex, lessThan(unpinnedIndex));
    });

    testWidgets('shows long-press menu when note is long-pressed',
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

      // Long press on the note
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();

      // Bottom sheet should appear with options
      expect(find.text('Pin'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
    });

    testWidgets('shows unpin option for pinned notes', (tester) async {
      final note = createTestNote(isPinned: true);

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press on the note
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();

      // Should show Unpin instead of Pin
      expect(find.text('Unpin'), findsOneWidget);
      expect(find.text('Pin'), findsNothing);
    });

    testWidgets('pins note when pin option is tapped', (tester) async {
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

      // Long press and tap Pin
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();

      // Verify PinNote event was dispatched
      verify(() => mockNotesBloc.add(PinNote(note.id))).called(1);

      // Should show snackbar
      expect(find.text('Note pinned'), findsOneWidget);
    });

    testWidgets('unpins note when unpin option is tapped', (tester) async {
      final note = createTestNote(isPinned: true);

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: [note], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: [note], lastUpdated: DateTime.now())),
      );
      when(() => mockNotesBloc.add(any())).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Long press and tap Unpin
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Unpin'));
      await tester.pumpAndSettle();

      // Verify UnpinNote event was dispatched
      verify(() => mockNotesBloc.add(UnpinNote(note.id))).called(1);

      // Should show snackbar
      expect(find.text('Note unpinned'), findsOneWidget);
    });

    testWidgets('archives note when archive option is tapped', (tester) async {
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

      // Long press and tap Archive
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      // Verify ArchiveNote event was dispatched
      verify(() => mockNotesBloc.add(ArchiveNote(note.id))).called(1);

      // Should show snackbar with undo option
      expect(find.text('Note archived'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);
    });

    testWidgets('unarchives note when undo is tapped in snackbar',
        (tester) async {
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

      // Long press and tap Archive
      await tester.longPress(find.text('Test note content'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();

      // Tap UNDO button
      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      // Verify UnarchiveNote event was dispatched
      verify(() => mockNotesBloc.add(UnarchiveNote(note.id))).called(1);
    });
  });
}
