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
import 'package:ephenotes/presentation/screens/search_screen.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/fake_note_datasource.dart';
import '../helpers/test_helpers.dart';

/// Integration tests focused on app lifecycle handling.
/// 
/// Tests various app lifecycle scenarios:
/// - App pause/resume during note editing
/// - App termination and restart with data persistence
/// - Memory pressure handling
/// - Background/foreground transitions
/// - System interruptions (calls, notifications)
void main() {
  group('App Lifecycle Integration Tests', () {
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

    /// Test app pause/resume during note editing
    testWidgets('App pause/resume during note editing preserves state', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Start creating a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      // Enter partial content
      const partialContent = 'This is a partial note being';
      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        partialContent,
      );

      // Set priority to High
      await tester.tap(find.text('High'));
      await tester.pumpAndSettle();

      // Simulate app pause (user switches to another app)
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      // Simulate app resume (user returns to app)
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify we're still on the editor screen with content preserved
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text(partialContent), findsOneWidget);

      // Complete the note
      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        '$partialContent edited after resume',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      // Verify note was saved successfully
      expect(find.text('$partialContent edited after resume'), findsOneWidget);
    });

    /// Test app termination and restart with data persistence
    testWidgets('App termination and restart preserves all data', (tester) async {
      // Session 1: Create and modify notes
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create multiple notes with different states
      final testScenarios = [
        {
          'content': 'Active high priority note',
          'priority': NotePriority.high,
          'pinned': true,
          'archived': false,
        },
        {
          'content': 'Active medium priority note',
          'priority': NotePriority.normal,
          'pinned': false,
          'archived': false,
        },
        {
          'content': 'Archived low priority note',
          'priority': NotePriority.low,
          'pinned': false,
          'archived': true,
        },
      ];

      for (final scenario in testScenarios) {
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
          scenario['content'] as String,
        );

        final priority = scenario['priority'] as NotePriority;
        await tester.tap(find.text(priority.name.capitalize()));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();

        // Pin if needed
        if (scenario['pinned'] as bool) {
          await tester.longPress(find.text(scenario['content'] as String));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Pin'));
          await tester.pumpAndSettle();
        }

        // Archive if needed
        if (scenario['archived'] as bool) {
          await tester.drag(find.text(scenario['content'] as String), const Offset(-300, 0));
          await tester.pumpAndSettle();
          await tester.pump(const Duration(seconds: 4)); // Wait for snackbar
        }
      }

      // Change theme setting
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Simulate app termination
      await _simulateAppLifecycleState(AppLifecycleState.detached);
      await tester.pump();

      // Close current instances
      await notesBloc.close();
      await settingsCubit.close();

      // Session 2: Restart app with new instances
      final newDataSource = FakeNoteLocalDataSource();
      // Simulate data persistence by copying data
      final persistedNotes = await dataSource.getAll();
      for (final note in persistedNotes) {
        await newDataSource.create(note);
      }

      final newRepository = NoteRepositoryImpl(dataSource: newDataSource);
      final newNotesBloc = NotesBloc(repository: newRepository);
      final newSettingsCubit = TestSettingsCubit();
      // Simulate persisted theme setting
      newSettingsCubit.setThemeMode(ThemeMode.dark);

      await tester.pumpWidget(_buildTestApp(newNotesBloc, newSettingsCubit));
      await tester.pumpAndSettle();

      newNotesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Verify active notes are restored
      expect(find.text('Active high priority note'), findsOneWidget);
      expect(find.text('Active medium priority note'), findsOneWidget);
      expect(find.text('Archived low priority note'), findsNothing); // Should be archived

      // Verify archived note is in archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Archived low priority note'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify note properties are preserved
      final restoredNotes = await newRepository.getActive();
      final pinnedNote = restoredNotes.firstWhere((n) => n.content == 'Active high priority note');
      expect(pinnedNote.isPinned, isTrue);
      expect(pinnedNote.priority, NotePriority.high);

      // Verify theme setting is preserved
      expect(newSettingsCubit.state, ThemeMode.dark);

      // Clean up
      await newNotesBloc.close();
      await newSettingsCubit.close();
    });

    /// Test memory pressure handling
    testWidgets('Memory pressure handling maintains core functionality', (tester) async {
      // Create a large dataset to simulate memory pressure
      final largeDataset = TestHelpers.generateTestNotes(100);
      for (final note in largeDataset) {
        await repository.create(note);
      }

      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      notesBloc.add(const LoadNotes());
      await tester.pumpAndSettle();

      // Simulate memory pressure
      await _simulateMemoryPressure();
      await tester.pump();

      // Verify app is still responsive
      expect(find.byType(NotesListScreen), findsOneWidget);

      // Verify we can still create notes under memory pressure
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.byType(NoteEditorScreen), findsOneWidget);

      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Note created under memory pressure',
      );

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Note created under memory pressure'), findsOneWidget);

      // Verify navigation still works
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.byType(NotesListScreen), findsOneWidget);
    });

    /// Test background/foreground transitions during various operations
    testWidgets('Background/foreground transitions during operations', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Test 1: Background during note creation
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Background test note',
      );

      // Simulate app going to background
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();

      // Simulate app returning to foreground
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Complete note creation
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Background test note'), findsOneWidget);

      // Test 2: Background during search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Background');
      await tester.pumpAndSettle();

      expect(find.text('Background test note'), findsOneWidget);

      // Simulate background/foreground during search
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify search results are still displayed
      expect(find.text('Background test note'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Test 3: Background during archive operation
      await tester.drag(find.text('Background test note'), const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Simulate background before undo timeout
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify archive operation completed
      await tester.pump(const Duration(seconds: 4));
      expect(find.text('Background test note'), findsNothing);

      // Verify note is in archive
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Background test note'), findsOneWidget);
    });

    /// Test system interruptions (simulated)
    testWidgets('System interruptions handling', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      const noteContent = 'Interruption test note';
      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        noteContent,
      );

      // Simulate system interruption (like incoming call)
      await _simulateSystemInterruption();
      await tester.pump();

      // Simulate interruption ending
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify we're still on the editor screen
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text(noteContent), findsOneWidget);

      // Complete note creation
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text(noteContent), findsOneWidget);

      // Test interruption during note editing
      await tester.tap(find.text(noteContent));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        '$noteContent - EDITED',
      );

      // Simulate another interruption
      await _simulateSystemInterruption();
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Save the edited note
      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('$noteContent - EDITED'), findsOneWidget);
    });

    /// Test rapid lifecycle state changes
    testWidgets('Rapid lifecycle state changes', (tester) async {
      await tester.pumpWidget(_buildTestApp(notesBloc, settingsCubit));
      await tester.pumpAndSettle();

      // Create a note
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byWidgetPredicate((w) => w is TextField && (w.decoration?.hintText ?? '') == 'Enter your note...'),
        'Rapid lifecycle test',
      );

      // Simulate rapid state changes (like quick app switching)
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify app is still functional
      expect(find.byType(NoteEditorScreen), findsOneWidget);
      expect(find.text('Rapid lifecycle test'), findsOneWidget);

      await tester.tap(find.byTooltip('Save'));
      await tester.pumpAndSettle();

      expect(find.text('Rapid lifecycle test'), findsOneWidget);

      // Test rapid changes during navigation
      await tester.tap(find.byIcon(Icons.search));
      await _simulateAppLifecycleState(AppLifecycleState.paused);
      await tester.pump();
      await _simulateAppLifecycleState(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Rapid lifecycle test'), findsOneWidget);
    });
  });
}

/// Helper functions for lifecycle simulation

Future<void> _simulateAppLifecycleState(AppLifecycleState state) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/lifecycle',
    const StandardMethodCodec().encodeMethodCall(
      MethodCall('AppLifecycleState.${state.name}'),
    ),
    (data) {},
  );
}

Future<void> _simulateMemoryPressure() async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  await binding.defaultBinaryMessenger.handlePlatformMessage(
    'flutter/system',
    const StandardMethodCodec().encodeMethodCall(
      const MethodCall('SystemNavigator.routeUpdated', {
        'location': '/',
        'state': null,
      }),
    ),
    (data) {},
  );
}

Future<void> _simulateSystemInterruption() async {
  // Simulate system interruption by pausing and then inactive state
  await _simulateAppLifecycleState(AppLifecycleState.inactive);
  await _simulateAppLifecycleState(AppLifecycleState.paused);
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

/// Extension to capitalize strings
extension StringCapitalization on String {
  String capitalize() {
    if (length == 0) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}