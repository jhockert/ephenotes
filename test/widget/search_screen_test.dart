import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/presentation/screens/search_screen.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
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
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<NotesBloc>.value(value: mockNotesBloc),
          BlocProvider<SettingsCubit>.value(value: mockSettingsCubit),
        ],
        child: const SearchScreen(),
      ),
    );
  }

  Note createTestNote({
    String? id,
    String? content,
    IconCategory? iconCategory,
    bool isPinned = false,
    bool isArchived = false,
  }) {
    return Note(
      id: id ?? 'test-note-1',
      content: content ?? 'Test note content',
      createdAt: DateTime(2026, 1, 15, 10, 0),
      updatedAt: DateTime(2026, 1, 15, 10, 0),
      iconCategory: iconCategory,
      isPinned: isPinned,
      isArchived: isArchived,
    );
  }

  group('SearchScreen -', () {
    testWidgets('displays search bar with autofocus', (tester) async {
      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: const [], lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Find the search TextField
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Verify autofocus is enabled
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.autofocus, isTrue);
    });

    testWidgets('displays all active notes when search query is empty',
        (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Buy milk'),
        createTestNote(id: '2', content: 'Call dentist'),
        createTestNote(id: '3', content: 'Buy bread'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Call dentist'), findsOneWidget);
      expect(find.text('Buy bread'), findsOneWidget);
    });

    testWidgets('filters notes based on search query (case-insensitive)',
        (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Buy milk'),
        createTestNote(id: '2', content: 'Call dentist'),
        createTestNote(id: '3', content: 'Buy bread'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Type "buy" in search bar
      await tester.enterText(find.byType(TextField), 'buy');
      await tester.pump();

      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Buy bread'), findsOneWidget);
      expect(find.text('Call dentist'), findsNothing);
    });

    testWidgets('search is case-insensitive', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Important MEETING tomorrow'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Type lowercase "meeting"
      await tester.enterText(find.byType(TextField), 'meeting');
      await tester.pump();

      expect(find.text('Important MEETING tomorrow'), findsOneWidget);
    });

    testWidgets('searches by icon category name', (tester) async {
      final notes = [
        createTestNote(
            id: '1', content: 'Team standup', iconCategory: IconCategory.work),
        createTestNote(
            id: '2',
            content: 'Grocery list',
            iconCategory: IconCategory.personal),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Search for "work"
      await tester.enterText(find.byType(TextField), 'work');
      await tester.pump();

      expect(find.text('Team standup'), findsOneWidget);
      expect(find.text('Grocery list'), findsNothing);
    });

    testWidgets('displays pinned notes first in search results',
        (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Buy milk', isPinned: false),
        createTestNote(id: '2', content: 'Buy groceries', isPinned: true),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Search for "buy"
      await tester.enterText(find.byType(TextField), 'buy');
      await tester.pump();

      // Both should be found
      expect(find.text('Buy milk'), findsOneWidget);
      expect(find.text('Buy groceries'), findsOneWidget);

      // Find all text widgets to check order
      final textWidgets = find.byType(Text);
      final textList = textWidgets.evaluate().map((e) {
        final widget = e.widget as Text;
        return widget.data;
      }).toList();

      // Pinned note should appear before unpinned note
      final pinnedIndex = textList.indexOf('Buy groceries');
      final unpinnedIndex = textList.indexOf('Buy milk');

      expect(pinnedIndex, lessThan(unpinnedIndex));
    });

    testWidgets('excludes archived notes from search', (tester) async {
      final notes = [
        createTestNote(
            id: '1', content: 'Active note with eggs', isArchived: false),
        createTestNote(
            id: '2', content: 'Archived note with eggs', isArchived: true),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Search for "eggs"
      await tester.enterText(find.byType(TextField), 'eggs');
      await tester.pump();

      expect(find.text('Active note with eggs'), findsOneWidget);
      expect(find.text('Archived note with eggs'), findsNothing);
    });

    testWidgets('displays empty state when no results found', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Buy milk'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Search for something that doesn't exist
      await tester.enterText(find.byType(TextField), 'nonexistent query xyz');
      await tester.pump();

      expect(find.text('No notes found for "nonexistent query xyz"'),
          findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('shows clear button when query is not empty', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Test note'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Type something
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears query when clear button is tapped', (tester) async {
      final notes = [
        createTestNote(id: '1', content: 'Test note'),
      ];

      when(() => mockNotesBloc.state).thenReturn(
        NotesLoaded(notes: notes, lastUpdated: DateTime.now()),
      );
      when(() => mockNotesBloc.stream).thenAnswer(
        (_) => Stream.value(NotesLoaded(notes: notes, lastUpdated: DateTime.now())),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Type something
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // TextField should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });
}
