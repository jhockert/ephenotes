import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/injection.dart';
import 'package:ephenotes/core/theme/app_theme.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/presentation/screens/notes_list_screen.dart';
import 'package:ephenotes/objectbox.g.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Main entry point for the ephenotes app.
///
/// Initializes ObjectBox database and sets up dependency injection
/// before launching the app.
Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize ObjectBox
  final docsDir = await getApplicationDocumentsDirectory();
  final store = await openStore(directory: p.join(docsDir.path, 'objectbox'));

  // Setup dependency injection with ObjectBox store
  await setupDependencyInjection(store);

  // Run the app
  runApp(const EphenotesApp());
}

/// Root application widget.
class EphenotesApp extends StatelessWidget {
  const EphenotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<NotesBloc>()..add(const LoadNotes()),
        ),
        BlocProvider(
          create: (context) => getIt<SettingsCubit>(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'ephenotes',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            home: const NotesListScreen(),
          );
        },
      ),
    );
  }
}
