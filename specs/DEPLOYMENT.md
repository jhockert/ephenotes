# Deployment Guide

This guide covers the complete deployment process for ephenotes to both the iOS App Store and Google Play Store.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Build Configuration](#build-configuration)
3. [iOS App Store Deployment](#ios-app-store-deployment)
4. [Google Play Store Deployment](#google-play-store-deployment)
5. [Version Management](#version-management)
6. [Pre-Deployment Checklist](#pre-deployment-checklist)
7. [Post-Deployment Monitoring](#post-deployment-monitoring)
8. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts

- **Apple Developer Account** ($99/year)
  - Enrolled in Apple Developer Program
  - Agreement accepted in App Store Connect
  - Two-factor authentication enabled

- **Google Play Console Account** ($25 one-time fee)
  - Developer account created and verified
  - Payment profile set up
  - App signing configured

### Required Tools

```bash
# Flutter SDK (stable channel)
flutter --version  # Should be 3.x or higher

# Xcode (for iOS builds)
xcode-select --version  # Should be 15.x or higher

# Android Studio / Android SDK
sdkmanager --version

# Fastlane (optional but recommended)
fastlane --version
```

### Development Environment

- macOS (required for iOS builds)
- Xcode 15.0+ installed
- Android SDK 34+ installed
- Valid code signing certificates
- Valid provisioning profiles

---

## Build Configuration

### 1. Update Version Numbers

Version numbers must be updated in multiple locations before each release:

```yaml
# pubspec.yaml
version: 1.0.0+1  # Format: MAJOR.MINOR.PATCH+BUILD_NUMBER
```

**Version Format:**
- `MAJOR.MINOR.PATCH` - Semantic version (user-facing)
- `BUILD_NUMBER` - Incremental build number (app stores)

**Example progression:**
- `1.0.0+1` - Initial release
- `1.0.1+2` - Bug fix release
- `1.1.0+3` - Feature release
- `2.0.0+4` - Major version

### 2. Update App Metadata

#### iOS - Info.plist

Location: `ios/Runner/Info.plist`

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleDisplayName</key>
<string>ephenotes</string>
```

#### Android - build.gradle

Location: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.ephenotes.app"
        minSdkVersion 23
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### 3. Environment Configuration

Create release configuration files:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String appName = 'ephenotes';
  static const String version = '1.0.0';
  static const int buildNumber = 1;
  static const bool isProduction = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}
```

---

## iOS App Store Deployment

### Step 1: Configure Code Signing

#### 1.1 Create App ID

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Navigate to Certificates, Identifiers & Profiles
3. Create new App ID:
   - **Description:** ephenotes
   - **Bundle ID:** `com.ephenotes.app`
   - **Capabilities:** None required (app is offline-only)

#### 1.2 Create Distribution Certificate

```bash
# Generate certificate signing request (CSR)
# Open Keychain Access > Certificate Assistant > Request a Certificate from a Certificate Authority
# Save as: ephenotesDistribution.certSigningRequest

# Or use Fastlane
fastlane cert
```

1. Upload CSR to Apple Developer Portal
2. Download distribution certificate
3. Double-click to install in Keychain

#### 1.3 Create Provisioning Profile

1. In Apple Developer Portal, create new provisioning profile
2. Select: **App Store Distribution**
3. Select App ID: `com.ephenotes.app`
4. Select distribution certificate
5. Download and install: `ephenotes_AppStore.mobileprovision`

### Step 2: Configure Xcode Project

```bash
# Open Xcode project
open ios/Runner.xcworkspace
```

#### 2.1 Signing & Capabilities

1. Select **Runner** target
2. Go to **Signing & Capabilities** tab
3. **Automatically manage signing:** Disabled
4. **Team:** Select your Apple Developer team
5. **Provisioning Profile:** Select downloaded profile

#### 2.2 Build Settings

- **Product Bundle Identifier:** `com.ephenotes.app`
- **Code Signing Identity:** Apple Distribution
- **Development Team:** Your team ID
- **iOS Deployment Target:** 13.0

### Step 3: Build Release IPA

```bash
# Clean build folder
flutter clean

# Get dependencies
flutter pub get

# Build iOS release
flutter build ios --release --no-codesign

# Or build with Xcode
cd ios
xcodebuild -workspace Runner.xcworkspace \
           -scheme Runner \
           -configuration Release \
           -archivePath build/Runner.xcarchive \
           archive

# Export IPA for App Store
xcodebuild -exportArchive \
           -archivePath build/Runner.xcarchive \
           -exportPath build/Release-iphoneos \
           -exportOptionsPlist ExportOptions.plist
```

#### ExportOptions.plist Template

Location: `ios/ExportOptions.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
</dict>
</plist>
```

### Step 4: Upload to App Store Connect

#### 4.1 Using Transporter App

1. Download **Transporter** from Mac App Store
2. Sign in with Apple ID
3. Drag and drop `.ipa` file
4. Click **Deliver**
5. Wait for processing (10-60 minutes)

#### 4.2 Using Command Line

```bash
# Install Apple's Application Loader tools
xcrun altool --upload-app \
             --type ios \
             --file build/Release-iphoneos/Runner.ipa \
             --username your-apple-id@email.com \
             --password "app-specific-password"
```

#### 4.3 Using Fastlane (Recommended)

```bash
# Install Fastlane
sudo gem install fastlane

# Initialize Fastlane
cd ios
fastlane init

# Upload build
fastlane pilot upload
```

### Step 5: Configure App Store Connect

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **My Apps** > **+** > **New App**

#### 5.1 App Information

- **Name:** ephenotes
- **Bundle ID:** `com.ephenotes.app`
- **SKU:** `ephenotes-ios-001`
- **Primary Language:** English (U.S.)
- **User Access:** Full Access

#### 5.2 Pricing and Availability

- **Price:** Free
- **Availability:** All countries
- **App Availability:** Make this app available

#### 5.3 App Privacy

Create privacy policy (see [PRIVACY_POLICY.md](PRIVACY_POLICY.md)):

**Data Collection:** None
- App does not collect any user data
- App does not track users
- All data stored locally on device
- No third-party SDKs with data collection

**Privacy Labels:**
- Data Not Collected: ✅ (All categories)

#### 5.4 Prepare for Submission

**Screenshots Required:**

| Device Type | Size | Quantity |
|-------------|------|----------|
| 6.7" Display (iPhone 15 Pro Max) | 1290 x 2796 | 3-10 |
| 6.5" Display (iPhone 14 Plus) | 1242 x 2688 | 3-10 |
| 5.5" Display (iPhone 8 Plus) | 1242 x 2208 | 3-10 |
| 12.9" iPad Pro | 2048 x 2732 | 3-10 |

**App Preview Video (Optional):**
- Format: .mov, .mp4, .m4v
- Duration: 15-30 seconds
- Resolution: Match screenshot sizes

**App Icon:**
- Size: 1024 x 1024 px
- Format: PNG (no transparency)
- Color space: sRGB or P3

**Description:**

```
ephenotes - Quick Notes for Ephemeral Thoughts

Capture fleeting ideas with lightning-fast note creation. Each note is limited to 140 characters, forcing you to distill thoughts to their essence.

Features:
✓ 140-character limit for concise notes
✓ Search with real-time filtering
✓ Archive with undo
✓ Pin important notes
✓ Color and icon categorization
✓ Priority system (high, medium, low)
✓ Manual reordering with drag-and-drop
✓ Dark mode support
✓ Fully accessible (VoiceOver support)
✓ 100% local storage - your data stays on your device

Perfect for:
• Quick reminders
• Shopping lists
• Daily tasks
• Ideas and inspiration
• Meeting notes

Privacy First:
- No account required
- No data collection
- No internet connection needed
- No ads, no tracking

Simple. Fast. Private.
```

**Keywords:**
```
notes,quick notes,todo,reminders,notebook,notepad,tasks,lists,productivity,minimal
```

**Support URL:** `https://ephenotes.app/support`
**Marketing URL:** `https://ephenotes.app`

**Version Information:**
- **Version:** 1.0.0
- **Copyright:** © 2026 ephenotes
- **Age Rating:** 4+

#### 5.5 App Review Information

**Contact Information:**
- First Name: [Your Name]
- Last Name: [Your Name]
- Phone: [Your Phone]
- Email: [Your Email]

**Notes for Review:**

```
Thank you for reviewing ephenotes!

This is a simple, offline note-taking app with no account system or data collection.

To test the app:
1. Tap the "+" button to create a new note
2. Type up to 140 characters
3. Tap "Save" to create the note
4. Swipe left on a note to archive it
5. Tap "Undo" to restore an archived note
6. Long-press a note to see pin/delete options
7. Tap the search icon to filter notes
8. Long-press and drag notes to reorder them

The app works completely offline and does not require any special permissions or accounts.

No demo account needed - the app works immediately after launch.
```

### Step 6: Submit for Review

1. Select build version from **App Store Connect**
2. Complete all required fields (metadata, screenshots, description)
3. Answer App Review questions
4. Submit export compliance documentation:
   - **Uses Encryption:** No (app is offline-only)
5. Click **Submit for Review**

**Review Timeline:**
- Typical: 24-48 hours
- First submission: May take 3-5 days
- Rejections: Address issues and resubmit

### Step 7: TestFlight Beta (Optional)

Before production release, test with TestFlight:

```bash
# Upload build (same as production)
fastlane pilot upload

# Add internal testers (up to 100)
# Add external testers (up to 10,000, requires App Review)
```

1. Go to **TestFlight** tab in App Store Connect
2. Add **Internal Testing** group
3. Add **External Testing** group (requires review)
4. Send beta invitation emails
5. Collect feedback before production release

---

## Google Play Store Deployment

### Step 1: Configure App Signing

#### 1.1 Generate Upload Keystore

```bash
# Create keystore directory
mkdir -p android/app/keys

# Generate keystore
keytool -genkey -v \
        -storetype PKCS12 \
        -keystore android/app/keys/upload-keystore.jks \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -alias upload \
        -storepass "YOUR_STORE_PASSWORD" \
        -keypass "YOUR_KEY_PASSWORD" \
        -dname "CN=ephenotes, OU=Mobile, O=ephenotes, L=City, ST=State, C=US"

# Backup keystore securely
# Store in password manager + encrypted backup
```

**CRITICAL:**
- Never commit keystore to version control
- Store passwords in secure password manager
- Keep encrypted backup in multiple locations
- If lost, you cannot update your app!

#### 1.2 Configure key.properties

Location: `android/key.properties` (add to .gitignore)

```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=keys/upload-keystore.jks
```

#### 1.3 Update build.gradle

Location: `android/app/build.gradle`

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 1.4 Configure ProGuard Rules

Location: `android/app/proguard-rules.pro`

```proguard
# Hive
-keep class * extends com.hivedb.HiveObjectAdapter
-keep class com.ephenotes.data.models.** { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
```

### Step 2: Build Release APK/AAB

```bash
# Clean build
flutter clean
flutter pub get

# Build App Bundle (AAB) - REQUIRED for Play Store
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab

# Optional: Build APK for testing
flutter build apk --release --split-per-abi

# Outputs:
# build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
# build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
# build/app/outputs/flutter-apk/app-x86_64-release.apk
```

**File Sizes (approximate):**
- AAB: ~15-20 MB
- APK (arm64): ~25-30 MB
- APK (split): ~10-15 MB each

### Step 3: Create Google Play Console App

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**

#### 3.1 App Details

- **App name:** ephenotes
- **Default language:** English (United States)
- **App or game:** App
- **Free or paid:** Free

#### 3.2 Declarations

- [ ] This app complies with Google Play policies
- [ ] This app is not primarily directed at children under 13
- [ ] Developer account is based in a supported location
- [ ] This app complies with US export laws

### Step 4: Set Up App Store Listing

#### 4.1 Main Store Listing

**App name:** ephenotes

**Short description (80 chars):**
```
Quick notes for ephemeral thoughts. 140 characters. No account. No tracking.
```

**Full description (4000 chars):**
```
ephenotes - Quick Notes for Ephemeral Thoughts

Capture fleeting ideas with lightning-fast note creation. Each note is limited to 140 characters, forcing you to distill thoughts to their essence.

✨ KEY FEATURES

📝 140-Character Limit
Keep it concise. Every note is limited to 140 characters, helping you focus on what matters.

🔍 Instant Search
Find notes in real-time as you type. Search is fast and responsive.

📦 Archive with Undo
Swipe to archive notes you don't need anymore. Undo anytime within 5 seconds.

📌 Pin Important Notes
Keep critical notes at the top of your list.

🎨 Color & Icon Categorization
Organize notes with 10 colors and 7 icon categories (work, personal, shopping, health, finance, important, ideas).

⭐ Priority System
Mark notes as high, medium, or low priority for better organization.

🔄 Manual Reordering
Long-press and drag notes to arrange them exactly how you want.

🌙 Dark Mode
Automatic dark mode support for comfortable viewing at any time.

♿ Fully Accessible
Complete VoiceOver and TalkBack support for users with visual impairments.

🔒 PRIVACY FIRST

• No account required
• No data collection
• No internet connection needed
• All notes stored locally on your device
• No ads, no tracking, no analytics
• Open source and transparent

🎯 PERFECT FOR

• Quick reminders
• Shopping lists
• Daily tasks
• Ideas and inspiration
• Meeting notes
• Grocery lists
• To-do items

📱 DESIGNED FOR SIMPLICITY

ephenotes has one job: help you capture thoughts quickly. No complex features. No overwhelming options. Just fast, simple note-taking.

The 140-character limit isn't a restriction—it's a feature. It forces you to think clearly and write concisely.

🌟 WHY EPHENOTES?

Most note apps are bloated with features you'll never use. ephenotes does one thing exceptionally well: capturing short, ephemeral thoughts.

Whether it's a quick reminder, a shopping item, or a fleeting idea, ephenotes gets out of your way and lets you focus.

💾 100% LOCAL STORAGE

Your notes never leave your device. No cloud sync means no data breaches, no privacy concerns, and no monthly subscriptions.

Download ephenotes today and experience the joy of simple, focused note-taking.
```

**App icon:**
- Size: 512 x 512 px
- Format: PNG (32-bit)
- File size: < 1 MB

**Feature graphic:**
- Size: 1024 x 500 px
- Format: PNG or JPEG
- Content: App name + tagline + visual

**Phone screenshots (REQUIRED - 2-8 screenshots):**
- Size: Minimum 320px, maximum 3840px
- Aspect ratio: 16:9 or 9:16
- Format: PNG or JPEG

**7-inch tablet screenshots (OPTIONAL):**
- Size: Minimum 1024px on smallest side
- Format: PNG or JPEG

**10-inch tablet screenshots (OPTIONAL):**
- Size: Minimum 1280px on smallest side
- Format: PNG or JPEG

**App category:**
- **Primary:** Productivity
- **Secondary:** Tools

**Tags:**
```
note-taking, productivity, reminders, todo, tasks
```

**Contact details:**
- Email: support@ephenotes.app
- Phone: (Optional)
- Website: https://ephenotes.app

**Privacy policy URL:**
- https://ephenotes.app/privacy-policy

#### 4.2 Store Settings

**App access:**
- [ ] All functionality is available without special access

**Ads:**
- [ ] No, this app does not contain ads

**Content rating:**
- Target age: Everyone
- Content: No sensitive content

**Target audience:**
- Primary: Adults 18+
- Secondary: Teens 13-17

**News app:**
- [ ] No, this is not a news app

### Step 5: Complete Data Safety Form

**Data collection and security:**

1. **Does your app collect or share user data?**
   - ✅ No, this app doesn't collect or share user data

2. **Does your app follow security best practices?**
   - ✅ Yes
   - ✅ Data is encrypted in transit (N/A - offline app)
   - ✅ Users can request data deletion (data is local-only)
   - ✅ Committed to Google Play Families Policy (if applicable)
   - ✅ Validated data safety section

3. **Privacy policy:**
   - URL: https://ephenotes.app/privacy-policy

**Data types collected:** None

This makes app review much faster!

### Step 6: Upload App Bundle

1. Go to **Production** > **Create new release**
2. Upload `app-release.aab`
3. Release name: `1.0.0 - Initial Release`
4. Release notes:

```
Initial release of ephenotes!

Features:
• 140-character note limit for concise thoughts
• Search notes with real-time filtering
• Archive notes with undo functionality
• Pin important notes to the top
• Color and icon categorization
• Priority system (high, medium, low)
• Manual reordering with drag-and-drop
• Dark mode support
• Fully accessible (TalkBack support)
• 100% local storage - no account needed

Privacy:
• No data collection
• No internet required
• No ads or tracking
• All notes stored locally

We hope you enjoy ephenotes!
```

### Step 7: Content Rating

1. Go to **Content rating**
2. Start questionnaire
3. Select **Utilities, Productivity, Communication, or Others**
4. Answer all questions truthfully:
   - Violence: None
   - Sexual content: None
   - Profanity: None
   - Controlled substances: None
   - User interaction: None (offline app)
   - Shares user data: No
5. Submit for rating

Expected rating: **Everyone** (ESRB E, PEGI 3)

### Step 8: Pricing & Distribution

**Countries:**
- ✅ Available in all countries

**Pricing:**
- Free

**Contain ads:**
- No

**In-app purchases:**
- No

**Content guidelines:**
- ✅ App complies with all guidelines
- ✅ Export laws compliance (US, EU)
- ✅ Not primarily directed at children

**Device categories:**
- ✅ Phone
- ✅ Tablet
- ✅ Chromebook

### Step 9: Submit for Review

1. Review all sections (all must have green checkmarks)
2. Click **Review release**
3. Verify all information
4. Click **Start rollout to Production**

**Review timeline:**
- Typical: 3-7 days
- First submission: Up to 14 days
- Policy violations: May require changes and resubmission

### Step 10: Staged Rollout (Optional)

Instead of releasing to 100% of users immediately:

1. Select **Staged rollout**
2. Choose percentage (20% → 50% → 100%)
3. Monitor crash reports and ratings
4. Gradually increase percentage

**Recommended rollout schedule:**
- Day 1-3: 20% of users
- Day 4-7: 50% of users
- Day 8+: 100% of users

---

## Version Management

### Semantic Versioning

Follow [semver.org](https://semver.org):

**Format:** `MAJOR.MINOR.PATCH`

- **MAJOR:** Breaking changes (1.0.0 → 2.0.0)
- **MINOR:** New features, backwards-compatible (1.0.0 → 1.1.0)
- **PATCH:** Bug fixes (1.0.0 → 1.0.1)

**Build numbers** increment with every release:

```
1.0.0+1  → Initial release
1.0.1+2  → Bug fix
1.0.2+3  → Another bug fix
1.1.0+4  → New feature
2.0.0+5  → Breaking change
```

### Release Workflow

```bash
# 1. Update version in pubspec.yaml
# pubspec.yaml: version: 1.1.0+4

# 2. Update CHANGELOG.md
# Add new version section

# 3. Commit changes
git add pubspec.yaml CHANGELOG.md
git commit -m "Bump version to 1.1.0+4"

# 4. Create git tag
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0

# 5. Build releases
flutter build ios --release
flutter build appbundle --release

# 6. Upload to stores
# (Follow iOS/Android steps above)
```

### Versioning Checklist

Before releasing:

- [ ] Version bumped in `pubspec.yaml`
- [ ] iOS version updated in `Info.plist`
- [ ] Android version updated in `build.gradle`
- [ ] CHANGELOG.md updated with changes
- [ ] Git tag created
- [ ] Release notes written
- [ ] Screenshots updated (if UI changed)

---

## Pre-Deployment Checklist

### Code Quality

- [ ] All tests passing (`flutter test`)
- [ ] Zero analyzer warnings (`flutter analyze`)
- [ ] Code formatted (`flutter format .`)
- [ ] No debug code or console.log statements
- [ ] No hardcoded secrets or API keys

### Build Verification

- [ ] Release build succeeds (iOS)
- [ ] Release build succeeds (Android)
- [ ] App launches without crashes
- [ ] All features working in release mode
- [ ] Performance acceptable (60 FPS)
- [ ] App size within limits (< 100 MB)

### Testing

- [ ] Manual testing on physical iOS device
- [ ] Manual testing on physical Android device
- [ ] Tested on minimum supported OS versions (iOS 13, Android 6)
- [ ] Tested in dark mode
- [ ] Tested with VoiceOver/TalkBack
- [ ] Tested with different screen sizes
- [ ] Tested edge cases (empty states, long text, etc.)

### Compliance

- [ ] Privacy policy published and linked
- [ ] Terms of service published (if required)
- [ ] App store guidelines reviewed
- [ ] Content rating appropriate
- [ ] Export compliance documented
- [ ] COPPA compliance verified (if targeting children)
- [ ] GDPR compliance verified (if available in EU)

### Store Assets

- [ ] App icon finalized (1024x1024)
- [ ] Screenshots captured for all required sizes
- [ ] Feature graphic created (Android)
- [ ] App description written
- [ ] Keywords optimized
- [ ] Support email configured
- [ ] Website URL set
- [ ] Release notes written

### Security

- [ ] No sensitive data in app bundle
- [ ] Code obfuscation enabled (Android)
- [ ] Keystore backed up securely
- [ ] Certificates backed up securely
- [ ] .gitignore configured properly
- [ ] No API keys in source code

---

## Post-Deployment Monitoring

### First 24 Hours

Monitor closely after release:

1. **Crash reports**
   - Check Firebase Crashlytics
   - Check App Store Connect / Play Console crash reporting
   - Respond to crashes within 4 hours

2. **User reviews**
   - Monitor 1-star reviews
   - Respond to user feedback
   - Address critical bugs immediately

3. **Performance metrics**
   - App launch time
   - Memory usage
   - Battery consumption
   - Network errors (should be zero for offline app)

4. **Download metrics**
   - Installation count
   - Retention rate (Day 1, Day 7, Day 30)
   - Uninstall rate

### Ongoing Monitoring

**Weekly:**
- Review crash-free users percentage (target: 99.5%+)
- Check user ratings (target: 4.0+ stars)
- Read new reviews and respond
- Monitor app size growth
- Check for OS compatibility issues

**Monthly:**
- Analyze user retention
- Review feature usage
- Plan next release
- Update dependencies
- Security audit

### Hotfix Process

If critical bug discovered:

```bash
# 1. Create hotfix branch
git checkout -b hotfix/1.0.1

# 2. Fix bug
# ... make changes ...

# 3. Bump patch version
# pubspec.yaml: 1.0.0+1 → 1.0.1+2

# 4. Test thoroughly
flutter test

# 5. Build and deploy
flutter build ios --release
flutter build appbundle --release

# 6. Submit expedited review
# iOS: Request expedited review in App Store Connect
# Android: Usually auto-approved within 24 hours

# 7. Monitor deployment
# Wait for approval and rollout

# 8. Merge to main
git checkout main
git merge hotfix/1.0.1
git push origin main
```

**Expedited Review (iOS):**
- Available for critical bugs only
- Explain severity in review notes
- Typical review time: 2-4 hours

---

## Troubleshooting

### iOS Issues

#### "Code signing failed"

```bash
# Clean derived data
rm -rf ~/Library/Developer/Xcode/DerivedData

# Re-download provisioning profiles
open "https://developer.apple.com/account/resources/profiles/list"

# Verify certificate in Keychain
security find-identity -v -p codesigning
```

#### "Archive build failed"

```bash
# Clean Flutter build
flutter clean
flutter pub get

# Clean Xcode build
cd ios
xcodebuild clean

# Rebuild
flutter build ios --release
```

#### "App Store Connect upload failed"

- Verify app-specific password is correct
- Check that bundle ID matches App Store Connect
- Ensure version/build number is higher than previous

### Android Issues

#### "Keystore password incorrect"

```bash
# Verify keystore exists
ls -la android/app/keys/

# Test keystore password
keytool -list -v \
        -keystore android/app/keys/upload-keystore.jks \
        -alias upload
```

#### "App not released"

Check Play Console for:
- All store listing sections completed (green checkmarks)
- Content rating submitted
- Pricing & distribution configured
- App bundle uploaded and reviewed

#### "APK/AAB rejected"

Common reasons:
- Privacy policy URL not working
- Missing data safety declarations
- Content rating incomplete
- Policy violations (requires fixing)

### General Issues

#### "Build too large"

```bash
# Enable code splitting
flutter build apk --release --split-per-abi

# Enable ProGuard minification (Android)
# Already configured in build.gradle

# Remove unused dependencies
flutter pub outdated
flutter pub upgrade
```

#### "App crashes on launch"

```bash
# Test release build locally
flutter run --release

# Check crash logs
# iOS: Xcode > Window > Devices and Simulators > View Device Logs
# Android: adb logcat

# Enable crash reporting
# Add Firebase Crashlytics (see MONITORING.md)
```

---

## Useful Commands

```bash
# Check Flutter setup
flutter doctor -v

# Build iOS release
flutter build ios --release --no-codesign

# Build Android AAB
flutter build appbundle --release

# Build Android APK (all architectures)
flutter build apk --release --split-per-abi

# Analyze code
flutter analyze

# Run tests
flutter test

# Check app size
flutter build appbundle --release --analyze-size
flutter build ios --release --analyze-size

# Clean build artifacts
flutter clean

# Update dependencies
flutter pub upgrade

# Generate app icons
flutter pub run flutter_launcher_icons:main
```

---

## Additional Resources

### Official Documentation

- [Flutter Deployment](https://docs.flutter.dev/deployment)
- [iOS App Distribution Guide](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/help/app-store-connect)

### Tools

- [Fastlane](https://fastlane.tools) - Automate deployment
- [Codemagic](https://codemagic.io) - CI/CD for Flutter
- [Transporter](https://apps.apple.com/app/transporter/id1450874784) - Upload to App Store
- [Firebase App Distribution](https://firebase.google.com/products/app-distribution) - Beta testing

### App Store Optimization (ASO)

- [App Annie](https://www.appannie.com) - Market intelligence
- [Sensor Tower](https://sensortower.com) - ASO tools
- [The Tool](https://thetool.io) - Keyword research

---

**Last Updated:** 2026-02-03
**Next Review:** Before first production release
