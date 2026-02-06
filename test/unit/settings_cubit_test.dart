import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
  });

  group('SettingsCubit', () {
    test('initial state is system when no stored preference', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn(null);

      final cubit = SettingsCubit(prefs: mockPrefs);

      expect(cubit.state, ThemeMode.system);
    });

    test('loads stored light theme preference', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn('light');

      final cubit = SettingsCubit(prefs: mockPrefs);

      expect(cubit.state, ThemeMode.light);
    });

    test('loads stored dark theme preference', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn('dark');

      final cubit = SettingsCubit(prefs: mockPrefs);

      expect(cubit.state, ThemeMode.dark);
    });

    test('handles invalid stored value gracefully', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn('invalid');

      final cubit = SettingsCubit(prefs: mockPrefs);

      expect(cubit.state, ThemeMode.system);
    });

    test('setThemeMode updates state and persists', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn(null);
      when(() => mockPrefs.setString('themeMode', any()))
          .thenAnswer((_) async => true);

      final cubit = SettingsCubit(prefs: mockPrefs);

      cubit.setThemeMode(ThemeMode.dark);

      expect(cubit.state, ThemeMode.dark);
      verify(() => mockPrefs.setString('themeMode', 'dark')).called(1);
    });

    test('cycleThemeMode cycles system -> light -> dark -> system', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn(null);
      when(() => mockPrefs.setString('themeMode', any()))
          .thenAnswer((_) async => true);

      final cubit = SettingsCubit(prefs: mockPrefs);

      expect(cubit.state, ThemeMode.system);

      cubit.cycleThemeMode();
      expect(cubit.state, ThemeMode.light);
      verify(() => mockPrefs.setString('themeMode', 'light')).called(1);

      cubit.cycleThemeMode();
      expect(cubit.state, ThemeMode.dark);
      verify(() => mockPrefs.setString('themeMode', 'dark')).called(1);

      cubit.cycleThemeMode();
      expect(cubit.state, ThemeMode.system);
      verify(() => mockPrefs.setString('themeMode', 'system')).called(1);
    });

    test('setThemeMode to light persists correctly', () {
      when(() => mockPrefs.getString('themeMode'))
          .thenReturn(null);
      when(() => mockPrefs.setString('themeMode', any()))
          .thenAnswer((_) async => true);

      final cubit = SettingsCubit(prefs: mockPrefs);
      cubit.setThemeMode(ThemeMode.light);

      expect(cubit.state, ThemeMode.light);
      verify(() => mockPrefs.setString('themeMode', 'light')).called(1);
    });
  });
}
