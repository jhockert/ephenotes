# ephenotes

Virtual post-it notes app. 140-character limit per note. Local-only storage, zero tracking.

## Tech Stack

- **Flutter** >=3.24 / **Dart** >=3.5
- **State**: BLoC (flutter_bloc) + SettingsCubit
- **Storage**: ObjectBox
- **DI**: get_it (see `lib/injection.dart`)
- **Testing**: bloc_test, mocktail

## Source Structure

```
lib/
  core/
    constants/          # app_colors, ui_strings
    error/              # app_error, error_handler, database_health_monitor
    theme/              # app_theme (light + dark)
    utils/              # accessibility, contrast, sorting, performance
  data/
    datasources/local/  # NoteLocalDataSource (interface), ObjectBoxNoteDataSource (impl)
    models/note.dart    # Note model with ObjectBox annotations
    repositories/       # NoteRepository / NoteRepositoryImpl
  presentation/
    bloc/               # NotesBloc (events, states), SettingsCubit
    screens/            # notes_list, note_editor, archive, search, settings
    widgets/            # note_card, swipeable_note_card, color_picker, icon_selector,
                        #   priority_selector, error_display, virtual_note_list
  injection.dart        # GetIt DI setup
  main.dart             # App entry point, ObjectBox init
```

## Data Flow

```
UI -> BLoC (Events) -> Repository -> DataSource -> ObjectBox
UI <- BLoC (States) <- Repository <- DataSource <- ObjectBox
```

## Rules

1. **TDD** - Write tests before implementation
2. **80% coverage min** (BLoC: 90%, Repositories: 85%)
3. **Zero issues**: `flutter analyze` + `dart format` must pass
4. **Conventional commits**: `feat:`, `fix:`, `docs:`, `test:`, etc.
5. **No print statements** - Use logging or remove before commit
6. **No hardcoded strings** - Use constants
7. **Both themes**: Light and dark mode must work
8. **Platforms**: iOS 13.0+ / Android API 23+

## Commands

```bash
flutter test                    # Run all tests
flutter test --coverage         # With coverage
flutter analyze                 # Static analysis
dart format lib/ test/          # Format code
flutter run                     # Run app
```

## Key Specs

Read [specs/DECISIONS.md](specs/DECISIONS.md) before implementing any feature.

| Document | Purpose |
|----------|---------|
| [specs/SPEC.md](specs/SPEC.md) | Full technical spec (source of truth) |
| [specs/REQUIREMENTS.md](specs/REQUIREMENTS.md) | 27 FRs + 41 NFRs |
| [specs/DECISIONS.md](specs/DECISIONS.md) | 20 design decisions |
| [specs/IMPLEMENTATION.md](specs/IMPLEMENTATION.md) | Architecture details |
| [STATUS.md](STATUS.md) | What's built and what's left |
