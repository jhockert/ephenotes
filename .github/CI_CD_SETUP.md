# CI/CD Pipeline Documentation

## Overview

This document describes the automated testing and deployment pipeline for ephenotes mobile app. The pipeline is built using GitHub Actions and includes comprehensive testing, building, and deployment workflows.

## Workflows

### 1. Test CI (`test.yml`)

**Trigger:** Push to `main`/`develop`, Pull Requests, Manual dispatch

**Purpose:** Run comprehensive test suite with code quality checks

**Test Categories:**
- **Unit Tests** (`test/unit/`) - 8 test files
- **Widget Tests** (`test/widget/`) - 11 test files  
- **Property-Based Tests** (`test/property/`) - 13 test files
- **Integration Tests** (`test/integration/`) - 7 test files
- **Accessibility Tests** (`test/accessibility/`) - 2 test files
- **Performance Tests** (`test/performance/`) - 1 test file

**Total:** 42+ test files covering 94+ test cases

**Steps:**
1. Code analysis with `flutter analyze`
2. Code formatting check with `dart format`
3. Run unit tests
4. Run widget tests
5. Run property-based tests (100+ random cases per property)
6. Run integration tests
7. Run accessibility tests
8. Run performance tests
9. Generate coverage report (minimum 60% threshold)
10. Upload coverage to Codecov (optional)
11. Archive test results as artifacts

**Outputs:**
- Test results summary
- Code coverage report
- Test artifacts (retained for 7 days)

**Coverage Threshold:** 60% minimum

---

### 2. Build Android (`build_android.yml`)

**Trigger:** Push to `main`, Version tags (`v*.*.*`), Manual dispatch

**Purpose:** Build signed Android App Bundle (AAB) for Google Play Store

**Requirements:**
- Java 17
- Android signing keystore
- GitHub Secrets:
  - `ANDROID_KEYSTORE_BASE64` - Base64-encoded keystore file
  - `ANDROID_KEY_ALIAS` - Key alias
  - `ANDROID_KEY_PASSWORD` - Key password
  - `ANDROID_STORE_PASSWORD` - Store password

**Steps:**
1. Setup Java 17 and Flutter
2. Cache Gradle and pub dependencies
3. Decode signing keystore from secrets
4. Create `key.properties` file
5. Build release AAB with signing
6. Upload AAB artifact (retained for 30 days)
7. Upload ProGuard mapping (retained for 90 days)

**Outputs:**
- `app-release.aab` - Signed Android App Bundle
- ProGuard mapping files for crash analysis

**Build Time:** ~10-15 minutes

---

### 3. Build iOS (`build_ios.yml`)

**Trigger:** Push to `main`, Version tags (`v*.*.*`), Manual dispatch

**Purpose:** Build signed iOS IPA for App Store distribution

**Requirements:**
- macOS runner
- iOS signing certificate and provisioning profile
- GitHub Secrets:
  - `IOS_CERTIFICATE_BASE64` - Base64-encoded P12 certificate
  - `IOS_CERTIFICATE_PASSWORD` - Certificate password
  - `IOS_PROVISIONING_PROFILE_BASE64` - Base64-encoded provisioning profile
  - `IOS_TEAM_ID` - Apple Developer Team ID

**Steps:**
1. Setup Flutter and CocoaPods
2. Cache CocoaPods dependencies
3. Import signing certificate to temporary keychain
4. Import provisioning profile
5. Build iOS app without codesign
6. Archive app with Xcode
7. Export signed IPA
8. Upload IPA artifact (retained for 30 days)
9. Upload dSYM symbols (retained for 90 days)

**Outputs:**
- `Runner.ipa` - Signed iOS app
- dSYM symbols for crash analysis

**Build Time:** ~20-30 minutes

---

### 4. Deploy (`deploy.yml`)

**Trigger:** Manual dispatch only

**Purpose:** Deploy builds to TestFlight, App Store, or Google Play Console

**Deployment Targets:**
- `testflight` - iOS TestFlight beta
- `appstore` - iOS App Store production
- `playstore-internal` - Google Play Internal Testing
- `playstore-beta` - Google Play Open Testing
- `playstore-production` - Google Play Production

