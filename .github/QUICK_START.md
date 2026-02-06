# CI/CD Quick Start Guide

## 🚀 Quick Reference

### Run Tests Locally

```bash
# All tests
flutter test

# Specific test suites
flutter test test/unit/              # Unit tests
flutter test test/widget/            # Widget tests
flutter test test/property/          # Property-based tests
flutter test test/integration/       # Integration tests
flutter test test/accessibility/     # Accessibility tests
flutter test test/performance/       # Performance tests

# With coverage
flutter test --coverage

# Single test file
flutter test test/unit/note_repository_test.dart
```

### Code Quality Checks

```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Fix formatting
dart format --fix .
```

### Build Locally

```bash
# Android
flutter build appbundle --release

# iOS
flutter build ios --release

# Check build
flutter build appbundle --release --verbose
```

---

## 📋 Pre-Push Checklist

Before pushing code, ensure:

- [ ] All tests pass: `flutter test`
- [ ] Code is formatted: `dart format .`
- [ ] No analysis issues: `flutter analyze`
- [ ] Coverage is adequate: `flutter test --coverage`
- [ ] Property tests pass (may take longer)

---

## 🔄 Workflow Triggers

### Automatic Triggers

| Workflow | Trigger | When |
|----------|---------|------|
| Test CI | Push to `main`/`develop` | Every commit |
| Test CI | Pull Request to `main` | PR opened/updated |
| Build Android | Push to `main` | After tests pass |
| Build Android | Version tag `v*.*.*` | Release tagged |
| Build iOS | Push to `main` | After tests pass |
| Build iOS | Version tag `v*.*.*` | Release tagged |

### Manual Triggers

All workflows can be triggered manually:

1. Go to **Actions** tab on GitHub
2. Select workflow
3. Click **Run workflow**
4. Fill in inputs (if required)
5. Click **Run workflow**

---

## 🧪 Test Suite Overview

### Test Categories

| Category | Files | Purpose | Duration |
|----------|-------|---------|----------|
| Unit | 8 | Core logic testing | ~10s |
| Widget | 11 | UI component testing | ~30s |
| Property | 13 | Correctness properties | ~60s |
| Integration | 7 | End-to-end flows | ~45s |
| Accessibility | 2 | A11y compliance | ~15s |
| Performance | 1 | Performance validation | ~20s |

**Total:** 42 test files, 94+ test cases

### Property-Based Tests

Special tests that run 100+ random test cases per property:

1. **Note Content Integrity** - Max 140 characters
2. **Archive-Pin Relationship** - Mutual exclusivity
3. **Search Result Consistency** - Subset validation
4. **Timestamp Monotonicity** - Logical ordering
5. **Priority-Based Ordering** - Consistent sorting
6. **Data Persistence Integrity** - Save/load reliability

**Note:** Property tests take longer (~60s) due to 100+ iterations per property.

---

## 🏗️ Build Workflows

### Android Build

**Inputs:**
- `version` - Version number (e.g., 1.0.0)
- `build_number` - Build number (e.g., 1)

**Output:**
- `app-release.aab` - Signed Android App Bundle
- ProGuard mapping files

**Duration:** ~10-15 minutes

### iOS Build

**Inputs:**
- `version` - Version number (e.g., 1.0.0)
- `build_number` - Build number (e.g., 1)

**Output:**
- `Runner.ipa` - Signed iOS app
- dSYM debug symbols

**Duration:** ~20-30 minutes

---

## 📦 Artifacts

### Download Artifacts

1. Go to workflow run
2. Scroll to **Artifacts** section
3. Click artifact name to download

### Artifact Types

| Artifact | Contents | Retention |
|----------|----------|-----------|
| test-results | Coverage reports | 7 days |
| app-release-{version} | Android AAB | 30 days |
| mapping-{version} | ProGuard mapping | 90 days |
| ios-release-{version} | iOS IPA | 30 days |
| dsym-{version} | iOS debug symbols | 90 days |

---

## 🚨 Common Issues

### Tests Fail in CI

**Symptom:** Tests pass locally but fail in CI

**Fix:**
```bash
# Match CI environment
flutter clean
flutter pub get
flutter test
```

### Coverage Below Threshold

**Symptom:** CI fails with "coverage below 60%"

**Fix:**
1. Run `flutter test --coverage`
2. Check `coverage/lcov.info`
3. Add tests for uncovered code
4. Or remove dead code

### Build Signing Errors

**Symptom:** Android/iOS build fails with signing error

**Fix:**
1. Verify GitHub Secrets are set
2. Check certificate/keystore validity
3. Ensure Base64 encoding is correct

---

## 🔐 Required Secrets

### Android

- `ANDROID_KEYSTORE_BASE64` - Keystore file (Base64)
- `ANDROID_KEY_ALIAS` - Key alias
- `ANDROID_KEY_PASSWORD` - Key password
- `ANDROID_STORE_PASSWORD` - Store password

### iOS

- `IOS_CERTIFICATE_BASE64` - P12 certificate (Base64)
- `IOS_CERTIFICATE_PASSWORD` - Certificate password
- `IOS_PROVISIONING_PROFILE_BASE64` - Provisioning profile (Base64)
- `IOS_TEAM_ID` - Apple Team ID

### Optional

- `APP_STORE_CONNECT_API_KEY_BASE64` - App Store API key
- `APP_STORE_CONNECT_API_KEY_ID` - API key ID
- `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` - Play Console service account
- `SLACK_WEBHOOK_URL` - Slack notifications

---

## 📊 Monitoring

### Check Workflow Status

1. Go to **Actions** tab
2. View recent workflow runs
3. Click run for details
4. Review logs and artifacts

### Coverage Trends

- Download coverage artifacts
- Compare over time
- Aim for >60% minimum
- Target 80%+ for production

### Build Success Rate

- Monitor build failures
- Check for flaky tests
- Review error patterns
- Update dependencies regularly

---

## 🎯 Best Practices

### 1. Write Tests First
- Add tests for new features
- Update tests for bug fixes
- Maintain >60% coverage

### 2. Run Tests Locally
- Before committing
- Before pushing
- Before creating PR

### 3. Keep CI Green
- Fix failing tests immediately
- Don't merge with failing CI
- Monitor workflow runs

### 4. Version Properly
- Use semantic versioning
- Tag releases: `v1.0.0`
- Update version in `pubspec.yaml`

### 5. Review Artifacts
- Download and test builds
- Verify signing works
- Test on real devices

---

## 🔗 Quick Links

- [Full CI/CD Documentation](CI_CD_SETUP.md)
- [Test Workflows](.github/workflows/test.yml)
- [Build Workflows](.github/workflows/)
- [GitHub Actions](../../actions)
- [Coverage Reports](../../actions/workflows/test.yml)

---

## 💡 Tips

### Speed Up Local Testing

```bash
# Run only changed tests
flutter test --coverage --reporter expanded

# Skip slow tests
flutter test --exclude-tags=slow

# Run in parallel (if configured)
flutter test --concurrency=4
```

### Debug CI Failures

```bash
# Enable verbose logging
flutter test --verbose

# Run specific failing test
flutter test test/path/to/failing_test.dart

# Check Flutter doctor
flutter doctor -v
```

### Optimize Build Times

- Use caching (already configured)
- Keep dependencies updated
- Remove unused dependencies
- Clean build occasionally

---

**Last Updated:** 2026-02-04

For detailed information, see [CI_CD_SETUP.md](CI_CD_SETUP.md)
