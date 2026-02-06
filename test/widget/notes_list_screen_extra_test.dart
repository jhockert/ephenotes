import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/presentation/screens/notes_list_screen.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import 'package:ephenotes/presentation/screens/archive_screen.dart';
import 'package:ephenotes/presentation/widgets/note_card.dart';
import 'package:ephenotes/data/models/note.dart';

Note createNote(String id, String content, DateTime createdAt, bool isPinned,
    bool isArchived) {
  return Note(
    id: id,
    content: content,
    createdAt: createdAt,
    updatedAt: createdAt,
    isPinned: isPinned,
    isArchived: isArchived,
  );
}

class MockNotesBloc extends Mock implements NotesBloc {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

void main() {
  late MockNotesBloc mockNotesBloc;
  late MockSettingsCubit mockSettingsCubit;

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    mockSettingsCubit = MockSettingsCubit();

    when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes: const [], lastUpdated: DateTime.now()));
    when(() => mockNotesBloc.stream)
        .thenAnswer((_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())));

    when(() => mockSettingsCubit.state).thenReturn(ThemeMode.system);
    when(() => mockSettingsCubit.stream)
        .thenAnswer((_) => Stream.value(ThemeMode.system));
    when(() => mockSettingsCubit.cycleThemeMode()).thenReturn(null);
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

  testWidgets('theme toggle button calls cycleThemeMode on SettingsCubit',
      (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final themeButton = find.byIcon(Icons.brightness_auto);
    expect(themeButton, findsOneWidget);

    await tester.tap(themeButton);
    await tester.pumpAndSettle();

    verify(() => mockSettingsCubit.cycleThemeMode()).called(1);
  });

  testWidgets('FAB navigates to NoteEditorScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditorScreen), findsOneWidget);
  });

  testWidgets('Archive button navigates to ArchiveScreen', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(ArchiveScreen), findsOneWidget);
  });

  testWidgets('flat list shows pinned notes before unpinned', (tester) async {
    when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes: [
      // pinned first
      // pinned note
      createNote('p1', 'Pinned', DateTime(2026, 1, 3), true, false),
      // unpinned note
      createNote('u1', 'Unpinned', DateTime(2026, 1, 2), false, false),
      createNote('u2', 'Unpinned2', DateTime(2026, 1, 1), false, false),
    ], lastUpdated: DateTime.now()));
    when(() => mockNotesBloc.stream)
        .thenAnswer((_) => Stream.value(NotesLoaded(notes: [
              createNote('p1', 'Pinned', DateTime(2026, 1, 3), true, false),
              createNote('u1', 'Unpinned', DateTime(2026, 1, 2), false, false),
              createNote('u2', 'Unpinned2', DateTime(2026, 1, 1), false, false),
            ], lastUpdated: DateTime.now())));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Pinned note should appear before unpinned
    final pinnedFinder = find.text('Pinned');
    final unpinnedFinder = find.text('Unpinned');
    expect(pinnedFinder, findsOneWidget);
    expect(unpinnedFinder, findsOneWidget);

    // Ensure pinned is found earlier in the list by checking widget order
    final pinnedIndex = tester.getTopLeft(pinnedFinder).dy;
    final unpinnedIndex = tester.getTopLeft(unpinnedFinder).dy;
    expect(pinnedIndex, lessThan(unpinnedIndex));
  });

  testWidgets('many unpinned notes display a flat list (no grouping)',
      (tester) async {
    // Create 11 unpinned active notes with varying dates
    final now = DateTime.now();
    final notes = List.generate(11, (i) {
      return createNote(
          '$i', 'Note $i', now.subtract(Duration(days: i)), false, false);
    });

    when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes: notes, lastUpdated: DateTime.now()));
    when(() => mockNotesBloc.stream)
        .thenAnswer((_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())));

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // The list is lazily built; ensure at least the newest note is visible and note cards render
    expect(find.text('Note 0'), findsOneWidget);
    expect(find.byType(NoteCard), findsAtLeastNWidgets(1));
  });
}
