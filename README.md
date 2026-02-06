# ephenotes

**Version 0.2.0** | **94 Tests Passing**

A virtual post-it notes app for iOS and Android. Quick notes with a 140-character limit, color coding, priorities, and search. Local storage only, no backend, no tracking.

> **AI agents**: Read [CLAUDE.md](CLAUDE.md) for project context and development guidelines.

---

## Features

**Implemented (v0.2.0):**
- Quick note creation with 140-character limit and real-time counter
- 10 color options for visual organization
- 7 icon categories (work, personal, shopping, health, finance, important, ideas)
- Real-time search across content and categories
- Pin important notes to the top
- Swipe-to-archive with 3-second undo
- Priority levels (high, medium, low) with color badges
- Text formatting (bold, italic, underline, font sizes, bullet lists, checkboxes)
- Gesture controls (swipe, long-press, tap)

**Coming next:**
- Drag-and-drop reordering
- Smart grouping by age (11+ notes)
- Dark mode

See [STATUS.md](STATUS.md) for full implementation status.

---

## Tech Stack

- **Framework**: Flutter (Dart)
- **Architecture**: BLoC + Clean Architecture
- **Storage**: Hive (local)
- **Platforms**: iOS 13.0+ / Android 6.0+

---

## Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Xcode 15+ (iOS) or Android Studio

### Setup

```bash
git clone https://github.com/yourusername/ephenotes.git
cd ephenotes
flutter pub get
flutter pub run build_runner build
flutter run
```

---

## Development

### Commands

```bash
flutter test                    # Run all tests (94)
flutter test --coverage         # With coverage report
flutter analyze                 # Static analysis
dart format lib/ test/          # Format code
flutter build ios --release     # iOS release build
flutter build appbundle --release  # Android release build
```

### Testing

94 tests across 6 files:
- Unit tests (61): BLoC, repository, datasource
- Widget tests (33): notes list, search, archive screens

Coverage requirements: 80% overall, 90% BLoC, 85% repositories.

---

## Architecture

```
UI -> BLoC (Events) -> Repository -> DataSource -> Hive
UI <- BLoC (States) <- Repository <- DataSource <- Hive
```

```
lib/
  data/          # Models, repositories, datasources
  presentation/  # BLoC, screens, widgets
  injection.dart # Dependency injection (GetIt)
  main.dart
```

---

## Roadmap

- [x] **v0.1.0** - Data layer (models, repository, BLoC, 61 unit tests)
- [x] **v0.2.0** - UI implementation (screens, widgets, 33 widget tests)
- [ ] **Phase 2 Extended** - Drag-and-drop, grouping, dark mode, integration tests
- [ ] **v1.0.0** - App store submission, CI/CD, accessibility audit
- [ ] **v2.0.0** - Cloud sync, export/import, templates, voice-to-text

---

## Documentation

| Document | Purpose |
|----------|---------|
| [CLAUDE.md](CLAUDE.md) | AI agent entry point |
| [STATUS.md](STATUS.md) | Implementation status |
| [CHANGELOG.md](CHANGELOG.md) | Version history |
| [specs/SPEC.md](specs/SPEC.md) | Technical specification |
| [specs/AGENTS.md](specs/AGENTS.md) | Development workflows |
| [specs/DECISIONS.md](specs/DECISIONS.md) | Design decisions |
| [specs/REQUIREMENTS.md](specs/REQUIREMENTS.md) | Formal requirements |
| [MANIFEST.md](MANIFEST.md) | Full documentation index |

---

## License

[Add your license here]
