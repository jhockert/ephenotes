import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/presentation/screens/notes_list_screen.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import '../test/helpers/fake_note_datasource.dart';

class TestSettingsCubit extends SettingsCubit {
  TestSettingsCubit() : super(prefs: _MockPrefs());
  @override
  void setThemeMode(ThemeMode mode) => emit(mode);
}

class _MockPrefs extends Mock implements SharedPreferences {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create → Edit → Archive → Restore flow', (tester) async {
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

    await tester.enterText(find.byType(TextField).first, 'Integration note');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    // Note should appear in list
    expect(find.text('Integration note'), findsOneWidget);

    // Edit note
    await tester.tap(find.text('Integration note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Integration note edited');
    await tester.tap(find.byIcon(Icons.check));
    await tester.pumpAndSettle();

    expect(find.text('Integration note edited'), findsOneWidget);

    // Archive note via long-press menu
    await tester.longPress(find.text('Integration note edited'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Archive'));
    await tester.pumpAndSettle();

    expect(find.text('Note archived'), findsOneWidget);

    // Navigate to Archive screen
    await tester.tap(find.byIcon(Icons.archive_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Archive'), findsOneWidget);
    expect(find.text('Integration note edited'), findsOneWidget);

    // Restore from archive
    await tester.longPress(find.text('Integration note edited'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Restore'));
    await tester.pumpAndSettle();

    expect(find.text('Note restored'), findsOneWidget);

    // Back to main screen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.text('Integration note edited'), findsOneWidget);
  });
}
