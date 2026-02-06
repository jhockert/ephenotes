# Deployment Scripts Documentation

## Overview

This directory contains automation scripts for version management, release notes generation, and deployment workflows.

---

## Scripts

### 1. version_manager.sh

**Purpose:** Automate version updates across all platform files

**Usage:**
```bash
# Bump version
./scripts/version_manager.sh bump [major|minor|patch]

# Set specific version
./scripts/version_manager.sh set <version> [build_number]

# Check current version
./scripts/version_manager.sh current

# Help
./scripts/version_manager.sh help
```

**Examples:**
```bash
# Bump patch version (1.0.0 → 1.0.1)
./scripts/version_manager.sh bump patch

# Bump minor version (1.0.0 → 1.1.0)
./scripts/version_manager.sh bump minor

# Set version to 2.0.0 with build 1
./scripts/version_manager.sh set 2.0.0 1
```

**What it updates:**
- `pubspec.yaml` - Flutter version
- `android/app/build.gradle.kts` - Android version
- `ios/Runner/Info.plist` - iOS version
- `CHANGELOG.md` - Changelog entry

---

### 2. generate_release_notes.sh

**Purpose:** Generate release notes from git commits

**Usage:**
```bash
# Generate full release notes
./scripts/generate_release_notes.sh full <from_tag> [to_tag] [output_file]

# Generate store-specific release notes
./scripts/generate_release_notes.sh store <from_tag> [to_tag] [store]

# Help
./scripts/generate_release_notes.sh help
```

**Examples:**
```bash
# Generate full release notes
./scripts/generate_release_notes.sh full v1.0.0 v1.1.0

# Generate for both stores
./scripts/generate_release_notes.sh store v1.0.0 HEAD both

# Generate for App Store only
./scripts/generate_release_notes.sh store v1.0.0 HEAD appstore

# Generate for Play Store only
./scripts/generate_release_notes.sh store v1.0.0 HEAD playstore
```

**Commit Format:**

The script uses conventional commit format:

| Prefix | Category | Example |
|--------|----------|---------|
| `feat:` | New Features | `feat: add dark mode` |
| `fix:` | Bug Fixes | `fix: resolve crash` |
| `perf:` | Performance | `perf: optimize search` |
| `refactor:` | Refactoring | `refactor: simplify code` |
| `docs:` | Documentation | `docs: update README` |
| `test:` | Tests | `test: add unit tests` |
| `chore:` | Chores | `chore: update deps` |

**Output:**
- Full notes: `RELEASE_NOTES.md` (or custom file)
- Store notes: `ios/AppStore/release_notes.txt` and/or `android/PlayStore/release_notes.txt`

---

### 3. run_ci_tests.sh

**Purpose:** Run all tests locally (matches CI environment)

**Usage:**
```bash
./scripts/run_ci_tests.sh
```

**What it runs:**
- Code analysis (`flutter analyze`)
- Code formatting check (`dart format`)
- Unit tests
- Widget tests
- Property-based tests
- Integration tests
- Accessibility tests
- Performance tests
- Coverage report

---

### 4. run_ci_tests.ps1

**Purpose:** Windows version of test runner

**Usage:**
```powershell
.\scripts\run_ci_tests.ps1
```

Same functionality as `run_ci_tests.sh` but for Windows/PowerShell.

---

## Workflow Integration

### Typical Release Workflow

```bash
# 1. Update version
./scripts/version_manager.sh bump minor

# 2. Generate release notes
./scripts/generate_release_notes.sh store $(git describe --tags --abbrev=0) HEAD both

# 3. Run tests
./scripts/run_ci_tests.sh

# 4. Commit changes
git add .
git commit -m "Release version $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"

# 5. Create tag
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
git tag -a "v$VERSION" -m "Release version $VERSION"

# 6. Push
git push && git push --tags

# 7. Deploy via GitHub Actions
# Go to Actions > Deploy to App Stores > Run workflow
```

---

## Script Requirements

### System Requirements

