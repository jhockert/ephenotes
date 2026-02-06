# ephenotes - Project Setup Guide

Complete step-by-step guide to initialize the ephenotes Flutter project from scratch.

---

## Prerequisites

Ensure you have installed:
- **Flutter SDK**: 3.16 or later
- **Dart SDK**: 3.0 or later
- **IDE**: VS Code or Android Studio with Flutter extension
- **Xcode**: 15+ (for iOS development, macOS only)
- **Android Studio**: For Android development

### Verify Installation

```bash
flutter doctor -v
```

All checkmarks should be green (except optional ones).

---

## Step 1: Initialize Flutter Project

### Option A: New Project
```bash
# Create new Flutter project
flutter create --org com.ephenotes --project-name ephenotes .

# Or if creating in new directory
flutter create --org com.ephenotes ephenotes
cd ephenotes
```

### Option B: Existing Directory
```bash
# If you're already in /home/jonas/ephenotes
flutter create --org com.ephenotes --project-name ephenotes .
```

This creates:
- `lib/` - Dart source code
- `android/` - Android platform code
- `ios/` - iOS platform code
- `test/` - Test files
- `pubspec.yaml` - Dependencies

---

## Step 2: Update pubspec.yaml

Replace the contents of `pubspec.yaml`:

```yaml
name: ephenotes
description: A modern, user-friendly virtual post-it notes app
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: ">=3.16.0"

dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  path_provider: ^2.1.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.18.0

  # UI Components
  flutter_slidable: ^3.0.0

  # Dependency Injection
  get_it: ^7.6.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Linting
  flutter_lints: ^3.0.0

  # Testing
  bloc_test: ^9.1.0
  mocktail: ^1.0.0

  # Code Generation
  hive_generator: ^2.0.0
  build_runner: ^2.4.0

flutter:
  uses-material-design: true

  # Uncomment to add assets later
  # assets:
  #   - assets/images/
```

### Install Dependencies

```bash
flutter pub get
```

---

## Step 3: Create Folder Structure

Create the project structure as defined in SPEC.md:

```bash
# Core directories
mkdir -p lib/core/constants
mkdir -p lib/core/theme
mkdir -p lib/core/utils
mkdir -p lib/core/extensions

# Data layer
mkdir -p lib/data/models
mkdir -p lib/data/repositories
mkdir -p lib/data/datasources/local
mkdir -p lib/data/datasources/hive_adapters

# Domain layer
mkdir -p lib/domain/usecases

# Presentation layer
mkdir -p lib/presentation/bloc/notes
mkdir -p lib/presentation/bloc/settings
mkdir -p lib/presentation/bloc/search
mkdir -p lib/presentation/screens
mkdir -p lib/presentation/widgets

# Test directories
mkdir -p test/unit
mkdir -p test/widget
mkdir -p test/integration
```

---

## Step 4: Create Data Models

### 4.1 Create Note Model

Create `lib/data/models/note.dart`:

```dart
import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

part 'note.g.dart';

@HiveType(typeId: 0)
class Note extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String content;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final NoteColor color;

  @HiveField(5)
  final NotePriority priority;

  @HiveField(6)
  final IconCategory? iconCategory;

  @HiveField(7)
  final bool isPinned;

  @HiveField(8)
  final bool isArchived;

  @HiveField(9)
  final int manualOrder;

  @HiveField(10)
  final bool isBold;

  @HiveField(11)
  final bool isItalic;

  @HiveField(12)
  final bool isUnderlined;

  @HiveField(13)
  final FontSize fontSize;

  @HiveField(14)
  final ListType listType;

  const Note({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.color = NoteColor.classicYellow,
    this.priority = NotePriority.medium,
    this.iconCategory,
    this.isPinned = false,
    this.isArchived = false,
    this.manualOrder = 0,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderlined = false,
    this.fontSize = FontSize.medium,
    this.listType = ListType.none,
  });

  Note copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteColor? color,
    NotePriority? priority,
    IconCategory? iconCategory,
    bool? isPinned,
    bool? isArchived,
    int? manualOrder,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    FontSize? fontSize,
    ListType? listType,
  }) {
    return Note(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      color: color ?? this.color,
      priority: priority ?? this.priority,
      iconCategory: iconCategory ?? this.iconCategory,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      manualOrder: manualOrder ?? this.manualOrder,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      fontSize: fontSize ?? this.fontSize,
      listType: listType ?? this.listType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        createdAt,
        updatedAt,
        color,
        priority,
        iconCategory,
        isPinned,
        isArchived,
        manualOrder,
        isBold,
        isItalic,
        isUnderlined,
        fontSize,
        listType,
      ];
}

@HiveType(typeId: 1)
enum NoteColor {
  @HiveField(0)
  classicYellow,
  @HiveField(1)
  coralPink,
  @HiveField(2)
  skyBlue,
  @HiveField(3)
  mintGreen,
  @HiveField(4)
  lavender,
  @HiveField(5)
  peach,
  @HiveField(6)
  teal,
  @HiveField(7)
  lightGray,
  @HiveField(8)
  lemon,
  @HiveField(9)
  rose,
}

@HiveType(typeId: 2)
enum NotePriority {
  @HiveField(0)
  high,
  @HiveField(1)
  medium,
  @HiveField(2)
  low,
}

@HiveType(typeId: 3)
enum IconCategory {
  @HiveField(0)
  work,
  @HiveField(1)
  personal,
  @HiveField(2)
  shopping,
  @HiveField(3)
  health,
  @HiveField(4)
  finance,
  @HiveField(5)
  important,
  @HiveField(6)
  ideas,
}

@HiveType(typeId: 4)
enum FontSize {
  @HiveField(0)
  small,
  @HiveField(1)
  medium,
  @HiveField(2)
  large,
}

@HiveType(typeId: 5)
enum ListType {
  @HiveField(0)
  none,
  @HiveField(1)
  bullets,
  @HiveField(2)
  checkboxes,
}
```

