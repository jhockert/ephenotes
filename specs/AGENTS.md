# ephenotes - AI Agent Development Guide

## Overview

This document defines the AI agent workflows, responsibilities, and quality standards for developing the ephenotes mobile application. All development work is performed by AI agents with comprehensive testing and documentation at each commit.

---

## Core Principles

### 1. Spec-Driven Development
- **All development must align with [SPEC.md](SPEC.md)**
- Agents must read and understand SPEC.md before starting any task
- Deviations from spec require explicit justification and documentation
- When unclear, ask for clarification rather than making assumptions

### 2. Test-First Approach
- Write tests before implementation code
- Minimum 80% code coverage required
- All tests must pass before committing
- Integration tests for critical user flows

### 3. Documentation Requirements
- Every public API must have dartdoc comments
- Complex logic requires inline explanatory comments
- README.md kept current with setup/build instructions
- CHANGELOG.md updated with every version

### 4. Quality Gates
- No commit without passing all checks
- Code must be formatted and linted
- Manual verification on both iOS and Android
- Dark mode tested for all UI changes

---

## Agent Roles & Responsibilities

### 1. Architecture Agent
**Role**: Design and maintain application structure

**Responsibilities**:
- Set up initial project structure following SPEC.md file layout
- Configure Flutter project for iOS and Android
- Implement BLoC architecture pattern
- Set up dependency injection
- Configure Hive/sqflite for local storage
- Define data models and adapters
- Ensure clean architecture principles

**Deliverables**:
- Project scaffold with proper folder structure (see [SETUP.md](SETUP.md))
- `pubspec.yaml` with all required dependencies
- Core models, repository interfaces, and Hive adapters (see [SPEC.md](SPEC.md) for data models)
- Dependency injection setup

**Quality Checks**:
- Project builds successfully on both platforms
- No circular dependencies
- All imports properly organized
- Architecture decisions documented

---

### 2. Feature Implementation Agent
**Role**: Implement features defined in SPEC.md

**Responsibilities**:
- Implement BLoC logic (events, states, bloc classes)
- Create use cases for business logic
- Implement repositories and data sources
- Build UI screens and widgets
- Implement animations and gestures
- Integrate all components

**Workflow**:
1. Read feature specification from SPEC.md
2. Create/update unit tests for the feature
3. Implement BLoC (events → states → bloc)
4. Implement data layer (repository → datasource)
5. Create widget tests
6. Build UI components
7. Integrate all layers
8. Run all tests and fix failures
9. Manual testing on both platforms
10. Document any deviations or decisions
11. Commit with descriptive message

**References**:
- See [SPEC.md](SPEC.md) for all feature specifications
- See [STATUS.md](../STATUS.md) for which features are already implemented

**Quality Checks**:
- Tests written before implementation
- All tests passing (unit + widget + integration)
- UI matches SPEC.md designs
- No performance regressions
- Accessibility requirements met
- Works in both light and dark mode

---

### 3. UI/UX Implementation Agent
**Role**: Build beautiful, functional user interfaces

**Responsibilities**:
- Implement screens per SPEC.md UI specifications
- Create reusable widget components
- Implement animations and transitions
- Ensure responsive layouts
- Apply theme and styling
- Implement gestures (swipe, long-press, drag)
- Accessibility features

**References**:
- See [SPEC.md](SPEC.md) for UI component list, animation specs, and design system
- See [STATUS.md](../STATUS.md) for which components are already built

**Quality Checks**:
- Pixel-perfect implementation of designs
- 60 FPS animations verified
- Touch targets ≥ 44x44pt
- Contrast ratios meet WCAG AA
- VoiceOver/TalkBack labels present
- Responsive on different screen sizes
- Dark mode properly styled

---

### 4. Testing Agent
**Role**: Ensure comprehensive test coverage and quality

**Responsibilities**:
- Write unit tests for all business logic
- Write widget tests for UI components
- Write integration tests for user flows
- Maintain 80%+ code coverage
- Fix failing tests
- Performance testing
- Accessibility testing

**Test Categories**:

#### Unit Tests (`test/unit/`)
- **BLoC Logic**:
  - Test all events trigger correct state changes
  - Test edge cases and error handling
  - Mock dependencies (repositories)
- **Data Models**:
  - Serialization/deserialization
  - Validation logic
  - Model methods