- **OS:** Linux, macOS, or WSL (Windows)
- **Shell:** Bash 4.0+
- **Tools:**
  - `git` - Version control
  - `sed` - Text processing
  - `grep` - Pattern matching
  - `base64` - Encoding/decoding
  - `/usr/libexec/PlistBuddy` - iOS plist editing (macOS only)

### Flutter Requirements

- Flutter 3.x+
- Dart 3.0+
- All dependencies installed (`flutter pub get`)

---

## Troubleshooting

### Permission Denied

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Or run with bash
bash scripts/version_manager.sh bump patch
```

### PlistBuddy Not Found (Linux/WSL)

The iOS version update requires macOS. On Linux/WSL:
- iOS version updates will be skipped
- Use GitHub Actions for iOS builds (runs on macOS)

### Git Tag Not Found

```bash
# Create initial tag if none exists
git tag -a v0.1.0 -m "Initial version"
git push --tags

# Then run release notes script
./scripts/generate_release_notes.sh store v0.1.0 HEAD both
```

### Version Format Error

Ensure version follows semantic versioning (X.Y.Z):
```bash
# ✅ Valid
./scripts/version_manager.sh set 1.0.0

# ❌ Invalid
./scripts/version_manager.sh set 1.0
./scripts/version_manager.sh set v1.0.0
```

---

## Best Practices

### 1. Version Management

- ✅ Use semantic versioning
- ✅ Bump patch for bug fixes
- ✅ Bump minor for new features
- ✅ Bump major for breaking changes
- ✅ Always increment build number

### 2. Release Notes

- ✅ Use conventional commit format
- ✅ Write clear, user-friendly messages
- ✅ Keep notes concise (under 4000 chars)
- ✅ Review generated notes before deployment

### 3. Testing

- ✅ Run tests before committing
- ✅ Fix all failing tests
- ✅ Maintain >60% coverage
- ✅ Test on physical devices

### 4. Git Workflow

- ✅ Commit version changes separately
- ✅ Tag releases with version number
- ✅ Push tags to trigger builds
- ✅ Keep commit history clean

---

## Examples

### Complete Release Example

```bash
# Start new release
echo "Starting release process..."

# 1. Ensure clean working directory
if [[ -n $(git status -s) ]]; then
  echo "Error: Working directory not clean"
  exit 1
fi

# 2. Update version
./scripts/version_manager.sh bump minor
VERSION=$(grep '^version:' pubspec.yaml | cut -d' ' -f2 | cut -d'+' -f1)
echo "Version: $VERSION"

# 3. Generate release notes
LAST_TAG=$(git describe --tags --abbrev=0)
./scripts/generate_release_notes.sh store $LAST_TAG HEAD both
./scripts/generate_release_notes.sh full $LAST_TAG HEAD "RELEASE_NOTES_$VERSION.md"

# 4. Run tests
./scripts/run_ci_tests.sh
if [ $? -ne 0 ]; then
  echo "Error: Tests failed"
  exit 1
fi

# 5. Commit and tag
git add .
git commit -m "Release version $VERSION"
git tag -a "v$VERSION" -m "Release version $VERSION"

# 6. Push
git push && git push --tags

echo "✅ Release $VERSION ready for deployment"
echo "Go to GitHub Actions to deploy"
```

### Hotfix Release Example

```bash
# Quick hotfix release
./scripts/version_manager.sh bump patch
./scripts/generate_release_notes.sh store $(git describe --tags --abbrev=0) HEAD both
git add . && git commit -m "Hotfix: $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"
git push

# Deploy immediately via GitHub Actions
```

---

## Additional Resources

- [Deployment Automation Guide](../.github/DEPLOYMENT_AUTOMATION.md)
- [CI/CD Setup Guide](../.github/CI_CD_SETUP.md)
- [Quick Reference](../.github/DEPLOYMENT_QUICK_REFERENCE.md)

---

**Last Updated:** 2026-02-04  
**Maintained by:** ephenotes Team

