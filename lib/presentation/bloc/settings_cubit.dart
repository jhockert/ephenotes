import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit managing application settings, primarily theme mode.
///
/// Persists the user's theme preference to SharedPreferences
/// and restores it on app startup.
class SettingsCubit extends Cubit<ThemeMode> {
  final SharedPreferences _prefs;

  static const _themeModeKey = 'themeMode';

  SettingsCubit({required SharedPreferences prefs})
      : _prefs = prefs,
        super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final stored = _prefs.getString(_themeModeKey) ?? 'system';
    emit(_fromString(stored));
  }

  /// Cycles theme mode: system -> light -> dark -> system.
  void cycleThemeMode() {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
    setThemeMode(next);
  }

  /// Sets theme mode to a specific value and persists it.
  void setThemeMode(ThemeMode mode) {
    _prefs.setString(_themeModeKey, _toString(mode));
    emit(mode);
  }

  static String _toString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };
  }

  static ThemeMode _fromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }
}