- **Repositories**:
  - CRUD operations
  - Filtering and sorting
  - Search functionality
- **Use Cases**:
  - Business logic correctness
  - Input validation
  - Error handling

#### Widget Tests (`test/widget/`)
- Test UI components render correctly and respond to interactions
- See [SPEC.md](SPEC.md) for expected widget behaviors
- See [STATUS.md](../STATUS.md) for current test coverage

#### Integration Tests (`test/integration/`)
- End-to-end user flows
- See [features/](../features/) for Gherkin scenarios defining acceptance criteria
- See [BDD_IMPLEMENTATION.md](BDD_IMPLEMENTATION.md) for testing strategy

**Test Execution**:
```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/unit/notes_bloc_test.dart

# Run integration tests
flutter test integration_test/
```

**Coverage Requirements**:
- Overall: ≥ 80%
- BLoC classes: ≥ 90%
- Repositories: ≥ 85%
- Utils/Helpers: ≥ 80%
- UI widgets: ≥ 70% (focus on logic, not styling)

**Quality Checks**:
- All tests pass
- No flaky tests
- Tests are independent (no shared state)
- Tests are fast (unit tests < 100ms each)
- Mocks used appropriately
- Test names are descriptive
- Coverage reports generated

---

### 5. Code Quality Agent
**Role**: Maintain code standards and best practices

**Responsibilities**:
- Format code (`dart format`)
- Run linter (`flutter analyze`)
- Fix linting warnings/errors
- Ensure code follows Flutter/Dart conventions
- Remove dead code
- Optimize imports
- Check for performance issues
- Security review

**Code Standards**:

#### Naming Conventions
- **Classes**: PascalCase (`NoteCard`, `NotesBloc`)
- **Files**: snake_case (`note_card.dart`, `notes_bloc.dart`)
- **Variables**: camelCase (`noteContent`, `isPinned`)
- **Constants**: camelCase or SCREAMING_SNAKE_CASE for compile-time constants
- **Private members**: Leading underscore (`_privateMethod`)

#### File Organization
- Imports organized: dart → flutter → package → relative
- One widget per file (unless tightly coupled helper widgets)
- Max 300 lines per file (refactor if larger)
- Related files grouped in folders

#### Code Patterns
- Immutable data classes with copyWith
- Const constructors where possible
- Named parameters for 3+ arguments
- Early returns for guard clauses
- Null-safety best practices

#### Flutter Best Practices
- Use `const` widgets aggressively
- Extract repeated widgets to methods/classes
- Keys for list items in ReorderableList
- Dispose controllers in dispose()
- Use `Builder` or `LayoutBuilder` when needed
- Avoid deep widget trees (extract to methods/widgets)

**Pre-Commit Checks**:
```bash
# Format code
dart format lib/ test/

# Analyze code
flutter analyze

# Check for unused imports
dart fix --dry-run

# Apply automatic fixes
dart fix --apply
```

**Quality Checks**:
- Zero analyzer issues
- Code formatted consistently
- No TODOs or FIXME comments in production code
- No commented-out code
- No print statements (use logging)
- No hardcoded strings (use constants)
- Meaningful variable names

---

### 6. Documentation Agent
**Role**: Maintain comprehensive documentation

**Responsibilities**:
- Write dartdoc comments for public APIs
- Update README.md with setup instructions
- Maintain CHANGELOG.md
- Document architecture decisions
- Create code examples
- Keep SPEC.md aligned with implementation

**Documentation Requirements**:

#### README.md
- Project description
- Prerequisites (Flutter SDK version, etc.)
- Setup instructions
- Build commands (iOS & Android)
- Run commands
- Testing commands
- Folder structure overview
- Contributing guidelines (for future)

