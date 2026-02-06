# Security Policy

This document outlines security practices, vulnerability reporting, and security audit procedures for ephenotes.

## Table of Contents

1. [Security Overview](#security-overview)
2. [Supported Versions](#supported-versions)
3. [Reporting a Vulnerability](#reporting-a-vulnerability)
4. [Security Best Practices](#security-best-practices)
5. [Security Audit Checklist](#security-audit-checklist)
6. [Threat Model](#threat-model)
7. [Security Testing](#security-testing)
8. [Compliance](#compliance)

---

## Security Overview

ephenotes prioritizes user privacy and data security through:

- **Local-Only Storage**: All data stored on device, no cloud sync
- **No Data Collection**: Zero telemetry, analytics, or tracking
- **No Network Access**: App functions completely offline
- **Open Source**: Transparent and auditable codebase
- **Minimal Permissions**: No camera, location, or contacts access
- **Regular Audits**: Quarterly security reviews

**Security Architecture Principles:**

1. **Privacy by Design**: No user data leaves the device
2. **Defense in Depth**: Multiple security layers
3. **Least Privilege**: Minimal permissions requested
4. **Fail Secure**: Errors don't expose data
5. **Transparency**: Open source and documented

---

## Supported Versions

Security updates are provided for the following versions:

| Version | Supported          | End of Support |
| ------- | ------------------ | -------------- |
| 1.x.x   | ✅ Yes             | TBD            |
| < 1.0   | ❌ No (pre-release)| 2026-03-01     |

**Update Policy:**
- Critical security fixes: Released within 48 hours
- High severity: Released within 7 days
- Medium severity: Included in next minor release
- Low severity: Included in next patch release

---

## Reporting a Vulnerability

### How to Report

**DO NOT** open a public GitHub issue for security vulnerabilities.

Instead, please email security-related issues to:

**Email:** security@ephenotes.app

**Subject:** `[SECURITY] Brief description`

**Include in your report:**
1. Description of the vulnerability
2. Steps to reproduce
3. Affected versions
4. Potential impact
5. Suggested fix (if any)
6. Your contact information

### What to Expect

1. **Acknowledgment**: Within 24 hours
2. **Initial Assessment**: Within 48 hours
3. **Status Update**: Within 7 days
4. **Fix Timeline**: Depends on severity
5. **Public Disclosure**: After fix is released

**Response Timeline:**

| Severity | Acknowledgment | Fix Target | Disclosure |
|----------|---------------|-----------|------------|
| Critical | < 24 hours | < 48 hours | After fix |
| High | < 24 hours | < 7 days | After fix |
| Medium | < 48 hours | < 30 days | After fix |
| Low | < 7 days | Next release | After fix |

### Disclosure Policy

We follow **Responsible Disclosure**:

1. Reporter notifies us privately
2. We investigate and develop a fix
3. We release the fix to all users
4. Public disclosure after 90% of users have updated
5. Credit given to reporter (if desired)

**Bug Bounty:** Currently not available (may be added in future)

---

## Security Best Practices

### For Users

1. **Keep Updated**
   - Install security updates promptly
   - Enable auto-updates in app stores
   - Check for updates monthly

2. **Device Security**
   - Use device lock screen (PIN, fingerprint, Face ID)
   - Keep iOS/Android updated
   - Don't jailbreak/root your device

3. **Data Backup**
   - Back up device regularly
   - Use encrypted backups
   - Store backups securely

4. **App Permissions**
   - Review app permissions (should be none for ephenotes)
   - Deny any unexpected permission requests

### For Developers

1. **Code Security**
   - Never commit secrets to repository
   - Use `.gitignore` for sensitive files
   - Review all third-party dependencies
   - Run `flutter analyze` before every commit

2. **Dependency Management**
   - Keep Flutter and dependencies updated
   - Audit dependencies quarterly
   - Use `flutter pub outdated` to check updates
   - Review dependency changelogs for security fixes

3. **Build Security**
   - Use separate keystores/certificates for dev/prod
   - Store production keys in secure vault
   - Never share private keys
   - Rotate signing keys annually

4. **Code Review**
   - All code changes require review
   - Security-sensitive changes require 2+ reviews
   - Use automated security scanning
   - Test for common vulnerabilities

---

## Security Audit Checklist

### Pre-Release Security Audit

Run this checklist before every release:

#### 1. Code Security

- [ ] **No Hardcoded Secrets**
  ```bash
  # Search for potential secrets
  grep -r "api_key" lib/
  grep -r "password" lib/
  grep -r "secret" lib/
  grep -r "token" lib/
  ```

- [ ] **No Debug Code**
  ```bash
  # Search for debug statements
  grep -r "print(" lib/
  grep -r "debugPrint" lib/
  grep -r "TODO" lib/
  grep -r "FIXME" lib/
  ```

- [ ] **Analyzer Passes**
  ```bash
  flutter analyze
  # Should return: No issues found!
  ```

- [ ] **No Unsafe Code Patterns**
  - No `eval()` or dynamic code execution
  - No SQL injection risks (using Hive, not SQL)
  - No XSS vulnerabilities (no web views)
  - No insecure deserialization

#### 2. Dependency Security

- [ ] **Dependencies Updated**
  ```bash
  flutter pub outdated
  flutter pub upgrade
  ```

- [ ] **Dependency Audit**
  ```bash
  # Check for known vulnerabilities (manual review)
  flutter pub deps
  ```

- [ ] **Review New Dependencies**
  - Verify package publisher reputation
  - Check package source code
  - Review security advisories
  - Confirm package license compatibility

#### 3. Data Security

- [ ] **Hive Box Encryption (Optional)**
  ```dart
  // If storing sensitive data, use encryption:
  final encryptionKey = Hive.generateSecureKey();
  await Hive.openBox('notes', encryptionCipher: HiveAesCipher(encryptionKey));
  ```
  **Note:** For ephenotes v1.0, encryption is not implemented as notes are not considered highly sensitive.

- [ ] **No Data Leakage**
  - No data sent to analytics
  - No data sent to crash reporting (in v1.0)
  - No data shared via intents/extensions
  - No data exposed in app snapshots

- [ ] **Secure Data Deletion**
  ```dart
  // Verify notes are properly deleted from Hive
  await noteBox.delete(key);
  await noteBox.compact();  // Reclaim space
  ```

#### 4. Permission Security

- [ ] **Minimal Permissions**
  ```xml
  <!-- android/app/src/main/AndroidManifest.xml -->
  <!-- Should have NO permissions beyond defaults -->
  ```

- [ ] **iOS Info.plist**
  ```xml
  <!-- ios/Runner/Info.plist -->
  <!-- Should have NO usage descriptions for permissions -->
  ```

- [ ] **No Network Access**
  ```bash
  # Verify no network calls
  grep -r "http://" lib/
  grep -r "https://" lib/
  grep -r "HttpClient" lib/
  grep -r "dio" lib/
  ```

#### 5. Platform Security

**Android:**

- [ ] **ProGuard/R8 Enabled**
  ```gradle
  // android/app/build.gradle
  buildTypes {
      release {
          minifyEnabled true
          shrinkResources true
      }
  }
  ```

- [ ] **Code Obfuscation**
  ```bash
  flutter build apk --obfuscate --split-debug-info=build/debug-info
  ```

- [ ] **App Signing**
  - Production keystore secured
  - Key passwords not committed
  - Keystore backed up securely

**iOS:**

- [ ] **Code Signing**
  - Distribution certificate valid
  - Provisioning profile correct
  - No debug provisioning profiles

- [ ] **App Transport Security**
  ```xml
  <!-- Info.plist - should NOT have ATS exceptions -->
  <!-- No NSAllowsArbitraryLoads: true -->
  ```

- [ ] **Bitcode Disabled** (Flutter requirement)
  ```
  ENABLE_BITCODE = NO
  ```

#### 6. Build Security

- [ ] **Release Build Only**
  ```bash
  # Never ship debug builds
  flutter build appbundle --release
  flutter build ios --release
  ```

- [ ] **No Debug Flags**
  - `kDebugMode` checks removed from production paths
  - No `--debug` flags in build commands
  - No developer menus accessible

- [ ] **Build Reproducibility**
  ```bash
  # Lock dependencies
  flutter pub get
  git add pubspec.lock
  ```

#### 7. Third-Party Code

- [ ] **Dependency Review**
  - Hive: ✅ Vetted, local database
  - GetIt: ✅ Vetted, dependency injection
  - Equatable: ✅ Vetted, value equality
  - Bloc: ✅ Vetted, state management
  - Mocktail: ✅ Vetted, dev dependency only

- [ ] **No Unnecessary Dependencies**
  ```bash
  # Review pubspec.yaml
  cat pubspec.yaml
  ```

- [ ] **License Compliance**
  ```bash
  flutter pub licenses
  ```

#### 8. Secure Coding

- [ ] **Input Validation**
  ```dart
  // Validate user input (140 char limit)
  if (text.length > 140) {
    return 'Note exceeds character limit';
  }
  ```

- [ ] **Error Handling**
  ```dart
  // Never expose sensitive info in errors
  try {
    await repository.save(note);
  } catch (e) {
    // Log error securely, show generic message to user
    logger.error('Failed to save note', error: e);
    return 'Unable to save note';
  }
  ```

- [ ] **Null Safety**
  ```bash
  # Verify null safety is enabled
  grep "sdk: '>=2.12.0" pubspec.yaml
  ```

#### 9. Privacy Compliance

- [ ] **Privacy Policy Published**
  - URL: https://ephenotes.app/privacy-policy
  - Clearly states no data collection
  - Updated within 6 months

- [ ] **App Store Privacy Labels**
  - iOS: "Data Not Collected" for all categories
  - Android: Data Safety form filled accurately

- [ ] **No Tracking**
  ```bash
  # Verify no tracking SDKs
  grep -r "firebase" pubspec.yaml
  grep -r "analytics" pubspec.yaml
  grep -r "mixpanel" pubspec.yaml
  ```

#### 10. Security Testing

- [ ] **Static Analysis**
  ```bash
  flutter analyze
  dart analyze --fatal-infos
  ```

- [ ] **Dependency Vulnerabilities**
  ```bash
  # Manual check of dependencies for CVEs
  # Check: https://cve.mitre.org/
  # Check: https://github.com/advisories
  ```

- [ ] **Manual Security Testing**
  - Test note encryption (if enabled)
  - Test data deletion (verify from Hive files)
  - Test app in airplane mode (should work)
  - Test app with network disabled (should work)

- [ ] **OWASP Mobile Top 10**
  - M1: Improper Platform Usage: ✅ N/A
  - M2: Insecure Data Storage: ✅ Local only
  - M3: Insecure Communication: ✅ No network
  - M4: Insecure Authentication: ✅ N/A (no auth)
  - M5: Insufficient Cryptography: ✅ Hive default
  - M6: Insecure Authorization: ✅ N/A
  - M7: Client Code Quality: ✅ Analyzed
  - M8: Code Tampering: ✅ Code signed
  - M9: Reverse Engineering: ✅ Obfuscated
  - M10: Extraneous Functionality: ✅ No debug code

---

## Threat Model

### Assets

1. **User Notes** (140-character text content)
2. **App Metadata** (colors, icons, priorities)
3. **Source Code** (open source, not secret)

### Threats

#### 1. Data Theft

**Threat:** Attacker accesses user's notes

**Mitigations:**
- Local-only storage (no cloud to breach)
- Device encryption (iOS/Android)
- App doesn't have network permission
- App doesn't use iCloud/Google Drive sync

**Residual Risk:** Low (requires physical device access)

#### 2. Data Loss

**Threat:** User loses notes due to app bug or device failure

**Mitigations:**
- Device backups include app data
- Hive database is crash-resistant
- Comprehensive testing (64% coverage)

**Residual Risk:** Medium (user must back up device)

#### 3. Code Injection

**Threat:** Attacker modifies app code

**Mitigations:**
- App is code-signed (iOS/Android)
- App Store / Play Store verification
- Users should only install from official stores

**Residual Risk:** Very Low (requires device compromise)

#### 4. Dependency Vulnerabilities

**Threat:** Third-party package has security flaw

**Mitigations:**
- Minimal dependencies (5 core packages)
- Regular updates (`flutter pub outdated`)
- Quarterly dependency audits
- Vetted, popular packages only

**Residual Risk:** Low (dependencies are stable, well-maintained)

#### 5. Supply Chain Attack

**Threat:** Compromised build pipeline or malicious contributor

**Mitigations:**
- GitHub Actions with secret management
- Code review required for all changes
- Signed commits recommended
- Build reproducibility via locked dependencies

**Residual Risk:** Low (open source, transparent)

#### 6. Physical Device Access

**Threat:** Attacker with physical device access reads notes

**Mitigations:**
- User should use device lock screen
- iOS/Android encrypt app data by default
- Optional: Implement app-level biometric lock (future)

**Residual Risk:** Medium (depends on user's device security)

### Threat Summary

| Threat | Likelihood | Impact | Risk | Mitigation Status |
|--------|-----------|--------|------|-------------------|
| Data Theft | Low | High | Medium | ✅ Mitigated |
| Data Loss | Medium | Medium | Medium | ⚠️ User-dependent |
| Code Injection | Very Low | High | Low | ✅ Mitigated |
| Dependency Vuln | Low | Medium | Low | ✅ Mitigated |
| Supply Chain | Very Low | High | Low | ✅ Mitigated |
| Physical Access | Medium | Medium | Medium | ⚠️ User-dependent |

---

## Security Testing

### Automated Testing

```bash
# Run before every release
./scripts/security_test.sh
```

**Script contents:**
```bash
#!/bin/bash

echo "🔒 Running Security Tests..."

# 1. Static analysis
echo "1️⃣ Running static analysis..."
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Static analysis failed"
  exit 1
fi

# 2. Check for secrets
echo "2️⃣ Scanning for hardcoded secrets..."
if grep -r "api_key\|password\|secret\|token" lib/ > /dev/null; then
  echo "❌ Potential secrets found in lib/"
  exit 1
fi

# 3. Check for debug code
echo "3️⃣ Scanning for debug code..."
DEBUG_COUNT=$(grep -r "print(\|debugPrint\|TODO\|FIXME" lib/ | wc -l)
if [ "$DEBUG_COUNT" -gt 0 ]; then
  echo "⚠️ Found $DEBUG_COUNT debug statements"
fi

# 4. Dependency check
echo "4️⃣ Checking dependencies..."
flutter pub outdated

# 5. Test coverage
echo "5️⃣ Running tests with coverage..."
flutter test --coverage
if [ $? -ne 0 ]; then
  echo "❌ Tests failed"
  exit 1
fi

echo "✅ Security tests passed!"
```

### Manual Testing

**Pre-Release Checklist:**

1. **Data Isolation Test**
   - Install app on device A
   - Create notes
   - Install app on device B
   - Verify device B does NOT see device A's notes

2. **Offline Test**
   - Enable airplane mode
   - Open app
   - Create/edit/delete notes
   - Verify all functionality works

3. **Data Deletion Test**
   - Create note
   - Delete note
   - Check Hive box files (using file explorer on rooted/jailbroken device)
   - Verify note data is removed

4. **Permission Test**
   - Check iOS Settings > ephenotes
   - Verify no permissions granted
   - Check Android Settings > Apps > ephenotes > Permissions
   - Verify no permissions granted

5. **Update Test**
   - Install previous version
   - Create notes
   - Update to new version
   - Verify notes persist and app works

### Penetration Testing (Future)

For v2.0 and beyond, consider professional penetration testing:

1. **Static Application Security Testing (SAST)**
   - Tools: SonarQube, Checkmarx
   - Frequency: Quarterly

2. **Dynamic Application Security Testing (DAST)**
   - Tools: OWASP ZAP, Burp Suite
   - Frequency: Before major releases

3. **Mobile Application Security Testing (MAST)**
   - Tools: MobSF, Drozer
   - Frequency: Annually

4. **Third-Party Audit**
   - Hire security firm for comprehensive audit
   - Frequency: Before v2.0 release

---

## Compliance

### Privacy Regulations

**GDPR (European Union)**
- ✅ Data minimization: No data collected
- ✅ Right to erasure: User can delete app
- ✅ Data portability: Local data, no export needed
- ✅ Privacy by design: Compliant

**CCPA (California)**
- ✅ No personal information collected
- ✅ No sale of personal information
- ✅ Compliant

**COPPA (Children's Online Privacy Protection Act)**
- ✅ Not directed at children under 13
- ✅ No data collection from children
- ✅ Compliant (but rated 4+ for broad compatibility)

### App Store Compliance

**Apple App Store**
- ✅ Privacy Nutrition Labels: "Data Not Collected"
- ✅ Privacy Policy: Published and linked
- ✅ No third-party analytics
- ✅ Compliant with App Store Review Guidelines

**Google Play Store**
- ✅ Data Safety form: "No data collected"
- ✅ Privacy Policy: Published and linked
- ✅ Target API 34 (Android 14)
- ✅ Compliant with Google Play Policies

### Security Standards

**OWASP Mobile Application Security Verification Standard (MASVS)**
- Level 1 (Standard Security): ✅ Compliant
- Level 2 (Defense in Depth): ⚠️ Partial (no encryption)
- Level 3 (High Security): ❌ Not applicable (not banking/health app)

**Recommendations for Future:**
- Implement Hive box encryption (Level 2)
- Add biometric authentication (Level 2)
- Implement certificate pinning if network added (Level 2)

---

## Security Roadmap

### v1.0 (Current)

- ✅ Local-only storage
- ✅ No data collection
- ✅ Minimal permissions
- ✅ Code signing
- ✅ Code obfuscation

### v1.1 (Planned)

- [ ] Hive box encryption (optional)
- [ ] App-level biometric lock (optional)
- [ ] Security audit by third party
- [ ] Automated vulnerability scanning

### v2.0 (Future)

- [ ] End-to-end encrypted sync (optional)
- [ ] Security bug bounty program
- [ ] Annual penetration testing
- [ ] SOC 2 Type II certification (if applicable)

---

## Security Contacts

**Security Team Email:** security@ephenotes.app

**Response Times:**
- Critical vulnerabilities: < 24 hours
- High severity: < 48 hours
- General inquiries: < 7 days

**PGP Key:** (Future - add if needed)

---

## Additional Resources

### Security Guidelines

- [OWASP Mobile Security Project](https://owasp.org/www-project-mobile-security/)
- [OWASP Mobile Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Flutter Security Best Practices](https://docs.flutter.dev/security)
- [Apple Security Guide](https://support.apple.com/guide/security/welcome/web)
- [Android Security](https://source.android.com/docs/security)

### Privacy Resources

- [GDPR Official Text](https://gdpr.eu/)
- [CCPA Resource Center](https://oag.ca.gov/privacy/ccpa)
- [Apple Privacy Guidelines](https://developer.apple.com/app-store/review/guidelines/#privacy)
- [Google Privacy Policy](https://policies.google.com/privacy)

---

**Last Updated:** 2026-02-03
**Next Review:** 2026-05-01 (Quarterly)
**Version:** 1.0
