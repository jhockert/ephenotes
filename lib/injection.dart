import 'package:get_it/get_it.dart';
import 'package:objectbox/objectbox.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/data/datasources/local/objectbox_note_datasource.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';

/// Global service locator for dependency injection.
final getIt = GetIt.instance;

/// Initializes all dependencies for the application.
///
/// This should be called once during app startup, after ObjectBox is initialized.
/// Register dependencies in order: data sources → repositories → BLoCs.
Future<void> setupDependencyInjection(Store store) async {
  // Register ObjectBox Store
  getIt.registerSingleton<Store>(store);

  // Register data sources
  getIt.registerLazySingleton<NoteLocalDataSource>(
    () => ObjectBoxNoteDataSource(
      store: getIt<Store>(),
    ),
  );

  // Register repositories
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      dataSource: getIt<NoteLocalDataSource>(),
    ),
  );

  // Register BLoCs as factories (new instance each time)
  getIt.registerFactory<NotesBloc>(
    () => NotesBloc(repository: getIt<NoteRepository>()),
  );

  // Register SharedPreferences for settings
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Register settings cubit as singleton (shared across app)
  getIt.registerLazySingleton<SettingsCubit>(
    () => SettingsCubit(prefs: getIt<SharedPreferences>()),
  );
}