### 4.2 Generate Hive Adapters

Run the code generator:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This creates `note.g.dart` with Hive adapters.

---

## Step 5: Setup Dependency Injection

Create `lib/injection.dart`:

```dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/notes/notes_bloc.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> setupDependencyInjection() async {
  // Register data sources
  getIt.registerLazySingleton<NoteLocalDataSource>(
    () => HiveNoteDataSource(
      notesBox: Hive.box<Note>('notes'),
    ),
  );

  // Register repositories
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      dataSource: getIt<NoteLocalDataSource>(),
    ),
  );

  // Register BLoCs (as factories for multiple instances)
  getIt.registerFactory<NotesBloc>(
    () => NotesBloc(
      repository: getIt<NoteRepository>(),
    ),
  );

  // Future: Add more BLoCs here
  // getIt.registerFactory<SearchBloc>(() => SearchBloc(...));
  // getIt.registerFactory<SettingsBloc>(() => SettingsBloc(...));
}
```

---

## Step 6: Initialize Hive

Create or update `lib/main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/injection.dart';
import 'package:ephenotes/app.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive with Flutter support
  await Hive.initFlutter();

  // Register all Hive type adapters
  Hive.registerAdapter(NoteAdapter());
  Hive.registerAdapter(NoteColorAdapter());
  Hive.registerAdapter(NotePriorityAdapter());
  Hive.registerAdapter(IconCategoryAdapter());
  Hive.registerAdapter(FontSizeAdapter());
  Hive.registerAdapter(ListTypeAdapter());

  // Open Hive boxes
  await Hive.openBox<Note>('notes');
  await Hive.openBox('settings');

  // Setup dependency injection
  await setupDependencyInjection();

  // Run the app
  runApp(const ephenotesApp());
}
```

---

## Step 7: Create App Widget

Create `lib/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/core/theme/app_theme.dart';
import 'package:ephenotes/presentation/screens/main_screen.dart';
import 'package:ephenotes/presentation/bloc/notes/notes_bloc.dart';
import 'package:ephenotes/injection.dart';

class ephenotesApp extends StatelessWidget {
  const ephenotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ephenotes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Follow system setting
      home: BlocProvider(
        create: (context) => getIt<NotesBloc>()..add(const LoadNotesStarted()),
        child: const MainScreen(),
      ),
    );
  }
}
```

---

## Step 8: Create Theme

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Prevent instantiation
  AppTheme._();

  /// Light theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFF59D), // Classic yellow
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      floatingActionButtonTheme: const FloatingActionButtonTheme Data(
        backgroundColor: Color(0xFFFFF59D),
        foregroundColor: Colors.black87,
      ),
    );
  }

  /// Dark theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFE082), // Adjusted for dark mode
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF121212),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFFFFE082),
        foregroundColor: Colors.black87,
      ),
    );
  }
}
```

---

## Step 9: Create Placeholder Screens

Create `lib/presentation/screens/main_screen.dart`:

```dart
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ephenotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () {
              // TODO: Navigate to archive
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show menu
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to ephenotes!\n\nTap + to create your first note',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create note
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

---

## Step 10: Run the App

### iOS
```bash
flutter run -d ios
```

### Android
```bash
flutter run -d android
```

### List Available Devices
```bash
flutter devices
```

You should see the app launch with a blank screen and a "+" button!

---

## Step 11: Verify Setup

### Check for Errors
```bash
# Run analyzer
flutter analyze

# Should show no issues
```

### Run Tests (will be empty for now)
```bash
flutter test
```

---

## Next Steps

Now that your project is initialized, you can start implementing features:

1. **Use AI Skills**:
   ```
   /new-feature        # Implement features from SPEC.md
   /new-bloc           # Create BLoCs as needed
   /test-all           # Run tests
   ```

2. **Implement Features in Order**:
   - Note CRUD operations (create, read, update, delete)
   - Archive with undo
   - Search functionality
   - Pin/unpin notes
   - Drag-and-drop reordering
   - Color and icon categorization
   - Text formatting
   - Dark mode refinement

3. **Follow TDD Workflow**:
   - Write tests first (Red)
   - Implement feature (Green)
   - Refactor (Refactor)
   - All quality gates must pass

---

## Troubleshooting

### Issue: "Command not found: flutter"
**Solution**: Add Flutter to PATH:
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: Hive generator not working
**Solution**: Clean and rebuild:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: iOS build fails
**Solution**: Update CocoaPods:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
```

### Issue: Android build fails
**Solution**: Invalidate caches:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### Issue: "get_it not found"
**Solution**: Ensure dependency injection is set up:
```bash
flutter pub get
# Check that lib/injection.dart exists
```

---

## Verification Checklist

Before starting feature development, verify:

- ✅ Flutter project created
- ✅ All dependencies installed (`flutter pub get`)
- ✅ Folder structure created
- ✅ Note model created with Hive annotations
- ✅ Hive adapters generated (`.g.dart` files exist)
- ✅ Dependency injection configured
- ✅ Hive initialized in main.dart
- ✅ App widget created
- ✅ Theme configured
- ✅ Placeholder main screen created
- ✅ App runs on iOS
- ✅ App runs on Android
- ✅ No analyzer errors (`flutter analyze`)

---

**You're all set! Start building features with `/new-feature`** 🚀

For detailed feature specifications, see [SPEC.md](SPEC.md).
For AI development workflows, see [AGENTS.md](AGENTS.md).
