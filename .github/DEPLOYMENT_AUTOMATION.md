# Deployment Automation Guide

## Overview

This guide covers the automated deployment system for ephenotes mobile app, including TestFlight, App Store, and Google Play Console uploads.

**Key Features:**
- ✅ Automated build and deployment to all stores
- ✅ Version management automation
- ✅ Release notes generation
- ✅ Security scanning integration
- ✅ Fastlane integration for iOS and Android
- ✅ One-command deployment workflow

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Version Management](#version-management)
4. [Release Notes Generation](#release-notes-generation)
5. [Deployment Workflows](#deployment-workflows)
6. [Security Scanning](#security-scanning)
7. [Fastlane Configuration](#fastlane-configuration)
8. [Troubleshooting](#troubleshooting)

---

## Quick Start

### Deploy to TestFlight (iOS)

```bash
# 1. Update version
./scripts/version_manager.sh set 1.0.0 1

# 2. Generate release notes
./scripts/generate_release_notes.sh store v0.9.0 HEAD ios

# 3. Commit and push
git add .
git commit -m "Release version 1.0.0"
git push

# 4. Trigger deployment via GitHub Actions
# Go to Actions > Deploy to App Stores > Run workflow
# Select: testflight, version: 1.0.0, build: 1
```

### Deploy to Play Console (Android)

```bash
# 1. Update version
./scripts/version_manager.sh set 1.0.0 1

# 2. Generate release notes
./scripts/generate_release_notes.sh store v0.9.0 HEAD android

# 3. Commit and push
git add .
git commit -m "Release version 1.0.0"
git push

# 4. Trigger deployment via GitHub Actions
# Go to Actions > Deploy to App Stores > Run workflow
# Select: playstore-internal, version: 1.0.0, build: 1
```

---

## Prerequisites

### Required GitHub Secrets

#### Android Secrets (4 required)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore | `base64 -i upload-keystore.jks \| pbcopy` |
| `ANDROID_KEY_ALIAS` | Key alias | From keystore generation |
| `ANDROID_KEY_PASSWORD` | Key password | From keystore generation |
| `ANDROID_STORE_PASSWORD` | Store password | From keystore generation |
| `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` | Service account JSON (Base64) | From Google Cloud Console |

#### iOS Secrets (4 required)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `IOS_CERTIFICATE_BASE64` | P12 certificate (Base64) | Export from Keychain, then `base64 -i cert.p12 \| pbcopy` |
| `IOS_CERTIFICATE_PASSWORD` | Certificate password | From certificate export |
| `IOS_PROVISIONING_PROFILE_BASE64` | Provisioning profile (Base64) | `base64 -i profile.mobileprovision \| pbcopy` |
| `IOS_TEAM_ID` | Apple Developer Team ID | From Apple Developer Portal |

#### App Store Connect API (3 optional, recommended)

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `APP_STORE_CONNECT_API_KEY_BASE64` | API key (Base64) | From App Store Connect > Users and Access > Keys |
| `APP_STORE_CONNECT_API_KEY_ID` | API key ID | From App Store Connect |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | From App Store Connect |

### Local Tools

```bash
# Install Fastlane
sudo gem install fastlane

# Verify installation
fastlane --version

# Install Flutter (if not already)
flutter --version
```

---

## Version Management

### Automated Version Bumping

The `version_manager.sh` script automates version updates across all platform files.

#### Bump Version Automatically

```bash
# Bump patch version (1.0.0 → 1.0.1)
./scripts/version_manager.sh bump patch

# Bump minor version (1.0.0 → 1.1.0)
./scripts/version_manager.sh bump minor

# Bump major version (1.0.0 → 2.0.0)
./scripts/version_manager.sh bump major
```

#### Set Specific Version

```bash
# Set version to 1.2.3 with build number 42
./scripts/version_manager.sh set 1.2.3 42

# Set version to 2.0.0 (auto-increment build number)
./scripts/version_manager.sh set 2.0.0
```

#### Check Current Version

```bash
./scripts/version_manager.sh current
```

### What Gets Updated

The version manager updates:
- ✅ `pubspec.yaml` - Flutter version
- ✅ `android/app/build.gradle.kts` - Android versionCode and versionName
- ✅ `ios/Runner/Info.plist` - iOS CFBundleShortVersionString and CFBundleVersion
- ✅ `CHANGELOG.md` - Generates changelog entry

### Version Format

- **Version:** Semantic versioning (X.Y.Z)
  - X = Major version (breaking changes)
  - Y = Minor version (new features)
  - Z = Patch version (bug fixes)
- **Build Number:** Integer that increments with each build

**Example:** `1.2.3+42`
- Version: 1.2.3
- Build: 42

---

## Release Notes Generation

### Generate Full Release Notes

```bash
# Generate release notes from v1.0.0 to v1.1.0
./scripts/generate_release_notes.sh full v1.0.0 v1.1.0

# Generate release notes from last tag to HEAD
./scripts/generate_release_notes.sh full v1.0.0 HEAD

# Save to custom file
./scripts/generate_release_notes.sh full v1.0.0 v1.1.0 RELEASE_NOTES_1.1.0.md
```

### Generate Store-Specific Release Notes

```bash
# Generate for both stores
./scripts/generate_release_notes.sh store v1.0.0 HEAD both

# Generate for App Store only
./scripts/generate_release_notes.sh store v1.0.0 HEAD appstore

# Generate for Play Store only
./scripts/generate_release_notes.sh store v1.0.0 HEAD playstore
```

### Release Notes Format

The script categorizes commits using conventional commit format:

| Prefix | Category | Example |
|--------|----------|---------|
| `feat:` | ✨ New Features | `feat: add dark mode support` |
| `fix:` | 🐛 Bug Fixes | `fix: resolve crash on startup` |
| `perf:` | ⚡ Performance | `perf: optimize search algorithm` |
| `refactor:` | ♻️ Refactoring | `refactor: simplify note model` |
| `docs:` | 📚 Documentation | `docs: update README` |
| `test:` | 🧪 Tests | `test: add unit tests for notes` |
| `chore:` | 🔧 Chores | `chore: update dependencies` |

### Store Release Notes Limits

- **App Store:** 4000 characters max
- **Play Store:** 500 characters max (per language)

The script automatically checks character count and warns if exceeded.

---

## Deployment Workflows

### Deployment Targets

| Target | Platform | Description | Review Required |
|--------|----------|-------------|-----------------|
| `testflight` | iOS | TestFlight beta testing | No |
| `appstore` | iOS | App Store production | Yes (Apple review) |
| `playstore-internal` | Android | Internal testing | No |
| `playstore-beta` | Android | Open beta testing | No |
| `playstore-production` | Android | Production release | Yes (Google review) |

### Deploy via GitHub Actions

1. **Go to GitHub Actions**
   - Navigate to your repository
   - Click "Actions" tab
   - Select "Deploy to App Stores" workflow

2. **Click "Run workflow"**
   - Select branch (usually `main`)
   - Choose deployment target
   - Enter version number (e.g., `1.0.0`)
   - Enter build number (e.g., `1`)
   - Add release notes (optional)

3. **Monitor Deployment**
   - Watch workflow progress
   - Check for errors in logs
   - Review deployment summary

### Deploy via Fastlane (Local)

#### iOS Deployment

```bash
# Deploy to TestFlight
cd ios
fastlane deploy_beta

# Deploy to App Store
cd ios
fastlane deploy_release

# Build only (no upload)
cd ios
fastlane build
```

#### Android Deployment

```bash
# Deploy to Internal Testing
cd android
fastlane deploy_internal

# Deploy to Beta
cd android
fastlane deploy_beta

# Deploy to Production
cd android
fastlane deploy_production

# Build only (no upload)
cd android
fastlane build
```

### Deployment Timeline

| Target | Build Time | Processing Time | Total Time |
|--------|------------|-----------------|------------|
| TestFlight | ~20-30 min | ~10-15 min | ~30-45 min |
| App Store | ~20-30 min | 24-48 hours (review) | 1-3 days |
| Play Internal | ~10-15 min | ~5-10 min | ~15-25 min |
| Play Beta | ~10-15 min | ~5-10 min | ~15-25 min |
| Play Production | ~10-15 min | 1-7 days (review) | 1-7 days |

---

## Security Scanning

### Automated Security Scans

The security scan workflow runs automatically:
- ✅ On every push to `main` or `develop`
- ✅ On every pull request to `main`
- ✅ Weekly on Mondays at 9 AM UTC
- ✅ Manual trigger via GitHub Actions

### Security Checks

#### 1. Dependency Security Scan
- Checks for outdated packages
- Identifies known vulnerabilities
- Audits pub dependencies

#### 2. Code Security Scan
- Static code analysis with `flutter analyze`
- Checks for security-related issues
- Identifies potential vulnerabilities

#### 3. Secrets Detection
- Scans for hardcoded passwords
- Checks for API keys in code
- Detects tokens and private keys

#### 4. Android Security
- Reviews AndroidManifest.xml permissions
- Checks for dangerous permissions
- Validates debuggable flag
- Reviews ProGuard configuration

#### 5. iOS Security
- Checks App Transport Security settings
- Reviews privacy permissions
- Detects hardcoded HTTP URLs
- Validates Info.plist security

### Run Security Scan Manually

```bash
# Via GitHub Actions
# Go to Actions > Security Scan > Run workflow

# Or run locally
flutter analyze
flutter pub outdated
dart pub audit
```

### Security Best Practices

1. **Never commit secrets**
   - Use environment variables
   - Use GitHub Secrets for CI/CD
   - Add sensitive files to `.gitignore`

2. **Keep dependencies updated**
   - Run `flutter pub outdated` regularly
   - Update packages with security fixes
   - Review dependency changes

3. **Minimize permissions**
   - Request only necessary permissions
   - Explain permission usage to users
   - Remove unused permissions

4. **Use HTTPS only**
   - No hardcoded HTTP URLs
   - Enable App Transport Security (iOS)
   - Use secure network connections

5. **Enable code obfuscation**
   - Use ProGuard/R8 for Android
   - Enable code obfuscation for iOS
   - Protect sensitive logic

---

## Fastlane Configuration

### Android Fastlane Setup

**Location:** `android/fastlane/`

**Files:**
- `Fastfile` - Deployment lanes
- `Appfile` - App configuration

**Lanes:**
- `build` - Build AAB
- `internal` - Deploy to Internal Testing
- `beta` - Deploy to Beta
- `production` - Deploy to Production
- `promote_to_production` - Promote Beta to Production

**Configuration:**
```ruby
# android/fastlane/Appfile
json_key_file("android/service-account.json")
package_name("com.ephenotes.app")
```

### iOS Fastlane Setup

**Location:** `ios/fastlane/`

**Files:**
- `Fastfile` - Deployment lanes
- `Appfile` - App configuration

**Lanes:**
- `build` - Build IPA
- `beta` - Deploy to TestFlight
- `release` - Deploy to App Store
- `upload_metadata` - Upload metadata only
- `download_metadata` - Download metadata

**Configuration:**
```ruby
# ios/fastlane/Appfile
app_identifier("com.ephenotes.app")
apple_id(ENV["APPLE_ID"])
team_id(ENV["TEAM_ID"])
```

### Environment Variables

Fastlane uses environment variables for sensitive data:

**iOS:**
- `APP_STORE_CONNECT_API_KEY_CONTENT` - API key (Base64)
- `APP_STORE_CONNECT_API_KEY_ID` - API key ID
- `APP_STORE_CONNECT_ISSUER_ID` - Issuer ID
- `TEAM_ID` - Apple Team ID
- `APPLE_ID` - Apple ID email

**Android:**
- Service account JSON file path (in Appfile)

---

## Troubleshooting

### Common Issues

#### 1. Fastlane Not Found

**Error:** `fastlane: command not found`

**Solution:**
```bash
# Install Fastlane
sudo gem install fastlane

# Or use bundler
bundle install
bundle exec fastlane
```

#### 2. iOS Code Signing Error

**Error:** `No signing certificate found`

**Solution:**
1. Verify certificate is valid and not expired
2. Check provisioning profile matches bundle ID
3. Ensure Team ID is correct
4. Re-export certificate and profile

```bash
# Check certificate
security find-identity -v -p codesigning

# Check provisioning profile
security cms -D -i profile.mobileprovision
```

#### 3. Android Upload Failed

**Error:** `Service account authentication failed`

**Solution:**
1. Verify service account JSON is valid
2. Check service account has "Release Manager" role
3. Ensure API is enabled in Google Cloud Console
4. Re-download service account key

#### 4. Version Conflict

**Error:** `Version code X has already been used`

**Solution:**
```bash
# Increment build number
./scripts/version_manager.sh set 1.0.0 <new_build_number>

# Or bump version
./scripts/version_manager.sh bump patch
```

#### 5. Release Notes Too Long

**Error:** `Release notes exceed 4000 characters`

**Solution:**
```bash
# Edit release notes file
nano ios/AppStore/release_notes.txt

# Or regenerate with shorter commits
./scripts/generate_release_notes.sh store v1.0.0 HEAD both
```

### Debug Mode

Enable verbose logging for troubleshooting:

```bash
# Fastlane verbose mode
fastlane beta --verbose

# Flutter verbose mode
flutter build appbundle --verbose

# GitHub Actions debug mode
# Add secret: ACTIONS_STEP_DEBUG = true
```

### Get Help

1. **Check workflow logs** in GitHub Actions
2. **Review Fastlane logs** in `fastlane/report.xml`
3. **Check Flutter doctor** with `flutter doctor -v`
4. **Verify secrets** are set correctly in GitHub
5. **Test locally** before pushing to CI/CD

---

## Best Practices

### 1. Version Management

- ✅ Use semantic versioning
- ✅ Increment build number for each build
- ✅ Tag releases in git
- ✅ Keep CHANGELOG.md updated

### 2. Release Notes

- ✅ Use conventional commit format
- ✅ Write user-friendly descriptions
- ✅ Keep notes concise and clear
- ✅ Highlight key features and fixes

### 3. Testing Before Deployment

- ✅ Run all tests locally
- ✅ Test on physical devices
- ✅ Verify version numbers
- ✅ Review release notes

### 4. Deployment Strategy

- ✅ Deploy to internal testing first
- ✅ Gather feedback from beta testers
- ✅ Monitor crash reports
- ✅ Gradual rollout to production

### 5. Security

- ✅ Run security scans before deployment
- ✅ Review permissions and privacy
- ✅ Keep dependencies updated
- ✅ Never commit secrets

---

## Deployment Checklist

### Pre-Deployment

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Version number updated
- [ ] Release notes generated
- [ ] Security scan passed
- [ ] Tested on physical devices
- [ ] Screenshots updated (if needed)
- [ ] Metadata reviewed

### Deployment

- [ ] Trigger deployment workflow
- [ ] Monitor build progress
- [ ] Verify upload successful
- [ ] Check store listing

### Post-Deployment

- [ ] Verify build in TestFlight/Play Console
- [ ] Add testers (if beta)
- [ ] Monitor crash reports
- [ ] Respond to user feedback
- [ ] Track installation metrics

---

## Additional Resources

### Documentation

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment)

### Tools

- [Transporter](https://apps.apple.com/app/transporter/id1450874784) - iOS app upload
- [bundletool](https://developer.android.com/studio/command-line/bundletool) - Android AAB testing
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi) - Automation

### Support

- GitHub Issues: Report bugs and request features
- Fastlane Community: [fastlane.tools/community](https://fastlane.tools/community)
- Flutter Discord: [flutter.dev/community](https://flutter.dev/community)

---

**Last Updated:** 2026-02-04  
**Version:** 1.0.0