**Requirements:**
- Pre-built AAB/IPA from build workflows
- Optional: Fastlane configuration for automated uploads
- Optional: App Store Connect API key
- Optional: Google Play Service Account JSON

**Steps:**
1. Validate deployment target and version format
2. Download pre-built artifacts
3. Upload to respective store (manual or via Fastlane)
4. Send deployment notification (optional)

**Note:** Currently requires manual upload to stores. Can be automated with Fastlane.

---

## Setup Instructions

### 1. Configure GitHub Secrets

#### Android Secrets

```bash
# Generate keystore (if not exists)
keytool -genkey -v -keystore upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Encode keystore to Base64
base64 -i upload-keystore.jks | pbcopy

# Add to GitHub Secrets:
# ANDROID_KEYSTORE_BASE64 = <paste base64 string>
# ANDROID_KEY_ALIAS = upload
# ANDROID_KEY_PASSWORD = <your key password>
# ANDROID_STORE_PASSWORD = <your store password>
```

#### iOS Secrets

```bash
# Export certificate from Keychain as P12
# Then encode to Base64
base64 -i certificate.p12 | pbcopy

# Encode provisioning profile
base64 -i profile.mobileprovision | pbcopy

# Add to GitHub Secrets:
# IOS_CERTIFICATE_BASE64 = <paste certificate base64>
# IOS_CERTIFICATE_PASSWORD = <certificate password>
# IOS_PROVISIONING_PROFILE_BASE64 = <paste profile base64>
# IOS_TEAM_ID = <your Apple Team ID>
```

#### Optional: Store Upload Secrets

```bash
# App Store Connect API Key
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
# Add as: APP_STORE_CONNECT_API_KEY_BASE64
# Also add: APP_STORE_CONNECT_API_KEY_ID
# Also add: APP_STORE_CONNECT_ISSUER_ID

# Google Play Service Account
base64 -i service-account.json | pbcopy
# Add as: GOOGLE_PLAY_SERVICE_ACCOUNT_JSON
```

### 2. Enable Workflows

All workflows are enabled by default. They will run automatically based on their triggers.

### 3. Manual Workflow Dispatch

You can manually trigger workflows from GitHub Actions UI:

1. Go to **Actions** tab
2. Select workflow (Test CI, Build Android, Build iOS, Deploy)
3. Click **Run workflow**
4. Fill in required inputs (for build/deploy workflows)
5. Click **Run workflow**

---

## Property-Based Testing in CI

Property-based tests are a key part of the test suite, validating correctness properties across 100+ random test cases per property.

**Properties Tested:**
1. **Note Content Integrity** - Content never exceeds 140 characters
2. **Archive-Pin Relationship** - Notes cannot be both archived and pinned
3. **Search Result Consistency** - Search results are always subset of active notes
4. **Timestamp Monotonicity** - Timestamps follow logical ordering
5. **Priority-Based Ordering** - Notes ordered by priority consistently
6. **Data Persistence Integrity** - All operations are persistent and recoverable

**Execution:**
- Property tests run in dedicated step: `Run property-based tests`
- Each property runs 100+ random test cases
- Failures include counterexamples for debugging
- Results included in test summary

**Test Location:** `test/property/`

---

## Code Coverage

**Minimum Threshold:** 60%

**Coverage Report:**
- Generated with `flutter test --coverage`
- Uploaded to Codecov (optional, requires token)
- Available as artifact in workflow runs
- Threshold check fails CI if below 60%

**View Coverage:**
1. Download `test-results` artifact from workflow run
2. Open `coverage/lcov.info` with coverage viewer
3. Or view on Codecov dashboard (if configured)

---

## Artifacts

### Test Results
- **Name:** `test-results`
- **Contents:** Coverage reports, test files
- **Retention:** 7 days
- **Size:** ~5-10 MB

### Android Build
- **Name:** `app-release-{version}`
- **Contents:** Signed AAB file
- **Retention:** 30 days
- **Size:** ~15-25 MB

### Android Mapping
- **Name:** `mapping-{version}`
- **Contents:** ProGuard mapping files
- **Retention:** 90 days
- **Size:** ~1-5 MB

