import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/presentation/screens/notes_list_screen.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import 'package:ephenotes/presentation/screens/archive_screen.dart';
import 'package:ephenotes/presentation/screens/search_screen.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/fake_note_datasource.dart';
import '../helpers/test_helpers.dart';

/// Integration tests focused on cross-screen navigation and state persistence.
///
/// Tests comprehensive navigation scenarios:
/// - Deep navigation chains with state preservation
/// - Back navigation with proper state restoration
/// - Navigation during ongoing operations
/// - State consistency across screen transitions
/// - Complex navigation patterns with multiple entry points
void main() {
  group('Navigation & State Integration Tests', () {
    late FakeNoteLocalDataSource dataSource;
    late NoteRepositoryImpl repository;
    late NotesBloc notesBloc;
    late TestSettingsCubit settingsCubit;

    setUp(() {
      dataSource = FakeNoteLocalDataSource();
      repository = NoteRepositoryImpl(dataSource: dataSource);
      notesBloc = NotesBloc(repository: repository);
      settingsCubit = TestSettingsCubit();
    });

    tearDown(() {
      notesBloc.close();
      settingsCubit.close();
    });

    /// Test deep navigation chain with state preservation
    testWidgets('Deep navigation chain preserves state at each level',
        (tester) async {
      // Pre-populate with test data
      final testNotes = TestHelpers.generateTestNotesWithCharacteristics(
        count: 10,
        forcePriority: NotePriority.normal,
      );
      for (final note in testNotes) {
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Level 1: Main screen - verify initial state
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(10));

      // Level 2: Navigate to Search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      // Perform search to establish search state
      await tester.enterText(find.byType(TextField), 'Meeting');
      await tester.pumpAndSettle();

      final searchResults = find.byType(Card);
      final searchResultCount = tester.widgetList(searchResults).length;

      // Level 3: Navigate to note editor from search results
      if (searchResultCount > 0) {
        await tester.tap(searchResults.first);
        await tester.pumpAndSettle();

        expect(find.byType(NoteEditorScreen), findsOneWidget);
        expect(find.text('Edit Note'), findsOneWidget);

        // Make a change to establish editor state
        await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField &&
              (w.decoration?.hintText ?? '') == 'Enter your note...'),
          'Modified from search navigation',
        );

        // Level 4: Navigate back to search (should preserve search query)
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(SearchScreen), findsOneWidget);
        expect(find.text('Meeting'), findsOneWidget); // Search query preserved

        // Level 3: Navigate back to main screen
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        expect(find.byType(NotesListScreen), findsOneWidget);
        expect(find.byType(Card), findsNWidgets(10)); // All notes still visible
      }

      // Level 2: Navigate to Archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ArchiveScreen), findsOneWidget);

      // Level 3: Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(10)); // All state preserved
    });

    /// Test navigation during ongoing operations
    testWidgets('Navigation during ongoing operations maintains consistency',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Test 1: Navigate away during note creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      // Start entering content
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Partial note content',
      );

      // Navigate away without saving
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text('Partial note content'), findsNothing); // Not saved

      // Test 2: Navigate during archive operation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Note to be archived',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Note to be archived'), findsOneWidget);

      // Start archive operation
      await tester.drag(
          find.text('Note to be archived'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      expect(find.text('Note archived'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      // Navigate to archive screen during undo window
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('Note to be archived'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Wait for undo window to expire
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('Note to be archived'), findsNothing); // Archived
    });

    /// Test complex navigation patterns with multiple entry points
    testWidgets('Complex navigation patterns with multiple entry points',
        (tester) async {
      // Create test data with different characteristics
      final highPriorityNote = TestHelpers.createTestNote(
        content: 'High priority note',
        priority: NotePriority.high,
        isPinned: true,
      );
      final mediumPriorityNote = TestHelpers.createTestNote(
        content: 'Normal priority note',
        priority: NotePriority.normal,
      );
      final archivedNote = TestHelpers.createTestNote(
        content: 'Archived note',
        priority: NotePriority.low,
        isArchived: true,
      );

      await repository.create(highPriorityNote);
      await repository.create(mediumPriorityNote);
      await repository.create(archivedNote);

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Pattern 1: Main → Search → Edit → Main → Archive → Main

      // Main → Search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'priority');
      await tester.pumpAndSettle();

      expect(find.text('High priority note'), findsOneWidget);
      expect(find.text('Medium priority note'), findsOneWidget);

      // Search → Edit
      await tester.tap(find.text('High priority note'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'High priority note - EDITED',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Edit → Main (automatic navigation after save)
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text('High priority note - EDITED'), findsOneWidget);

      // Main → Archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('Archived note'), findsOneWidget);

      // Archive → Main
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);

      // Pattern 2:  Main → Search → Archive (via back) → Main

      // Main → Search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      // Search → Archive (via back navigation to main, then to archive)
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ArchiveScreen), findsOneWidget);

      // Archive → Main
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);

      // Verify all state is consistent
      expect(find.text('High priority note - EDITED'), findsOneWidget);
      expect(find.text('Medium priority note'), findsOneWidget);
    });

    /// Test state consistency across rapid navigation
    testWidgets('State consistency across rapid navigation', (tester) async {
      // Create test notes
      for (int i = 0; i < 5; i++) {
        final note = TestHelpers.createTestNote(
          content: 'Rapid nav test note $i',
          priority: i % 2 == 0 ? NotePriority.high : NotePriority.low,
        );
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Perform rapid navigation sequence
      final navigationSequence = [
        () async {
          await tester.tap(find.byIcon(Icons.search));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.archive_outlined));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.settings));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.add));
          await tester.pumpAndSettle();
        },
        () async {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        },
      ];

      // Execute rapid navigation
      for (final navAction in navigationSequence) {
        await navAction();
        await tester.pump(const Duration(milliseconds: 100)); // Brief pause
      }

      // Verify final state is consistent
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));

      // Verify all notes are still accessible
      for (int i = 0; i < 5; i++) {
        expect(find.text('Rapid nav test note $i'), findsOneWidget);
      }

      // Verify functionality still works after rapid navigation
      await tester.tap(find.text('Rapid nav test note 0'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);
    });

    /// Test navigation with concurrent state changes
    testWidgets('Navigation with concurrent state changes', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Concurrent state test',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Concurrent state test'), findsOneWidget);

      // Navigate to search while triggering state changes
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Trigger concurrent state change via BLoC while on search screen
      notesBloc.add(CreateNote(TestHelpers.createTestNote(
        content: 'Note created during search',
        priority: NotePriority.high,
      )));
      await tester.pumpAndSettle();

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify both notes are present
      expect(find.text('Concurrent state test'), findsOneWidget);
      expect(find.text('Note created during search'), findsOneWidget);

      // Navigate to archive while triggering archive operation
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      // Trigger concurrent archive operation
      final notes = await repository.getActive();
      final noteToArchive = notes.first;
      notesBloc.add(ArchiveNote(noteToArchive.id));
      await tester.pumpAndSettle();

      // Verify archived note appears in archive screen
      expect(find.text(noteToArchive.content), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify archived note is no longer on main screen
      expect(find.text(noteToArchive.content), findsNothing);

      // Verify remaining note is still present
      final remainingNotes = await repository.getActive();
      expect(remainingNotes.length, 1);
      expect(find.text(remainingNotes.first.content), findsOneWidget);
    });

    /// Test navigation error recovery
    testWidgets('Navigation error recovery maintains app stability',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Error recovery test',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Error recovery test'), findsOneWidget);

      // Simulate error condition
      dataSource.shouldFailNextOperation = true;

      // Navigate to search (should handle error gracefully)
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      // Try to search (may encounter error)
      await tester.enterText(find.byType(TextField), 'Error');
      await tester.pumpAndSettle();

      // Navigate back (should work despite error)
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(NotesListScreen), findsOneWidget);

      // Reset error condition
      dataSource.shouldFailNextOperation = false;

      // Verify app is still functional
      await tester.tap(find.text('Error recovery test'));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Error recovery test'), findsOneWidget);
    });
  });
}

/// Test settings cubit for testing
class TestSettingsCubit extends SettingsCubit {
  TestSettingsCubit() : super(prefs: _FakePrefs());

  @override
  void setThemeMode(ThemeMode mode) => emit(mode);
}

/// Fake SharedPreferences for testing
class _FakePrefs implements SharedPreferences {
  final Map<String, Object> _map = {};

  @override
  String? getString(String key) => _map[key] as String?;

  @override
  Future<bool> setString(String key, String value) async {
    _map[key] = value;
    return true;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Helper to build test app with proper providers
Widget _buildTestApp(NotesBloc notesBloc, TestSettingsCubit settingsCubit) {
  return MaterialApp(
    home: MultiBlocProvider(
      providers: [
        BlocProvider<NotesBloc>.value(value: notesBloc),
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
      ],
      child: const NotesListScreen(),
    ),
  );
}
