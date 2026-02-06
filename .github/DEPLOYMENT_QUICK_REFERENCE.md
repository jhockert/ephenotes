# Deployment Quick Reference

## 🚀 One-Command Deployments

### TestFlight (iOS Beta)

```bash
# 1. Update version and generate notes
./scripts/version_manager.sh bump patch
./scripts/generate_release_notes.sh store $(git describe --tags --abbrev=0) HEAD ios

# 2. Commit and push
git add . && git commit -m "Release $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"
git push

# 3. Deploy via GitHub Actions UI
# Actions > Deploy to App Stores > Run workflow
# Target: testflight
```

### Play Store Internal Testing

```bash
# 1. Update version and generate notes
./scripts/version_manager.sh bump patch
./scripts/generate_release_notes.sh store $(git describe --tags --abbrev=0) HEAD android

# 2. Commit and push
git add . && git commit -m "Release $(grep '^version:' pubspec.yaml | cut -d' ' -f2)"
git push

# 3. Deploy via GitHub Actions UI
# Actions > Deploy to App Stores > Run workflow
# Target: playstore-internal
```

---

## 📋 Common Commands

### Version Management

```bash
# Check current version
./scripts/version_manager.sh current

# Bump patch (1.0.0 → 1.0.1)
./scripts/version_manager.sh bump patch

# Bump minor (1.0.0 → 1.1.0)
./scripts/version_manager.sh bump minor

# Bump major (1.0.0 → 2.0.0)
./scripts/version_manager.sh bump major

# Set specific version
./scripts/version_manager.sh set 1.2.3 42
```

### Release Notes

```bash
# Generate for both stores
./scripts/generate_release_notes.sh store v1.0.0 HEAD both

# Generate full release notes
./scripts/generate_release_notes.sh full v1.0.0 HEAD

# Generate for specific store
./scripts/generate_release_notes.sh store v1.0.0 HEAD appstore
./scripts/generate_release_notes.sh store v1.0.0 HEAD playstore
```

### Local Deployment (Fastlane)

```bash
# iOS TestFlight
cd ios && fastlane deploy_beta

# Android Internal
cd android && fastlane deploy_internal

# Android Beta
cd android && fastlane deploy_beta
```

### Security Scanning

```bash
# Run all security checks
flutter analyze
flutter pub outdated
dart pub audit

# Or trigger via GitHub Actions
# Actions > Security Scan > Run workflow
```

---

## 🎯 Deployment Targets

| Target | Platform | Command | Review Time |
|--------|----------|---------|-------------|
| `testflight` | iOS | Beta testing | ~30 min |
| `appstore` | iOS | Production | 1-3 days |
| `playstore-internal` | Android | Internal testing | ~15 min |
| `playstore-beta` | Android | Open beta | ~15 min |
| `playstore-production` | Android | Production | 1-7 days |

---

## 🔐 Required Secrets

### Android (5 secrets)
- `ANDROID_KEYSTORE_BASE64`
- `ANDROID_KEY_ALIAS`
- `ANDROID_KEY_PASSWORD`
- `ANDROID_STORE_PASSWORD`
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`

### iOS (4 secrets)
- `IOS_CERTIFICATE_BASE64`
- `IOS_CERTIFICATE_PASSWORD`
- `IOS_PROVISIONING_PROFILE_BASE64`
- `IOS_TEAM_ID`

### Optional (3 secrets)
- `APP_STORE_CONNECT_API_KEY_BASE64`
- `APP_STORE_CONNECT_API_KEY_ID`
- `APP_STORE_CONNECT_ISSUER_ID`

---

## ✅ Pre-Deployment Checklist

- [ ] All tests passing (`flutter test`)
- [ ] Code analyzed (`flutter analyze`)
- [ ] Version updated
- [ ] Release notes generated
- [ ] Security scan passed
- [ ] Tested on devices
- [ ] Secrets configured

---

## 🐛 Quick Troubleshooting

### Fastlane not found
```bash
sudo gem install fastlane
```

### Version conflict
```bash
./scripts/version_manager.sh bump patch
```

### iOS signing error
```bash
security find-identity -v -p codesigning
```

### Android upload failed
```bash
# Check service account has "Release Manager" role
# Verify JSON key is valid
```

---

## 📚 Full Documentation

- [Complete Deployment Guide](.github/DEPLOYMENT_AUTOMATION.md)
- [CI/CD Setup Guide](.github/CI_CD_SETUP.md)
- [Quick Start Guide](.github/QUICK_START.md)

---

**Need Help?** Check workflow logs in GitHub Actions or review the full documentation.

