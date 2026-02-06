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

/// Simplified end-to-end integration tests that focus on core workflows
/// without complex UI interactions that may be fragile.
///
/// These tests verify:
/// - Complete user workflows through the app
/// - Cross-screen navigation functionality
/// - State persistence across navigation
/// - Basic app lifecycle scenarios
void main() {
  group('Simplified End-to-End Integration Tests', () {
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

    /// Test basic navigation between screens
    testWidgets('Basic screen navigation works correctly', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Start on main screen
      expect(find.byType(NotesListScreen), findsOneWidget);

      // Navigate to search screen
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);

      // Navigate to archive screen
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(ArchiveScreen), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);

      // Navigate to note editor
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreen), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);
    });

    /// Test note creation and display workflow
    testWidgets('Note creation and display workflow', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Initially no notes
      expect(find.text('No notes yet'), findsOneWidget);

      // Navigate to note editor
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreen), findsOneWidget);

      // Enter note content
      const noteContent = 'Test integration note';
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        noteContent,
      );

      // Save the note
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Should be back on main screen with note visible
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text(noteContent), findsOneWidget);
      expect(find.text('No notes yet'), findsNothing);
    });

    /// Test note editing workflow
    testWidgets('Note editing workflow', (tester) async {
      // Pre-create a note
      final testNote = TestHelpers.createTestNote(
        content: 'Original note content',
        priority: NotePriority.normal,
      );
      await repository.create(testNote);

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Load notes
      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Note should be visible
      expect(find.text('Original note content'), findsOneWidget);

      // Tap note to edit
      await tester.tap(find.text('Original note content'));
      await tester.pumpAndSettle();

      // Should be on editor screen
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Edit Note'), findsOneWidget);

      // Edit the content
      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Edited note content',
      );

      // Save changes
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Should be back on main screen with updated content
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text('Edited note content'), findsOneWidget);
      expect(find.text('Original note content'), findsNothing);
    });

    /// Test archive and restore workflow
    testWidgets('Archive and restore workflow', (tester) async {
      // Pre-create a note
      final testNote = TestHelpers.createTestNote(
        content: 'Note to archive',
        priority: NotePriority.high,
      );
      await repository.create(testNote);

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Load notes
      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Note should be visible
      expect(find.text('Note to archive'), findsOneWidget);

      // Archive the note via swipe
      await tester.drag(find.text('Note to archive'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Should show archive confirmation
      expect(find.text('Note archived'), findsOneWidget);

      // Wait for undo timeout
      await tester.pump(const Duration(seconds: 4));

      // Note should no longer be on main screen
      expect(find.text('Note to archive'), findsNothing);

      // Navigate to archive screen
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();

      // Note should be in archive
      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('Note to archive'), findsOneWidget);

      // Restore the note via long press
      await tester.longPress(find.text('Note to archive'));
      await tester.pumpAndSettle();

      // Tap restore option
      await tester.tap(find.text('Restore'));
      await tester.pumpAndSettle();

      // Should show restore confirmation
      expect(find.text('Note restored'), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Note should be back on main screen
      expect(find.byType(NotesListScreen), findsOneWidget);
      expect(find.text('Note to archive'), findsOneWidget);
    });

    /// Test search functionality
    testWidgets('Search functionality workflow', (tester) async {
      // Pre-create multiple notes
      final notes = [
        TestHelpers.createTestNote(content: 'Meeting notes for project'),
        TestHelpers.createTestNote(content: 'Grocery shopping list'),
        TestHelpers.createTestNote(content: 'Project deadline reminder'),
      ];

      for (final note in notes) {
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Load notes
      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // All notes should be visible
      expect(find.text('Meeting notes for project'), findsOneWidget);
      expect(find.text('Grocery shopping list'), findsOneWidget);
      expect(find.text('Project deadline reminder'), findsOneWidget);

      // Navigate to search screen
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      // Search for "project"
      await tester.enterText(find.byType(TextField), 'project');
      await tester.pumpAndSettle();

      // Should find 2 notes with "project"
      expect(find.text('Meeting notes for project'), findsOneWidget);
      expect(find.text('Project deadline reminder'), findsOneWidget);
      expect(find.text('Grocery shopping list'), findsNothing);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // All notes should be visible again
      expect(find.text('Meeting notes for project'), findsOneWidget);
      expect(find.text('Grocery shopping list'), findsOneWidget);
      expect(find.text('Project deadline reminder'), findsOneWidget);

      // Navigate back to main screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);
    });

    /// Test state persistence across navigation
    testWidgets('State persistence across navigation', (tester) async {
      // Pre-create notes with different states
      final notes = [
        TestHelpers.createTestNote(content: 'Active note 1', isPinned: true),
        TestHelpers.createTestNote(content: 'Active note 2', isPinned: false),
        TestHelpers.createTestNote(content: 'Archived note', isArchived: true),
      ];

      for (final note in notes) {
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Load notes
      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Active notes should be visible
      expect(find.text('Active note 1'), findsOneWidget);
      expect(find.text('Active note 2'), findsOneWidget);
      expect(find.text('Archived note'), findsNothing);

      // Navigate through multiple screens
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.byType(ArchiveScreen), findsOneWidget);
      expect(find.text('Archived note'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);

      // State should be preserved - active notes still visible
      expect(find.text('Active note 1'), findsOneWidget);
      expect(find.text('Active note 2'), findsOneWidget);
      expect(find.text('Archived note'), findsNothing);
    });

    /// Test error handling during operations
    testWidgets('Error handling during operations', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note successfully first
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Successful note',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Successful note'), findsOneWidget);

      // Now simulate an error condition
      dataSource.shouldFailNextOperation = true;

      // Try to create another note (should handle error gracefully)
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Failed note',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // App should still be functional, original note should still be there
      expect(find.text('Successful note'), findsOneWidget);
      expect(find.byType(NotesListScreen), findsOneWidget);

      // Reset error condition
      dataSource.shouldFailNextOperation = false;

      // Verify app is still functional
      await tester.tap(find.text('Successful note'));
      await tester.pumpAndSettle();
      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Successful note'), findsOneWidget);
    });

    /// Test multiple operations in sequence
    testWidgets('Multiple operations in sequence', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create multiple notes
      final noteContents = ['First note', 'Second note', 'Third note'];

      for (final content in noteContents) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate((w) =>
              w is TextField &&
              (w.decoration?.hintText ?? '') == 'Enter your note...'),
          content,
        );

        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();
      }

      // All notes should be visible
      for (final content in noteContents) {
        expect(find.text(content), findsOneWidget);
      }

      // Edit one note
      await tester.tap(find.text('Second note'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) =>
            w is TextField &&
            (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Second note - EDITED',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Second note - EDITED'), findsOneWidget);
      expect(find.text('Second note'), findsNothing);

      // Archive one note
      await tester.drag(find.text('Third note'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));

      expect(find.text('Third note'), findsNothing);

      // Verify remaining notes
      expect(find.text('First note'), findsOneWidget);
      expect(find.text('Second note - EDITED'), findsOneWidget);

      // Check archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Third note'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Final state verification
      expect(find.text('First note'), findsOneWidget);
      expect(find.text('Second note - EDITED'), findsOneWidget);
      expect(find.text('Third note'), findsNothing);
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