#### CHANGELOG.md
Follow [Keep a Changelog](https://keepachangelog.com/) format.
See [CHANGELOG.md](../CHANGELOG.md) for current version history.

#### Code Comments
- **Dartdoc** for all public classes, methods, parameters
- **Inline comments** for complex logic
- **No obvious comments** ("// increment counter" for `counter++`)
- **Why, not what**: Explain reasoning, not mechanics

Example:
```dart
/// Represents a virtual post-it note with content, styling, and metadata.
///
/// Example:
/// ```dart
/// final note = Note(id: uuid.v4(), content: 'Buy groceries');
/// ```
class Note {
  // ...
}
```

**Quality Checks**:
- All public APIs documented
- README.md has accurate setup steps
- CHANGELOG.md updated with version
- No broken documentation links
- Code examples compile and run

---

### 7. Platform Integration Agent
**Role**: Handle platform-specific concerns (iOS & Android)

**Responsibilities**:
- Configure iOS project (Info.plist, etc.)
- Configure Android project (AndroidManifest.xml, Gradle)
- Set up app icons and splash screens
- Handle platform-specific permissions
- Test on both platforms
- Handle platform-specific UI adaptations (if needed)
- Build and sign apps for release

**References**:
- See [SPEC.md](SPEC.md) for platform requirements (iOS 13.0+, Android 6.0+)
- See [DEPLOYMENT.md](DEPLOYMENT.md) for full deployment configuration
- See [SETUP.md](SETUP.md) for initial project setup

**Build Commands**:
```bash
# iOS
flutter build ios --release

# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Install on connected device
flutter install
```

**Quality Checks**:
- App runs on iOS simulator
- App runs on Android emulator
- App runs on physical iOS device
- App runs on physical Android device
- App icon displays correctly on both platforms
- Splash screen displays correctly
- Dark mode works on both platforms
- Orientation handling correct

---

### 8. Debugging & Bug Fix Agent
**Role**: Investigate and resolve issues

**Responsibilities**:
- Reproduce reported bugs
- Investigate root cause
- Write regression tests
- Implement fix
- Verify fix on both platforms
- Document bug and fix in commit message

**Debugging Workflow**:
1. **Reproduce**: Follow steps to reproduce bug
2. **Isolate**: Narrow down the component/file
3. **Investigate**: Use debugger, logs, stack traces
4. **Test**: Write test that fails due to bug
5. **Fix**: Implement minimal fix
6. **Verify**: Test passes, bug no longer reproducible
7. **Regression Test**: Ensure fix doesn't break other features
8. **Document**: Clear commit message explaining bug and fix

**Debugging Tools**:
- Flutter DevTools
- Dart debugger in IDE
- `print()` for quick checks (remove before commit)
- `debugPrint()` for larger outputs
- `debugPaintSizeEnabled` for layout issues
- `debugPaintLayerBordersEnabled` for rendering

**Bug Report Template**:
```markdown
## Bug Description
[Clear description of unexpected behavior]

## Steps to Reproduce
1. Step one
2. Step two
3. ...

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Environment
- Platform: iOS/Android
- Device: [Device name/emulator]
- Flutter version: [version]
- App version: [version]

## Stack Trace / Logs
[If applicable]

## Screenshots
[If applicable]
```

**Quality Checks**:
- Bug fully understood before fixing
- Regression test added
- Fix verified on both platforms
- No new bugs introduced
- Performance not degraded

---

## Workflow: Feature Development

### Step-by-Step Process

#### 1. Planning Phase
```
Agent: Architecture or Feature Implementation
Duration: 15-30 minutes
```
- Read SPEC.md for feature details
- Identify affected components
- List required tests
- Estimate complexity
- Create task breakdown

#### 2. Test Writing Phase
```
Agent: Testing Agent
Duration: 30-60 minutes per feature
```
- Write unit tests for business logic
- Write widget tests for UI
- Write integration tests for flows
- All tests should FAIL initially (Red phase of TDD)

#### 3. Implementation Phase
```
Agent: Feature Implementation Agent
Duration: 1-3 hours per feature
```
- Implement data models
- Implement BLoC (events, states, bloc)
- Implement repository/datasource
- Implement UI components
- Wire everything together
- Run tests frequently

#### 4. UI Polish Phase
```
Agent: UI/UX Implementation Agent
Duration: 30-60 minutes
```
- Refine styling and spacing
- Implement animations
- Test responsiveness
- Verify dark mode
- Add accessibility labels

#### 5. Quality Assurance Phase
```
Agent: Code Quality Agent + Testing Agent
Duration: 20-30 minutes
```
- Run `flutter analyze`
- Run `dart format`
- Run all tests
- Check coverage report
- Manual testing on both platforms
- Performance profiling (if needed)

#### 6. Documentation Phase
```
Agent: Documentation Agent
Duration: 15-20 minutes
```
- Add dartdoc comments
- Update README if needed
- Update CHANGELOG.md
- Document any decisions or trade-offs

#### 7. Commit Phase
```
Agent: Any agent completing work
Duration: 5 minutes
```
- Stage files: `git add <files>`
- Commit with conventional commit message
- Example: `feat: implement note archiving with undo functionality`
- Push to repository

---

## Workflow: Bug Fix

#### 1. Reproduction
```
Agent: Debugging & Bug Fix Agent
Duration: 10-20 minutes
```
- Follow reproduction steps
- Confirm bug exists
- Note affected platforms

#### 2. Investigation
```
Agent: Debugging & Bug Fix Agent
Duration: 20-60 minutes
```
- Use debugger to trace issue
- Identify root cause
- Check if existing tests should have caught this

#### 3. Test Writing
```
Agent: Testing Agent
Duration: 15-30 minutes
```
- Write regression test that fails due to bug
- Run test to confirm failure

#### 4. Fix Implementation
```
Agent: Debugging & Bug Fix Agent
Duration: 15-60 minutes
```
- Implement minimal fix
- Run regression test until it passes
- Verify all other tests still pass

#### 5. Verification
```
Agent: Testing Agent
Duration: 15-30 minutes
```
- Manual testing on both platforms
- Verify fix works in all scenarios
- Check for side effects

#### 6. Commit
```
Agent: Debugging & Bug Fix Agent
Duration: 5 minutes
```
- Commit: `fix: resolve note deletion animation crash on iOS`
- Include issue reference if applicable

---

## Workflow: New Version Release

#### 1. Pre-Release Checks
```
All Agents: Collaborative
Duration: 1-2 hours
```
- **Testing Agent**:
  - All tests passing (unit, widget, integration)
  - Coverage ≥ 80%
  - Manual regression testing
- **Code Quality Agent**:
  - No analyzer warnings
  - Code formatted
  - No TODOs or debug code
- **Platform Integration Agent**:
  - Build successful on iOS
  - Build successful on Android
  - Test on physical devices
- **Documentation Agent**:
  - README.md current
  - CHANGELOG.md updated
  - All public APIs documented

#### 2. Version Bump
```
Agent: Documentation Agent
Duration: 10 minutes
```
- Update version in `pubspec.yaml`
- Follow semantic versioning (MAJOR.MINOR.PATCH)
- Example: `1.0.0` → `1.1.0` (new feature)

#### 3. Build Release
```
Agent: Platform Integration Agent
Duration: 20-30 minutes
```
- Build iOS release: `flutter build ios --release`
- Build Android release: `flutter build appbundle --release`
- Generate release notes from CHANGELOG.md

#### 4. Tag Release
```
Agent: Any agent
Duration: 5 minutes
```
```bash
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0
```

#### 5. Store Submission
```
Agent: Platform Integration Agent (manual step)
```
- Submit to App Store Connect (iOS)
- Submit to Google Play Console (Android)
- Include screenshots, description, keywords

---

## Quality Gates

### Gate 1: Code Compiles
- Project builds without errors on both platforms
- No compilation warnings
- All imports resolve

### Gate 2: Tests Pass
- All unit tests pass
- All widget tests pass
- All integration tests pass
- Coverage ≥ 80%

### Gate 3: Code Quality
- `flutter analyze` shows 0 issues
- Code is formatted (`dart format`)
- No debug code or print statements
- Follows naming conventions

### Gate 4: Manual Testing
- Feature works on iOS
- Feature works on Android
- Works in light mode
- Works in dark mode
- Accessibility labels present

### Gate 5: Documentation
- Public APIs have dartdoc comments
- README.md is current
- CHANGELOG.md updated
- Commit message follows conventions

### Gate 6: Performance
- No frame drops (60 FPS)
- App launches < 2 seconds
- No memory leaks
- Animations smooth

**ALL GATES MUST PASS BEFORE COMMIT**

---

## Commit Message Standards

### Format: Conventional Commits
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build, config, dependencies

### Scopes (Optional)
- `notes`: Note-related features
- `archive`: Archive functionality
- `search`: Search functionality
- `ui`: UI components
- `theme`: Theming and styling
- `storage`: Data persistence
- `bloc`: BLoC logic

### Examples
```bash
feat(notes): implement drag-and-drop reordering with sticking animation

Added ReorderableListView for manual note reordering. Implemented
custom animation for "sticking" effect when note is dropped. Persists
new order to local storage.

Closes #12

---

fix(archive): resolve undo snackbar not appearing after swipe delete

Snackbar was being dismissed by Navigator pop. Fixed by using
ScaffoldMessenger instead of context-based Scaffold.of().

---

test(search): add integration tests for search functionality

Added tests for:
- Real-time search filtering
- Search term highlighting
- No results state
- Search with special characters

---

docs: update README with build instructions for M1 Macs

Added specific instructions for running on Apple Silicon. Included
troubleshooting section for common CocoaPods issues.
```

---

## AI Agent Communication

### When Starting Work
```markdown
🤖 **Agent**: Feature Implementation Agent
📋 **Task**: Implement note pinning functionality
📄 **Reference**: SPEC.md sections 5 & 1.4
⏰ **Phase**: Planning → Test Writing → Implementation
```

### During Work
```markdown
✅ Unit tests written for pin/unpin logic
✅ BLoC events and states created
⚙️ Currently: Implementing UI for pinned notes section
```

### When Blocked
```markdown
⚠️ **Blocked**: Need clarification on pin icon placement
❓ **Question**: Should pin icon be in top-left or top-right of note card?
📄 **Reference**: SPEC.md shows top-right but mockups unclear
```

### When Completed
```markdown
✅ **Completed**: Note pinning functionality
📊 **Tests**: 15/15 passing, coverage: 87%
🔍 **Quality**: All gates passed
💾 **Commit**: feat(notes): implement pin/unpin functionality
📝 **Documentation**: Updated README and CHANGELOG
```

---

## Error Handling Standards

### User-Facing Errors
- Use `SnackBar` for transient messages
- Use `AlertDialog` for errors requiring acknowledgment
- Use inline error text for form validation
- Always provide actionable guidance

### Developer Errors
- Use assertions for internal contract violations
- Use custom exceptions for business logic errors
- Log errors appropriately (not with `print`)

See [SPEC.md](SPEC.md) for app-specific error scenarios and edge cases.

---

## Performance Considerations

### ListView Optimization
- Use `ListView.builder` for efficient rendering
- Implement proper `Key` for list items
- Avoid rebuilding entire list on single item change

### BLoC Best Practices
- Use `Equatable` for states to prevent unnecessary rebuilds
- Use `transformEvents` for debouncing search input
- Dispose BLoCs properly

### Animation Performance
- Use `const` constructors where possible
- Avoid `Opacity` widget (use `AnimatedOpacity`)
- Avoid `ClipRRect` in animations if possible
- Profile with `flutter run --profile`

### Hive Optimization
- Use lazy boxes for large datasets
- Index frequently queried fields
- Close boxes when not in use

---

## Accessibility Requirements

### Screen Reader Support
- All interactive widgets must have semantic labels
- Use `Semantics` widget when needed
- Buttons and taps need clear labels

```dart
IconButton(
  icon: Icon(Icons.add),
  onPressed: _createNote,
  tooltip: 'Create new note',
  // Automatic semantic label from tooltip
);

Semantics(
  label: 'Note: ${note.content}. Priority: ${note.priority}',
  child: NoteCard(note: note),
);
```

### Visual Accessibility
- Contrast ratios: 4.5:1 (normal text), 3:1 (large text)
- Touch targets: Minimum 44x44pt
- Support system font scaling
- Color is not sole indicator (use icons + colors)

### Testing Accessibility
```bash
# Enable semantic debugger
flutter run --debug
# Press 'S' to toggle semantics tree
```

---

## Security Considerations

See [SECURITY.md](SECURITY.md) for full security policy, audit checklists, and threat model.

Key rules for development:
- No API keys or secrets in code
- Validate all user input
- Keep dependencies up to date (`pub outdated`)
- Audit new dependencies before adding

---

## Future Agent Roles (Post v1.0)

### Backend Integration Agent
- Set up Firebase or custom API
- Implement authentication
- Implement cloud sync
- Handle offline/online state

### Analytics Agent
- Integrate analytics (Firebase, Mixpanel)
- Define events and properties
- Create dashboards
- A/B testing implementation

### DevOps Agent
- CI/CD pipeline setup (GitHub Actions, Fastlane)
- Automated testing on PRs
- Automated builds
- Store submission automation

---

## Agent Collaboration Matrix

| Agent | Collaborates With | Handoff Point |
|-------|-------------------|---------------|
| Architecture | Feature Implementation | Project structure ready |
| Feature Implementation | UI/UX | Business logic complete |
| Feature Implementation | Testing | Code ready for testing |
| UI/UX | Testing | UI components built |
| Testing | Code Quality | All tests passing |
| Code Quality | Documentation | Code clean and formatted |
| Documentation | Platform Integration | Docs complete |
| Platform Integration | Release | Builds successful |

---

## Troubleshooting Guide

### Common Issues

#### Tests Failing
1. Check if SPEC.md alignment
2. Run `flutter pub get`
3. Clear build: `flutter clean && flutter pub get`
4. Check for async timing issues in tests
5. Verify mock data is correct

#### Build Failing
1. Run `flutter doctor`
2. Update Flutter: `flutter upgrade`
3. Clean project: `flutter clean`
4. Delete `pubspec.lock` and `flutter pub get`
5. Check platform-specific errors (iOS/Android)

#### Performance Issues
1. Run profiling: `flutter run --profile`
2. Use DevTools performance tab
3. Check for unnecessary rebuilds
4. Verify `const` constructors used
5. Check list rendering (use `ListView.builder`)

#### Platform-Specific Issues
1. **iOS**: Clean Xcode build folder
2. **iOS**: Update CocoaPods: `cd ios && pod update`
3. **Android**: Invalidate caches in Android Studio
4. **Android**: Check Gradle version compatibility

---

## Success Criteria

### For Each Feature
- ✅ Aligns with SPEC.md
- ✅ Tests written and passing (80%+ coverage)
- ✅ Works on iOS and Android
- ✅ Works in light and dark mode
- ✅ No analyzer warnings
- ✅ Properly documented
- ✅ Committed with conventional commit message

### For Each Version
- ✅ All features complete per version roadmap
- ✅ All quality gates passed
- ✅ Manual testing complete
- ✅ Performance benchmarks met
- ✅ CHANGELOG.md updated
- ✅ README.md current
- ✅ Builds successfully for both platforms

### For Project Completion (v1.0)
- ✅ All MVP features implemented (from SPEC.md)
- ✅ 80%+ overall test coverage
- ✅ No critical or high-priority bugs
- ✅ App Store and Play Store ready
- ✅ User documentation complete
- ✅ Performance targets met
- ✅ Accessibility requirements met

---

## Resources & References

### Flutter Documentation
- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Docs](https://dart.dev/guides)
- [BLoC Pattern](https://bloclibrary.dev/)
- [Flutter Testing](https://docs.flutter.dev/testing)

### Tools
- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Hive Database](https://docs.hivedb.dev/)
- [Conventional Commits](https://www.conventionalcommits.org/)

### Design
- [Material Design](https://m3.material.io/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [WCAG Accessibility](https://www.w3.org/WAI/WCAG21/quickref/)

---

**Document Version**: 1.0
**Last Updated**: 2026-02-03
**Status**: Active Development Guide

---

## Quick Reference: Agent Commands

```bash
# Architecture Setup
flutter create --org com.ephenotes ephenotes
cd ephenotes
flutter pub add flutter_bloc hive hive_flutter uuid intl
flutter pub add --dev bloc_test mocktail hive_generator build_runner

# Code Quality
dart format lib/ test/
flutter analyze
dart fix --dry-run

# Testing
flutter test
flutter test --coverage
flutter test test/unit/notes_bloc_test.dart

# Running
flutter run
flutter run --release
flutter run --profile

# Building
flutter build apk --release
flutter build appbundle --release
flutter build ios --release

# Platform Testing
flutter devices
flutter run -d <device-id>

# Debugging
flutter clean
flutter doctor -v
flutter logs
```

---

## Remember

🎯 **Always refer to SPEC.md before starting work**
✅ **Tests before implementation (TDD)**
📝 **Document as you code**
🧪 **All tests must pass before commit**
🎨 **Test on both platforms**
🌙 **Verify dark mode for all UI changes**
♿ **Include accessibility from the start**
🚀 **Commit often with descriptive messages**

Happy coding! 🤖✨
