import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/fake_note_datasource.dart';
import '../helpers/test_helpers.dart';

/// Comprehensive integration tests for archive visibility functionality.
void main() {
  group('Archive Visibility Integration Tests', () {
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
      dataSource.clear();
    });

    test('Complete archive workflow', () async {
      final testNote = TestHelpers.createTestNote(
        content: 'Archive workflow test note',
        priority: NotePriority.high,
      );
      await repository.create(testNote);

      var activeNotes = await repository.getActive();
      expect(activeNotes.length, 1);
      expect(activeNotes.first.content, 'Archive workflow test note');
      expect(activeNotes.first.isArchived, isFalse);

      final archivedNote = testNote.copyWith(isArchived: true, isPinned: false);
      await repository.update(archivedNote);

      activeNotes = await repository.getActive();
      expect(activeNotes.isEmpty, isTrue);

      final archivedNotes = await repository.getArchived();
      expect(archivedNotes.length, 1);
      expect(archivedNotes.first.content, 'Archive workflow test note');
      expect(archivedNotes.first.isArchived, isTrue);
    });
  });
}

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
