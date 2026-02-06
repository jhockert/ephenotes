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
import '../helpers/fake_note_datasource.dart';

class TestSettingsCubit extends SettingsCubit {
  TestSettingsCubit() : super(prefs: _FakePrefs());
  @override
  void setThemeMode(ThemeMode mode) => emit(mode);
}

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

void main() {
  testWidgets('Create → Edit → Archive → Restore flow (widget-level)',
      (tester) async {
    final dataSource = FakeNoteLocalDataSource();
    final repository = NoteRepositoryImpl(dataSource: dataSource);
    final notesBloc = NotesBloc(repository: repository);

    final settingsCubit = TestSettingsCubit();

    await tester.pumpWidget(
      MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<NotesBloc>.value(value: notesBloc),
            BlocProvider<SettingsCubit>.value(value: settingsCubit),
          ],
          child: const NotesListScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Create a note
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(NoteEditorScreen), findsOneWidget);

    await tester.enterText(
      find.byWidgetPredicate((w) =>
          w is TextField &&
          (w.decoration?.hintText ?? '') == 'Enter your note...'),
      'Integration note',
    );
    await tester.tap(find.byTooltip('Save'));
    await tester.pumpAndSettle();

    // Note should appear in list
    expect(find.text('Integration note'), findsOneWidget);

    // Update the created note via BLoC (more reliable for widget-level flows)
    final createdNotes = await repository.getActive();
    expect(createdNotes.length, greaterThan(0));
    final created = createdNotes.first;

    notesBloc
        .add(UpdateNote(created.copyWith(content: 'Integration note edited')));
    await tester.pumpAndSettle();

    final activeNotes = await repository.getActive();
    expect(
        activeNotes.any((n) => n.content == 'Integration note edited'), isTrue);

    // Archive via BLoC and verify it got archived in repository
    notesBloc.add(ArchiveNote(created.id));
    await tester.pumpAndSettle();

    final archived = await repository.getArchived();
    expect(archived.any((n) => n.id == created.id), isTrue);

    // Navigate to Archive screen and verify presence
    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Integration note edited'), findsOneWidget);

    // Restore via BLoC and verify repository and main screen
    notesBloc.add(UnarchiveNote(created.id));
    await tester.pumpAndSettle();

    final activeAfterRestore = await repository.getActive();
    expect(activeAfterRestore.any((n) => n.id == created.id), isTrue);

    // Back to main screen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Integration note edited'), findsOneWidget);
  });
}