### iOS Build
- **Name:** `ios-release-{version}`
- **Contents:** Signed IPA file
- **Retention:** 30 days
- **Size:** ~30-50 MB

### iOS Symbols
- **Name:** `dsym-{version}`
- **Contents:** dSYM debug symbols
- **Retention:** 90 days
- **Size:** ~10-20 MB

---

## Troubleshooting

### Test Failures

**Problem:** Tests fail in CI but pass locally

**Solutions:**
1. Check Flutter version matches (3.x stable)
2. Run `flutter pub get` to sync dependencies
3. Clear cache: `flutter clean && flutter pub get`
4. Check for platform-specific issues (Linux vs macOS)

### Build Failures

**Problem:** Android build fails with signing error

**Solutions:**
1. Verify all Android secrets are set correctly
2. Check keystore is valid: `keytool -list -v -keystore upload-keystore.jks`
3. Ensure Base64 encoding is correct (no line breaks)

**Problem:** iOS build fails with provisioning error

**Solutions:**
1. Verify provisioning profile matches bundle ID
2. Check certificate is valid and not expired
3. Ensure Team ID is correct
4. Verify provisioning profile includes signing certificate

### Coverage Threshold

**Problem:** Coverage below 60% threshold

**Solutions:**
1. Add tests for uncovered code
2. Remove dead code
3. Adjust threshold in workflow (if justified)

---

## Best Practices

### 1. Run Tests Locally First
```bash
# Run all tests
flutter test

# Run specific test suite
flutter test test/unit/
flutter test test/property/

# Run with coverage
flutter test --coverage
```

### 2. Version Tagging
```bash
# Create version tag
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin v1.0.0

# This triggers build workflows automatically
```

### 3. Pre-commit Checks
```bash
# Analyze code
flutter analyze

# Format code
dart format .

# Run tests
flutter test
```

### 4. Monitor Workflow Runs
- Check GitHub Actions tab regularly
- Review failed workflow logs
- Download artifacts for testing
- Monitor coverage trends

### 5. Keep Secrets Updated
- Rotate signing keys annually
- Update certificates before expiration
- Test secret changes in workflow dispatch

---

## Performance Optimization

### Caching Strategy
- **Pub dependencies:** Cached by `pubspec.lock` hash
- **Gradle dependencies:** Cached by Gradle files hash
- **CocoaPods:** Cached by `Podfile.lock` hash

### Parallel Execution
- Test suites run sequentially for clarity
- Can be parallelized if needed (separate jobs)

### Timeout Settings
- **Test CI:** 20 minutes
- **Android Build:** 30 minutes
- **iOS Build:** 45 minutes
- **Deploy:** 30 minutes

---

## Deployment Automation

### ✅ Implemented Features

The deployment pipeline now includes full automation:

1. **✅ Fastlane Integration** - Automated store uploads for iOS and Android
2. **✅ Version Management** - Automated version bumping with `version_manager.sh`
3. **✅ Release Notes Generation** - Automated release notes from git commits
4. **✅ Security Scanning** - Comprehensive security checks before deployment
5. **✅ One-Command Deployment** - Deploy to any store with single workflow

**See:** [Deployment Automation Guide](DEPLOYMENT_AUTOMATION.md) for complete documentation

### Future Enhancements

1. **Parallel Test Execution** - Faster CI runs
2. **Visual Regression Testing** - Screenshot comparisons
3. **Slack/Discord Notifications** - Build status alerts
4. **E2E Tests on Real Devices** - Firebase Test Lab integration
5. **Automated Rollback** - Quick rollback on critical issues

### Optional Integrations
- **Codecov** - Coverage tracking and trends
- **Sentry** - Crash reporting and monitoring
- **Firebase Crashlytics** - Mobile crash analytics
- **App Center** - Beta distribution and testing

---

## Support

For issues or questions about the CI/CD pipeline:
1. Check workflow logs in GitHub Actions
2. Review this documentation
3. Check GitHub Secrets configuration
4. Verify Flutter and dependency versions
5. Test builds locally before pushing

**Workflow Files:**
- `.github/workflows/test.yml`
- `.github/workflows/build_android.yml`
- `.github/workflows/build_ios.yml`
- `.github/workflows/deploy.yml`

**Last Updated:** 2026-02-04
