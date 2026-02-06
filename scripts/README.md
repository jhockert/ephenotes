# Test Scripts

This directory contains scripts for running the CI/CD test pipeline locally.

## Available Scripts

### `run_ci_tests.sh` (Linux/macOS)

Bash script that runs the complete CI test pipeline locally.

**Usage:**
```bash
# Make executable (first time only)
chmod +x scripts/run_ci_tests.sh

# Run all tests
./scripts/run_ci_tests.sh
```

### `run_ci_tests.ps1` (Windows)

PowerShell script that runs the complete CI test pipeline locally.

**Usage:**
```powershell
# Run all tests
.\scripts\run_ci_tests.ps1

# Or with execution policy
powershell -ExecutionPolicy Bypass -File .\scripts\run_ci_tests.ps1
```

## What These Scripts Do

1. **Check Flutter Installation** - Verify Flutter is available
2. **Install Dependencies** - Run `flutter pub get`
3. **Code Analysis** - Run `flutter analyze`
4. **Code Formatting** - Check with `dart format`
5. **Run Test Suites:**
   - Unit Tests (`test/unit/`)
   - Widget Tests (`test/widget/`)
   - Property-Based Tests (`test/property/`)
   - Integration Tests (`test/integration/`)
   - Accessibility Tests (`test/accessibility/`)
   - Performance Tests (`test/performance/`)
6. **Generate Coverage** - Create coverage report
7. **Check Coverage Threshold** - Ensure ≥60% coverage
8. **Print Summary** - Show test results

## Test Suites

| Suite | Location | Purpose | Duration |
|-------|----------|---------|----------|
| Unit | `test/unit/` | Core logic | ~10s |
| Widget | `test/widget/` | UI components | ~30s |
| Property | `test/property/` | Correctness properties | ~60s |
| Integration | `test/integration/` | End-to-end flows | ~45s |
| Accessibility | `test/accessibility/` | A11y compliance | ~15s |
| Performance | `test/performance/` | Performance validation | ~20s |

**Total Duration:** ~3-4 minutes

## Exit Codes

- `0` - All tests passed
- `1` - One or more tests failed

## Requirements

### All Platforms
- Flutter 3.16+ installed
- Dart 3.0+ installed
- All dependencies in `pubspec.yaml`

### Linux/macOS (for coverage threshold)
- `lcov` installed (optional)
  ```bash
  # Ubuntu/Debian
  sudo apt-get install lcov
  
  # macOS
  brew install lcov
  ```

### Windows (for coverage threshold)
- `lcov` via Chocolatey (optional)
  ```powershell
  choco install lcov
  ```

## Troubleshooting

### Script Won't Execute (Linux/macOS)

**Problem:** Permission denied

**Solution:**
```bash
chmod +x scripts/run_ci_tests.sh
```

### Script Won't Execute (Windows)

**Problem:** Execution policy restriction

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Or run with bypass:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run_ci_tests.ps1
```

### Tests Fail Locally

**Problem:** Tests pass in IDE but fail in script

**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter test
```

### Coverage Threshold Check Skipped

**Problem:** lcov not installed

**Solution:**
- Install lcov (see Requirements above)
- Or ignore - coverage report still generated in `coverage/lcov.info`

## CI/CD Integration

These scripts mirror the GitHub Actions workflows:

- **Local:** `./scripts/run_ci_tests.sh`
- **CI:** `.github/workflows/test.yml`

Both run the same test suites in the same order.

## Quick Commands

```bash
# Run all tests locally
./scripts/run_ci_tests.sh

# Run specific test suite
flutter test test/unit/

# Run with coverage
flutter test --coverage

# Check formatting
dart format .

# Fix formatting
dart format --fix .

# Analyze code
flutter analyze
```

## See Also

- [CI/CD Setup Guide](../.github/CI_CD_SETUP.md)
- [Quick Start Guide](../.github/QUICK_START.md)
- [Test Workflows](../.github/workflows/)

---

**Last Updated:** 2026-02-04
