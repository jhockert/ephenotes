# CI/CD Pipeline

This document describes the Continuous Integration and Continuous Deployment (CI/CD) pipeline for ephenotes using GitHub Actions.

## Table of Contents

1. [Overview](#overview)
2. [Pipeline Architecture](#pipeline-architecture)
3. [GitHub Actions Workflows](#github-actions-workflows)
4. [Setup Instructions](#setup-instructions)
5. [Secrets Configuration](#secrets-configuration)
6. [Workflow Triggers](#workflow-triggers)
7. [Build Artifacts](#build-artifacts)
8. [Deployment Process](#deployment-process)
9. [Troubleshooting](#troubleshooting)

---

## Overview

The ephenotes CI/CD pipeline automates:

- **Code Quality**: Linting, formatting, and static analysis
- **Testing**: Unit tests, widget tests, integration tests
- **Building**: Android AAB and iOS IPA compilation
- **Deployment**: Beta distribution and app store releases

**Benefits:**
- Catch bugs early
- Consistent build environment
- Faster release cycles
- Automated testing on every commit
- Reduced human error

---

## Pipeline Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Developer                            │
│                            │                                 │
│                            ▼                                 │
│                    git push / PR                            │
└────────────────────────────┬────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────┐
│                     GitHub Actions                           │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   Test CI    │  │  Build iOS   │  │Build Android │      │
│  │              │  │              │  │              │      │
│  │ • Lint       │  │ • Compile    │  │ • Compile    │      │
│  │ • Format     │  │ • Sign       │  │ • Sign       │      │
│  │ • Analyze    │  │ • Archive    │  │ • Bundle     │      │
│  │ • Test       │  │              │  │              │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                 │                 │               │
│         ▼                 ▼                 ▼               │
│  ┌──────────────────────────────────────────────────┐      │
│  │              All Checks Pass ✅                   │      │
│  └──────────────────────┬───────────────────────────┘      │
└─────────────────────────┼──────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│              Deployment (Manual Trigger)                     │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  TestFlight     │              │  Play Console   │      │
│  │  (iOS Beta)     │              │  (Android Beta) │      │
│  └─────────────────┘              └─────────────────┘      │
│                                                              │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  App Store      │              │  Google Play    │      │
│  │  (Production)   │              │  (Production)   │      │
│  └─────────────────┘              └─────────────────┘      │
└─────────────────────────────────────────────────────────────┘
```

---

## GitHub Actions Workflows

### 1. Test Workflow (`test.yml`)

**Purpose:** Run tests and quality checks on every push/PR

**Triggers:**
- Push to `main` branch
- Pull requests targeting `main`
- Manual dispatch

**Steps:**
1. Checkout code
2. Setup Flutter
3. Install dependencies
4. Run `flutter analyze`
5. Run `flutter format --set-exit-if-changed`
6. Run `flutter test` with coverage
7. Upload coverage to Codecov (optional)

**Duration:** ~3-5 minutes

### 2. Build Android Workflow (`build_android.yml`)

**Purpose:** Build signed Android App Bundle (AAB)

**Triggers:**
- Push to `main` branch (after tests pass)
- Manual dispatch with version input
- Tag push (e.g., `v1.0.0`)

**Steps:**
1. Checkout code
2. Setup Flutter
3. Setup Java 17
4. Decode keystore from secrets
5. Create `key.properties`
6. Build AAB: `flutter build appbundle --release`
7. Upload AAB as artifact

**Duration:** ~8-12 minutes

### 3. Build iOS Workflow (`build_ios.yml`)

**Purpose:** Build signed iOS IPA

**Triggers:**
- Push to `main` branch (after tests pass)
- Manual dispatch with version input
- Tag push (e.g., `v1.0.0`)

**Requirements:**
- Self-hosted macOS runner (Xcode required)
- OR GitHub-hosted macOS runner with Xcode

**Steps:**
1. Checkout code
2. Setup Flutter
3. Install CocoaPods dependencies
4. Import certificates and provisioning profiles
5. Build IPA: `flutter build ios --release`
6. Export IPA for App Store
7. Upload IPA as artifact

**Duration:** ~15-25 minutes

**Note:** iOS builds require macOS with Xcode. GitHub provides macOS runners, but they have limited minutes on free tier. Consider self-hosted runner for production use.

### 4. Deploy Workflow (`deploy.yml`)

**Purpose:** Deploy to TestFlight, Play Console, or production

**Trigger:** Manual dispatch only (workflow_dispatch)

**Inputs:**
- **Target:** `testflight` | `playstore-beta` | `appstore` | `playstore`
- **Version:** Version number (e.g., `1.0.0`)
- **Build Number:** Build number (e.g., `1`)

**Steps:**
1. Download build artifacts
2. Upload to selected target using Fastlane
3. Notify on Slack/Discord (optional)

**Duration:** ~5-10 minutes

---

## Setup Instructions

### 1. Initialize GitHub Actions

```bash
# Create workflow directory
mkdir -p .github/workflows

# Workflows are already created in the repository:
# - .github/workflows/test.yml
# - .github/workflows/build_android.yml
# - .github/workflows/build_ios.yml
# - .github/workflows/deploy.yml
```

### 2. Configure Repository Settings

1. Go to repository **Settings** > **Actions** > **General**
2. **Workflow permissions:**
   - ✅ Read and write permissions
   - ✅ Allow GitHub Actions to create and approve pull requests

3. **Artifact and log retention:**
   - Set to **30 days** (or longer for releases)

### 3. Set Up Secrets

Go to **Settings** > **Secrets and variables** > **Actions**

#### Required Secrets

Click **New repository secret** for each:

**Android Secrets:**

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded keystore file | `cat android/app/keys/upload-keystore.jks \| base64` |
| `ANDROID_KEY_ALIAS` | Key alias (usually "upload") | From keystore generation |
| `ANDROID_KEY_PASSWORD` | Key password | From keystore generation |
| `ANDROID_STORE_PASSWORD` | Keystore password | From keystore generation |

**iOS Secrets:**

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `IOS_CERTIFICATE_BASE64` | Base64-encoded P12 certificate | `cat certificate.p12 \| base64` |
| `IOS_CERTIFICATE_PASSWORD` | Certificate password | From certificate export |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile | `cat profile.mobileprovision \| base64` |
| `IOS_TEAM_ID` | Apple Developer Team ID | developer.apple.com/account |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API Key ID | appstoreconnect.apple.com |
| `APP_STORE_CONNECT_ISSUER_ID` | API Key Issuer ID | appstoreconnect.apple.com |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded .p8 key | `cat AuthKey_XXX.p8 \| base64` |

**Deployment Secrets (Optional):**

| Secret Name | Description | How to Get |
|-------------|-------------|------------|
| `SLACK_WEBHOOK_URL` | Slack webhook for notifications | slack.com/apps |
| `DISCORD_WEBHOOK_URL` | Discord webhook for notifications | Discord server settings |

### 4. Generate Android Secrets

```bash
# Generate keystore (if not already done)
keytool -genkey -v \
        -storetype PKCS12 \
        -keystore android/app/keys/upload-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias upload

# Convert keystore to Base64
cat android/app/keys/upload-keystore.jks | base64 | pbcopy
# Paste as ANDROID_KEYSTORE_BASE64 secret

# Store passwords as secrets:
# ANDROID_KEY_ALIAS=upload
# ANDROID_KEY_PASSWORD=<your-key-password>
# ANDROID_STORE_PASSWORD=<your-store-password>
```

### 5. Generate iOS Secrets

#### 5.1 Export Certificate

```bash
# Open Keychain Access
# Find "Apple Distribution: Your Name"
# Right-click > Export "Apple Distribution..."
# Save as certificate.p12
# Set a password

# Convert to Base64
cat certificate.p12 | base64 | pbcopy
# Paste as IOS_CERTIFICATE_BASE64 secret

# Store password as IOS_CERTIFICATE_PASSWORD secret
```

#### 5.2 Export Provisioning Profile

```bash
# Download from developer.apple.com/account
# Certificates, Identifiers & Profiles > Profiles
# Download App Store provisioning profile

# Convert to Base64
cat ephenotes_AppStore.mobileprovision | base64 | pbcopy
# Paste as IOS_PROVISIONING_PROFILE_BASE64 secret
```

#### 5.3 Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/access/api)
2. Click **Keys** tab
3. Click **+** to generate new API key
4. Name: "GitHub Actions CI/CD"
5. Access: **App Manager**
6. Download `.p8` file (only available once!)

```bash
# Convert to Base64
cat AuthKey_XXXXXXXXXX.p8 | base64 | pbcopy
# Paste as APP_STORE_CONNECT_API_KEY_BASE64

# Store these from App Store Connect page:
# APP_STORE_CONNECT_API_KEY_ID (e.g., XXXXXXXXXX)
# APP_STORE_CONNECT_ISSUER_ID (e.g., xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx)
```

### 6. Test Workflows

```bash
# Trigger test workflow
git commit --allow-empty -m "Test CI workflow"
git push

# Watch workflow run
# Go to: https://github.com/YOUR_USERNAME/ephenotes/actions

# Check for green checkmarks ✅
```

---

## Secrets Configuration

### Creating Base64 Secrets

**macOS/Linux:**
```bash
# File to Base64
cat <file> | base64 | pbcopy  # Copies to clipboard

# String to Base64
echo -n "your-password" | base64
```

**Windows (PowerShell):**
```powershell
# File to Base64
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path\to\file"))

# String to Base64
[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("your-password"))
```

### Security Best Practices

- ✅ **Never commit secrets** to repository
- ✅ **Use GitHub Secrets** for all sensitive data
- ✅ **Rotate secrets** every 6-12 months
- ✅ **Limit secret access** to only workflows that need them
- ✅ **Use environment-specific secrets** (dev, staging, prod)
- ✅ **Enable secret scanning** in repository settings
- ✅ **Review access logs** periodically

**GitHub Secret Protection:**
- Secrets are encrypted at rest
- Secrets are redacted from logs (shown as `***`)
- Secrets are only available during workflow execution
- Secrets are not passed to forked repositories

---

## Workflow Triggers

### Push Triggers

```yaml
on:
  push:
    branches:
      - main
      - develop
    paths-ignore:
      - '**.md'
      - 'docs/**'
```

Runs on every push to `main` or `develop`, except markdown/docs changes.

### Pull Request Triggers

```yaml
on:
  pull_request:
    branches:
      - main
    types:
      - opened
      - synchronize
      - reopened
```

Runs on PRs targeting `main` when opened, updated, or reopened.

### Tag Triggers

```yaml
on:
  push:
    tags:
      - 'v*.*.*'
```

Runs on version tags (e.g., `v1.0.0`, `v1.0.1`).

### Manual Triggers

```yaml
on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version number (e.g., 1.0.0)'
        required: true
      environment:
        description: 'Deployment environment'
        required: true
        type: choice
        options:
          - beta
          - production
```

Allows manual workflow execution from GitHub UI.

### Schedule Triggers

```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday at midnight
```

Runs on a schedule (useful for dependency updates, security scans).

---

## Build Artifacts

### What Are Artifacts?

Artifacts are files produced during workflow runs that can be downloaded or used by other workflows.

### ephenotes Artifacts

1. **Android AAB**
   - File: `app-release.aab`
   - Size: ~15-20 MB
   - Retention: 30 days
   - Download from: Actions > Workflow Run > Artifacts

2. **iOS IPA**
   - File: `Runner.ipa`
   - Size: ~25-30 MB
   - Retention: 30 days
   - Download from: Actions > Workflow Run > Artifacts

3. **Test Coverage**
   - File: `coverage.zip` (contains `lcov.info`)
   - Size: ~1 MB
   - Retention: 30 days

### Downloading Artifacts

**Via GitHub UI:**
1. Go to **Actions** tab
2. Click on workflow run
3. Scroll to **Artifacts** section
4. Click artifact name to download ZIP

**Via GitHub CLI:**
```bash
# Install GitHub CLI
brew install gh

# Authenticate
gh auth login

# List artifacts
gh run list --workflow=build_android.yml

# Download artifact
gh run download <run-id> --name app-release
```

### Using Artifacts in Other Workflows

```yaml
- name: Download Android AAB
  uses: actions/download-artifact@v4
  with:
    name: app-release
    path: build/outputs/

- name: Deploy to Play Store
  run: |
    fastlane android deploy
```

---

## Deployment Process

### Beta Deployment (TestFlight/Play Console Internal Testing)

#### iOS TestFlight

```bash
# Trigger deploy workflow manually
# GitHub > Actions > Deploy > Run workflow
#
# Inputs:
#   Target: testflight
#   Version: 1.0.0
#   Build Number: 1

# Or use Fastlane locally:
cd ios
fastlane beta

# Testers receive notification via TestFlight app
```

#### Android Internal Testing

```bash
# Trigger deploy workflow manually
# GitHub > Actions > Deploy > Run workflow
#
# Inputs:
#   Target: playstore-beta
#   Version: 1.0.0
#   Build Number: 1

# Or use Fastlane locally:
cd android
fastlane internal

# Add testers in Play Console > Internal Testing
```

### Production Deployment

#### Prerequisites

- [ ] All tests passing
- [ ] Beta testing completed
- [ ] No critical bugs
- [ ] App store metadata updated
- [ ] Screenshots uploaded
- [ ] Privacy policy published
- [ ] Version numbers incremented

#### iOS App Store

```bash
# Trigger deploy workflow manually
# GitHub > Actions > Deploy > Run workflow
#
# Inputs:
#   Target: appstore
#   Version: 1.0.0
#   Build Number: 1

# Build uploaded to App Store Connect
# Go to App Store Connect > My Apps > ephenotes
# Select build version
# Submit for review
```

**Manual Submission After Upload:**
1. App Store Connect > My Apps > ephenotes
2. Click **+** Version or Build
3. Select uploaded build
4. Complete What's New
5. Submit for Review

#### Google Play Store

```bash
# Trigger deploy workflow manually
# GitHub > Actions > Deploy > Run workflow
#
# Inputs:
#   Target: playstore
#   Version: 1.0.0
#   Build Number: 1

# Build uploaded to Play Console
# Go to Play Console > ephenotes > Production
# Review and rollout release
```

**Manual Release After Upload:**
1. Play Console > ephenotes > Production
2. Create new release
3. Select uploaded AAB
4. Add release notes
5. Review and rollout (20% → 50% → 100%)

---

## Workflow Examples

### Running Tests Manually

```bash
# Via GitHub CLI
gh workflow run test.yml

# Via GitHub UI
# Actions > Test > Run workflow > Run
```

### Building for Specific Version

```bash
# Via GitHub CLI
gh workflow run build_android.yml \
  -f version=1.0.1 \
  -f build_number=2

# Via GitHub UI
# Actions > Build Android > Run workflow
# Enter version: 1.0.1
# Enter build_number: 2
# Click Run
```

### Deploying to TestFlight

```bash
# Via GitHub CLI
gh workflow run deploy.yml \
  -f target=testflight \
  -f version=1.0.0 \
  -f build_number=1

# Via GitHub UI
# Actions > Deploy > Run workflow
# Target: testflight
# Version: 1.0.0
# Build Number: 1
# Click Run
```

---

## Monitoring Workflows

### GitHub Actions Dashboard

View all workflow runs:
```
https://github.com/YOUR_USERNAME/ephenotes/actions
```

**Status indicators:**
- 🟢 **Success** - All steps completed
- 🔴 **Failure** - One or more steps failed
- 🟡 **In Progress** - Currently running
- ⚪ **Queued** - Waiting to start
- ⚫ **Cancelled** - Manually cancelled

### Email Notifications

**Enable notifications:**
1. GitHub > Settings > Notifications
2. **Actions** section:
   - ✅ Only notify for failed workflows
   - ✅ Send notifications for my own workflows
   - ✅ Send notifications for workflows I watch

### Slack Integration (Optional)

Add to workflow:
```yaml
- name: Notify Slack
  if: failure()
  uses: slackapi/slack-github-action@v1
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
    payload: |
      {
        "text": "❌ Build failed for ephenotes v${{ github.ref_name }}"
      }
```

---

## Troubleshooting

### Common Issues

#### 1. Workflow Fails: "flutter: command not found"

**Solution:** Check Flutter setup action:
```yaml
- uses: subosito/flutter-action@v2
  with:
    flutter-version: '3.x'
    channel: 'stable'
```

#### 2. Android Build Fails: "Keystore not found"

**Solution:** Verify secrets and decoding:
```yaml
- name: Decode keystore
  run: |
    echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > android/app/keys/upload-keystore.jks
```

Check that:
- Secret `ANDROID_KEYSTORE_BASE64` exists
- Directory `android/app/keys/` exists (create in workflow)

#### 3. iOS Build Fails: "Code signing failed"

**Solution:** Verify certificates and profiles:
```yaml
- name: Import certificate
  run: |
    echo "${{ secrets.IOS_CERTIFICATE_BASE64 }}" | base64 -d > certificate.p12
    security create-keychain -p "" build.keychain
    security import certificate.p12 -k build.keychain -P "${{ secrets.IOS_CERTIFICATE_PASSWORD }}" -T /usr/bin/codesign
    security set-keychain-settings -lut 21600 build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "" build.keychain
```

#### 4. Tests Fail: "Hive is not initialized"

**Solution:** Initialize Hive in test setup:
```dart
// test/setup.dart
void setupTests() {
  final tempDir = Directory.systemTemp.createTempSync();
  Hive.init(tempDir.path);
}
```

#### 5. Workflow Timeout

**Solution:** Increase timeout:
```yaml
jobs:
  build:
    timeout-minutes: 30  # Default is 60
```

Or optimize build:
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.pub-cache
      ${{ env.FLUTTER_HOME }}/.pub-cache
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
```

#### 6. Artifact Upload Fails

**Solution:** Check artifact size (max 500 MB per artifact):
```yaml
- name: Upload AAB
  uses: actions/upload-artifact@v4
  with:
    name: app-release
    path: build/app/outputs/bundle/release/app-release.aab
    retention-days: 30
    if-no-files-found: error
```

### Debugging Workflows

**Enable debug logging:**
```bash
# Set secrets in repository settings:
ACTIONS_STEP_DEBUG = true
ACTIONS_RUNNER_DEBUG = true
```

**Re-run workflow with debug:**
1. Go to failed workflow run
2. Click **Re-run all jobs** > **Enable debug logging**
3. View detailed logs

**Access runner via SSH (debugging):**
```yaml
- name: Setup tmate session
  if: failure()
  uses: mxschmitt/action-tmate@v3
  timeout-minutes: 15
```

This creates an SSH session to the runner for debugging.

---

## Performance Optimization

### Cache Dependencies

```yaml
- name: Cache Flutter SDK
  uses: actions/cache@v4
  with:
    path: /opt/hostedtoolcache/flutter
    key: ${{ runner.os }}-flutter-${{ env.FLUTTER_VERSION }}

- name: Cache Pub Dependencies
  uses: actions/cache@v4
  with:
    path: |
      ~/.pub-cache
      ${{ github.workspace }}/.dart_tool
    key: ${{ runner.os }}-pub-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-pub-
```

**Speed improvement:** 2-5 minutes per build

### Parallel Jobs

```yaml
jobs:
  test:
    # ...

  build-android:
    needs: test
    # ...

  build-ios:
    needs: test
    # runs in parallel with build-android
    # ...
```

**Speed improvement:** 10-20 minutes (Android + iOS in parallel)

### Matrix Builds

```yaml
strategy:
  matrix:
    flutter-version: ['3.19.0', '3.x']
    os: [ubuntu-latest, macos-latest]

steps:
  - uses: subosito/flutter-action@v2
    with:
      flutter-version: ${{ matrix.flutter-version }}
```

Test across multiple Flutter versions and platforms.

---

## Cost Optimization

### GitHub Actions Pricing

**Free tier (Public repositories):**
- ✅ Unlimited minutes for public repos
- ✅ All features available

**Free tier (Private repositories):**
- ✅ 2,000 minutes/month Linux
- ✅ Included storage: 500 MB

**Paid plans:**
- Linux: $0.008/minute
- macOS: $0.08/minute (10x Linux)
- Windows: $0.016/minute

### Reducing Costs

1. **Use Linux runners** when possible (Android builds)
2. **Use self-hosted runners** for iOS (free, requires macOS)
3. **Cache dependencies** aggressively
4. **Skip unnecessary workflows** (paths-ignore)
5. **Limit concurrent runs** (concurrency groups)

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true  # Cancel previous runs
```

---

## Self-Hosted Runners

For iOS builds and cost savings, consider self-hosted runners.

### Setting Up Self-Hosted Runner (macOS)

**Requirements:**
- macOS 11+ (Big Sur or later)
- Xcode 15+
- Administrator access

**Setup:**

1. GitHub > Settings > Actions > Runners > New runner
2. Select macOS
3. Download and configure:

```bash
# Create directory
mkdir actions-runner && cd actions-runner

# Download runner
curl -o actions-runner-osx-x64-2.311.0.tar.gz \
  -L https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-osx-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-osx-x64-2.311.0.tar.gz

# Configure
./config.sh --url https://github.com/YOUR_USERNAME/ephenotes --token YOUR_TOKEN

# Install as service
./svc.sh install

# Start service
./svc.sh start
```

**Use in workflow:**
```yaml
runs-on: self-hosted  # Instead of macos-latest
```

**Benefits:**
- ✅ Free (no per-minute charges)
- ✅ Faster builds (local cache)
- ✅ Custom environment setup

**Considerations:**
- ⚠️ Requires maintaining hardware
- ⚠️ Security: Only use for trusted repositories
- ⚠️ Availability: Machine must be online

---

## Additional Resources

### Official Documentation

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Flutter CI/CD Guide](https://docs.flutter.dev/deployment/cd)
- [Fastlane for Flutter](https://docs.fastlane.tools/)

### Useful Actions

- [flutter-action](https://github.com/subosito/flutter-action) - Setup Flutter
- [upload-artifact](https://github.com/actions/upload-artifact) - Upload build artifacts
- [cache](https://github.com/actions/cache) - Cache dependencies
- [checkout](https://github.com/actions/checkout) - Checkout repository

### Example Repositories

- [flutter/flutter](https://github.com/flutter/flutter) - Flutter framework CI
- [flutter/samples](https://github.com/flutter/samples) - Flutter samples CI

---

**Last Updated:** 2026-02-03
**Maintained By:** DevOps Team
**Review Frequency:** Monthly
