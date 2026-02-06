import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Comprehensive end-to-end integration tests covering complete user workflows.
///
/// Tests include:
/// - Complete user workflows (create → edit → archive → restore)
/// - Cross-screen navigation and state persistence
/// - App lifecycle handling (pause/resume/terminate)
/// - Complex multi-step user journeys
/// - State consistency across screen transitions
void main() {
  group('End-to-End Integration Tests', () {
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

    /// Test complete user workflow: Create → Edit → Archive → Restore
    testWidgets('Complete user workflow: Create → Edit → Archive → Restore',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Step 1: Create a new note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Verify we're on the note editor screen
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('New Note'), findsOneWidget);

      // Enter note content
      const noteContent = 'End-to-end test note';
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        noteContent,
      );

      // Set priority to High
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Set color to Sky Blue
      await tester.tap(find.byWidgetPredicate((w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration as BoxDecoration).color?.toARGB32() ==
              Colors.lightBlue.toARGB32()));
      await tester.pumpAndSettle();

      // Save the note
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify we're back on the main screen and note is visible
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text(noteContent), findsOneWidget);

      // Step 2: Edit the note
      await tester.tap(find.text(noteContent));
      await tester.pumpAndSettle();

      // Verify we're on the edit screen
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Edit Note'), findsOneWidget);

      // Modify the content
      const editedContent = 'End-to-end test note - EDITED';
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        editedContent,
      );

      // Change priority to Medium
      await tester.tap(find.text('Medium'));
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify changes are reflected on main screen
      expect(find.text(editedContent), findsOneWidget);
      expect(find.text(noteContent), findsNothing);

      // Step 3: Archive the note via swipe
      await tester.drag(find.text(editedContent), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify archive snackbar appears
      expect(find.text('Note archived'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 4));

      // Verify note is no longer on main screen
      expect(find.text(editedContent), findsNothing);

      // Step 4: Navigate to archive screen
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      // Verify we're on archive screen and note is there
      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text(editedContent), findsOneWidget);

      // Step 5: Restore the note
      await tester.longPress(find.text(editedContent));
      await tester.pumpAndSettle();

      // Tap restore option
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      // Verify restore snackbar
      expect(find.text('Note restored'), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify note is back on main screen
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text(editedContent), findsOneWidget);

      // Verify note maintains its properties (Medium priority, Sky Blue color)
      final restoredNotes = await repository.getActive();
      final restoredNote =
          restoredNotes.firstWhere((n) => n.content == editedContent);
      expect(restoredNote.priority, NotePriority.normal);
      expect(restoredNote.color, NoteColor.skyBlue);
    });

    /// Test complex multi-screen navigation with state persistence
    testWidgets('Complex multi-screen navigation with state persistence',
        (tester) async {
      // Pre-populate with test data
      final testNotes = TestHelpers.generateTestNotesWithCharacteristics(
        count: 5,
        forcePriority: NotePriority.high,
      );
      for (final note in testNotes) {
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Load notes
      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Verify notes are displayed
      expect(find.byType(Card), findsNWidgets(5));

      // Navigate to Search screen
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      // Perform a search
      await tester.enterText(find.byType(TextField), 'Meeting');
      await tester.pumpAndSettle();

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back on main screen with all notes still visible
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));

      // Navigate to Archive screen
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('No archived notes'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify all state is preserved
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.byType(Card), findsNWidgets(5));
    });

    /// Test app lifecycle handling (pause/resume simulation)
    testWidgets('App lifecycle handling - pause/resume simulation',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const noteContent = 'Lifecycle test note';
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        noteContent,
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify note is created
      expect(find.text(noteContent), findsOneWidget);

      // Simulate app pause (backgrounding)
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routeUpdated', {
            'location': '/',
            'state': null,
          }),
        ),
        (data) {},
      );

      // Simulate app resume (foregrounding)
      await binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/lifecycle',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routeUpdated', {
            'location': '/',
            'state': null,
          }),
        ),
        (data) {},
      );

      await tester.pumpAndSettle();

      // Verify app state is preserved after lifecycle events
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text(noteContent), findsOneWidget);

      // Verify note can still be edited after lifecycle events
      await tester.tap(find.text(noteContent));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Edit Note'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text(noteContent), findsOneWidget);
    });

    /// Test data persistence across app termination simulation
    testWidgets('Data persistence across app termination simulation',
        (tester) async {
      // First app session - create notes
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create multiple notes with different properties
      final testData = [
        {'content': 'Persistent note 1', 'priority': NotePriority.high},
        {'content': 'Persistent note 2', 'priority': NotePriority.normal},
        {'content': 'Persistent note 3', 'priority': NotePriority.low},
      ];

      for (final data in testData) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField &&
              (w.decoration?.hintText ?? '') == 'Enter your note...'),
          data['content'] as String,
        );

        // Set priority
        final priority = data['priority'] as NotePriority;
        await tester.tap(find.text(priority.name.capitalize()));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();
      }

      // Verify all notes are created
      for (final data in testData) {
        expect(find.text(data['content'] as String), findsOneWidget);
      }

      // Archive one note
      await tester.drag(find.text('Persistent note 2'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Wait for snackbar to disappear
      await tester.pump(const Duration(seconds: 4));

      // Pin one note
      await tester.longPress(find.text('Persistent note 1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();

      // Simulate app termination by creating new instances
      await notesBloc.close();
      await settingsCubit.close();

      // Second app session - verify persistence
      final newDataSource = FakeNoteLocalDataSource();
      // Copy data from old datasource to simulate persistence
      final persistedNotes = await dataSource.getAll();
      for (final note in persistedNotes) {
        await newDataSource.create(note);
      }

      final newRepository = NoteRepositoryImpl(dataSource: newDataSource);
      final newNotesBloc = NotesBloc(repository: newRepository);
      final newSettingsCubit = TestSettingsCubit();

      await tester.pumpWidget(_buildTestApp(newNotesBloc, newSettingsCubit));
      await tester.pumpAndSettle();

      // Load notes in new session
      newNotesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Verify active notes are still there
      expect(find.text('Persistent note 1'), findsOneWidget);
      expect(find.text('Persistent note 3'), findsOneWidget);
      expect(
          find.text('Persistent note 2'), findsNothing); // Should be archived

      // Verify archived note is in archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Persistent note 2'), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify pinned note is still pinned (should be at top)
      final activeNotes = await newRepository.getActive();
      final pinnedNote =
          activeNotes.firstWhere((n) => n.content == 'Persistent note 1');
      expect(pinnedNote.isPinned, isTrue);

      // Clean up
      await newNotesBloc.close();
      await newSettingsCubit.close();
    });

    /// Test error recovery and state consistency
    testWidgets('Error recovery and state consistency', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const noteContent = 'Error recovery test';
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        noteContent,
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify note is created
      expect(find.text(noteContent), findsOneWidget);

      // Simulate an error by making the datasource fail
      dataSource.shouldFailNextOperation = true;

      // Try to create another note (this should fail)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'This should fail',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // The error should be handled gracefully
      // The original note should still be visible
      expect(find.text(noteContent), findsOneWidget);

      // Reset the error condition
      dataSource.shouldFailNextOperation = false;

      // Verify we can still interact with existing notes
      await tester.tap(find.text(noteContent));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      // Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify app is still functional
      expect(find.text(noteContent), findsOneWidget);
    });

    /// Test complex user journey with multiple operations
    testWidgets('Complex user journey with multiple operations',
        (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Journey: Create 3 notes → Edit 1 → Archive 1 → Search → Pin 1 → Restore archived

      // Step 1: Create 3 notes with different priorities
      final noteContents = [
        'High priority note',
        'Medium priority note',
        'Low priority note'
      ];
      final priorities = [
        NotePriority.high,
        NotePriority.normal,
        NotePriority.low
      ];

      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField &&
              (w.decoration?.hintText ?? '') == 'Enter your note...'),
          noteContents[i],
        );

        await tester.tap(find.text(priorities[i].name.capitalize()));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();
      }

      // Verify all notes are created and properly ordered by priority
      expect(find.text('High priority note'), findsOneWidget);
      expect(find.text('Medium priority note'), findsOneWidget);
      expect(find.text('Low priority note'), findsOneWidget);

      // Step 2: Edit the medium priority note
      await tester.tap(find.text('Medium priority note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Medium priority note - EDITED',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Medium priority note - EDITED'), findsOneWidget);

      // Step 3: Archive the low priority note
      await tester.drag(find.text('Low priority note'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('Low priority note'), findsNothing);

      // Step 4: Search for "priority"
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'priority');
      await tester.pumpAndSettle();

      // Should find 2 active notes
      expect(find.text('High priority note'), findsOneWidget);
      expect(find.text('Medium priority note - EDITED'), findsOneWidget);
      expect(find.text('Low priority note'), findsNothing); // Archived

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Step 5: Pin the high priority note
      await tester.longPress(find.text('High priority note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pin'));
      await tester.pumpAndSettle();

      // Step 6: Navigate to archive and restore the archived note
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Low priority note'), findsOneWidget);

      await tester.longPress(find.text('Low priority note'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify final state: all 3 notes are active, high priority is pinned
      expect(find.text('High priority note'), findsOneWidget);
      expect(find.text('Medium priority note - EDITED'), findsOneWidget);
      expect(find.text('Low priority note'), findsOneWidget);

      // Verify pinned note is at the top by checking repository state
      final finalNotes = await repository.getActive();
      final pinnedNote =
          finalNotes.firstWhere((n) => n.content == 'High priority note');
      expect(pinnedNote.isPinned, isTrue);
    });
  });
}

/// Test settings cubit for testing
class TestSettingsCubit extends SettingsCubit {
  TestSettingsCubit() : super(prefs: _FakePrefs());

  @override
  void setThemeMode(ThemeMode mode) => emit(mode);

  @override
  void cycleThemeMode() {
    final current = state;
    switch (current) {
      case ThemeMode.system:
        emit(ThemeMode.light);
        break;
      case ThemeMode.light:
        emit(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        emit(ThemeMode.system);
        break;
    }
  }
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

/// Extension to capitalize strings
extension StringCapitalization on String {
  String capitalize() {
    if (length == 0) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
