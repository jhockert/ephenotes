# Monitoring & Observability

This document covers monitoring, crash reporting, performance tracking, and observability strategies for ephenotes.

## Table of Contents

1. [Overview](#overview)
2. [Crash Reporting](#crash-reporting)
3. [Performance Monitoring](#performance-monitoring)
4. [Analytics (Optional)](#analytics-optional)
5. [Logging Strategy](#logging-strategy)
6. [Alerting & Notifications](#alerting--notifications)
7. [Dashboards](#dashboards)
8. [Troubleshooting](#troubleshooting)

---

## Overview

**Monitoring Goals:**

1. **Stability**: Track crash-free users (target: 99.5%+)
2. **Performance**: Monitor app responsiveness (target: 60 FPS, < 200ms search)
3. **User Experience**: Identify pain points and friction
4. **Quality**: Detect bugs before users report them

**Privacy-First Monitoring:**

ephenotes is a privacy-focused app. All monitoring must:
- ✅ Respect user privacy (no personal data)
- ✅ Be opt-in or anonymized
- ✅ Comply with privacy policy
- ✅ Not track individual users

**Monitoring Stack (Recommended):**

| Tool | Purpose | Cost |
|------|---------|------|
| Firebase Crashlytics | Crash reporting | Free |
| Firebase Performance | Performance monitoring | Free |
| Sentry | Alternative crash reporting | Free tier available |
| App Store Connect | iOS metrics | Free (built-in) |
| Google Play Console | Android metrics | Free (built-in) |

---

## Crash Reporting

### Why Crash Reporting?

- Detect crashes before users report them
- Get stack traces for debugging
- Track crash-free user percentage
- Prioritize fixes based on impact

### Option 1: Firebase Crashlytics (Recommended)

**Pros:**
- Free
- Automatic crash detection
- Integration with Flutter
- Real-time alerts
- Detailed stack traces

**Cons:**
- Requires Firebase project
- Adds ~2 MB to app size
- Owned by Google

#### Setup Firebase Crashlytics

**1. Create Firebase Project**

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create Firebase project
# Or use Firebase Console: https://console.firebase.google.com
```

**2. Add Firebase to Flutter**

```bash
# Add dependencies
flutter pub add firebase_core
flutter pub add firebase_crashlytics

# Configure FlutterFire
flutterfire configure
```

**3. Update pubspec.yaml**

```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_crashlytics: ^3.4.0
```

**4. Initialize Firebase**

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Crashlytics collection
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Pass all uncaught asynchronous errors to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}
```

**5. Log Non-Fatal Errors**

```dart
// lib/data/repositories/note_repository_impl.dart
Future<void> save(Note note) async {
  try {
    await _noteBox.put(note.id, note);
  } catch (e, stack) {
    // Log to Crashlytics (non-fatal)
    await FirebaseCrashlytics.instance.recordError(
      e,
      stack,
      reason: 'Failed to save note',
      fatal: false,
    );
    rethrow;
  }
}
```

**6. Add Custom Keys for Debugging**

```dart
// Set user ID (anonymized)
await FirebaseCrashlytics.instance.setUserIdentifier(
  'user_${DateTime.now().millisecondsSinceEpoch}',
);

// Set custom keys
await FirebaseCrashlytics.instance.setCustomKey('note_count', noteCount);
await FirebaseCrashlytics.instance.setCustomKey('app_version', '1.0.0');
await FirebaseCrashlytics.instance.setCustomKey('build_number', 1);
```

**7. Test Crash Reporting**

```dart
// Add a test crash button (dev mode only)
if (kDebugMode) {
  ElevatedButton(
    onPressed: () {
      FirebaseCrashlytics.instance.crash();  // Force crash for testing
    },
    child: const Text('Test Crash'),
  );
}
```

**8. View Crashes in Console**

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Crashlytics**
4. View crash reports, trends, and affected users

#### Privacy Considerations for Firebase

**Data Collected by Crashlytics:**
- Crash stack traces
- Device model and OS version
- App version and build number
- Anonymous user ID (not linked to personal data)

**Update Privacy Policy:**
```
While ephenotes does not collect personal information, we use Firebase
Crashlytics to improve app stability. Crashlytics collects crash reports
and device information but does not track your personal data or note content.
You can opt out of crash reporting in Settings.
```

**Opt-Out Implementation (v1.1):**
```dart
// Allow users to disable crash reporting
await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
  userConsent,
);
```

---

### Option 2: Sentry

**Pros:**
- Open source
- Detailed error tracking
- Performance monitoring
- Self-hosted option available

**Cons:**
- Paid plans for high volume
- More complex setup

#### Setup Sentry

```bash
# Add dependency
flutter pub add sentry_flutter
```

```dart
// lib/main.dart
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  await SentryFlutter.init(
    (options) {
      options.dsn = 'YOUR_SENTRY_DSN';
      options.tracesSampleRate = 1.0;  // 100% of transactions
      options.environment = 'production';
      options.release = '1.0.0+1';
    },
    appRunner: () => runApp(const MyApp()),
  );
}
```

---

## Performance Monitoring

### Why Performance Monitoring?

- Ensure 60 FPS rendering
- Track search performance (< 200ms requirement)
- Identify slow screens and operations
- Monitor app startup time

### Option 1: Firebase Performance Monitoring

**Setup:**

```bash
flutter pub add firebase_performance
```

```dart
// lib/main.dart
import 'package:firebase_performance/firebase_performance.dart';

// Track custom traces
Future<void> searchNotes(String query) async {
  final trace = FirebasePerformance.instance.newTrace('search_notes');
  await trace.start();

  try {
    final results = await _performSearch(query);
    trace.setMetric('result_count', results.length);
    return results;
  } finally {
    await trace.stop();
  }
}
```

**Automatic Tracing:**
- App startup time
- Screen rendering performance
- Network requests (if added)

**View Performance Data:**
1. Firebase Console > Performance
2. View traces, screen rendering, and custom metrics

### Option 2: Custom Performance Logging

```dart
// lib/core/performance/performance_tracker.dart
class PerformanceTracker {
  static final Map<String, Stopwatch> _timers = {};

  static void startTrace(String name) {
    _timers[name] = Stopwatch()..start();
  }

  static void stopTrace(String name) {
    final timer = _timers[name];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds;

      if (kDebugMode) {
        print('⏱️ $name took ${duration}ms');
      }

      // Log to analytics or file
      if (duration > 1000) {
        // Warn if operation took > 1 second
        print('⚠️ Slow operation: $name took ${duration}ms');
      }

      _timers.remove(name);
    }
  }
}

// Usage:
PerformanceTracker.startTrace('search_notes');
final results = await searchNotes(query);
PerformanceTracker.stopTrace('search_notes');
```

### Performance Benchmarks

**Target Metrics:**

| Operation | Target | Measurement |
|-----------|--------|-------------|
| App startup | < 2 seconds | Cold start to first frame |
| Search | < 200ms | Query input to results display |
| Note creation | < 100ms | Tap "+" to editor screen |
| Note save | < 50ms | Tap "Save" to list update |
| Scroll performance | 60 FPS | Smooth scrolling on list |
| Archive animation | 300ms | Swipe to archive completion |

**Monitoring Techniques:**

1. **Flutter DevTools**
   ```bash
   flutter run --profile
   # Open DevTools to analyze performance
   ```

2. **FPS Monitoring**
   ```dart
   // Use Flutter's built-in FPS overlay (dev mode)
   MaterialApp(
     showPerformanceOverlay: kDebugMode,
     // ...
   );
   ```

3. **Frame Timing**
   ```dart
   import 'dart:ui' as ui;

   void monitorFrameTiming() {
     ui.window.onReportTimings = (List<FrameTiming> timings) {
       for (final timing in timings) {
         final totalSpan = timing.totalSpan;
         if (totalSpan.inMilliseconds > 16) {
           // Frame took > 16ms (below 60 FPS)
           print('⚠️ Slow frame: ${totalSpan.inMilliseconds}ms');
         }
       }
     };
   }
   ```

---

## Analytics (Optional)

**⚠️ Important:** ephenotes v1.0 does NOT include analytics to maintain privacy.

If analytics are needed in the future (v2.0+), consider:

### Privacy-Respecting Analytics

**Option 1: Privacy-First Analytics (Plausible, Matomo)**
- No cookies
- No personal data
- Aggregated stats only

**Option 2: Anonymized Firebase Analytics**
```dart
// Only if user opts in
await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(userConsent);

// Log anonymous events
await FirebaseAnalytics.instance.logEvent(
  name: 'note_created',
  parameters: {
    'note_count': noteCount,  // Aggregated, not personal
  },
);
```

**Events to Track (Future):**
- App launches (count only)
- Features used (search, archive, pin)
- Note count distribution (aggregated)
- Crash-free rate

**Privacy Policy Update Required:**
```
ephenotes may collect anonymous usage data to improve the app. This includes
app launches, feature usage, and crash reports. No personal information or
note content is collected. You can opt out in Settings.
```

---

## Logging Strategy

### Log Levels

```dart
// lib/core/logging/logger.dart
enum LogLevel { debug, info, warning, error, fatal }

class AppLogger {
  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🐛 DEBUG: $message');
      if (error != null) print('Error: $error');
      if (stackTrace != null) print('Stack: $stackTrace');
    }
  }

  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void warning(String message, {Object? error}) {
    print('⚠️ WARNING: $message');
    if (error != null) print('Error: $error');
    // Optionally send to crash reporting (non-fatal)
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    print('❌ ERROR: $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack: $stackTrace');

    // Send to Crashlytics (non-fatal)
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: false,
      );
    }
  }

  static void fatal(String message, {Object? error, StackTrace? stackTrace}) {
    print('💀 FATAL: $message');
    if (error != null) print('Error: $error');
    if (stackTrace != null) print('Stack: $stackTrace');

    // Send to Crashlytics (fatal)
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: true,
      );
    }
  }
}
```

### Usage in Code

```dart
// lib/presentation/bloc/notes_bloc.dart
Future<void> _onCreateNote(CreateNote event, Emitter<NotesState> emit) async {
  try {
    AppLogger.info('Creating new note');
    await _repository.create(event.note);
    AppLogger.info('Note created successfully');
  } catch (e, stack) {
    AppLogger.error('Failed to create note', error: e, stackTrace: stack);
    emit(NotesError('Unable to create note', error: e));
  }
}
```

### Production Logging

**Do NOT log in production:**
- Personal data (note content)
- User identifiers
- Sensitive operations

**DO log in production:**
- Critical errors
- Performance issues
- System errors (database, file I/O)

---

## Alerting & Notifications

### Crash Rate Alerts

**Firebase Crashlytics Alerts:**

1. Firebase Console > Crashlytics > Settings
2. Enable **Crash Velocity Alerts**
3. Set threshold: Alert when crash rate > 0.5%
4. Configure email notifications

**Alert Thresholds:**

| Metric | Warning | Critical |
|--------|---------|----------|
| Crash-free users | < 99% | < 98% |
| Fatal crashes | > 5/day | > 20/day |
| ANRs (Android) | > 2/day | > 10/day |

### Performance Alerts

**App Vitals (Google Play Console):**

1. Play Console > Quality > Android vitals
2. Monitor:
   - Crash rate
   - ANR rate
   - Excessive wake-ups
   - Stuck wake locks

**Thresholds:**
- Crash rate: < 1.09% (bad behavior threshold)
- ANR rate: < 0.47% (bad behavior threshold)

### Setting Up Alerts

**Email Notifications:**
- Firebase Console > Project Settings > Integrations
- Add email addresses for alerts

**Slack Integration (Optional):**
```bash
# Firebase Crashlytics Slack webhook
# Configure in Firebase Console
```

**PagerDuty (For On-Call, Optional):**
- Integrate Firebase with PagerDuty
- Alert on-call engineer for critical crashes

---

## Dashboards

### App Store Connect (iOS)

**Metrics Available:**
- App Store impressions
- App units (downloads)
- Sales and trends
- Crashes (basic)
- Energy use
- Launch time

**Access:**
1. https://appstoreconnect.apple.com
2. My Apps > ephenotes > App Analytics

### Google Play Console (Android)

**Metrics Available:**
- Installations
- Uninstallations
- Ratings and reviews
- Android vitals (crashes, ANRs)
- User acquisition
- Retention

**Access:**
1. https://play.google.com/console
2. ephenotes > Statistics

### Firebase Console

**Metrics Available:**
- Crashlytics: Crash reports, trends, impacted users
- Performance: Trace metrics, screen rendering
- Analytics: Custom events (if enabled)

**Access:**
1. https://console.firebase.google.com
2. Select ephenotes project

### Custom Dashboard (Future)

**Tool Options:**
- Grafana (self-hosted)
- Datadog (paid)
- New Relic (paid)

**Example Metrics:**
- Daily active users
- Crash-free rate
- Average app startup time
- Note creation rate
- Search performance (p50, p95, p99)

---

## Troubleshooting

### Common Issues

#### 1. Crashlytics Not Reporting Crashes

**Solutions:**
```bash
# Verify Firebase is initialized
flutter run

# Check logs for Firebase initialization errors
# Look for: "Firebase initialized successfully"

# Force a test crash
FirebaseCrashlytics.instance.crash();

# Wait 5-10 minutes for reports to appear in console
```

#### 2. Crash Reports Missing Symbols (Obfuscated)

**Solution:**
```bash
# Upload debug symbols to Firebase
firebase crashlytics:symbols:upload \
  --app=YOUR_APP_ID \
  build/app/outputs/symbols/release

# For iOS
# Upload dSYMs via Xcode or fastlane
```

#### 3. Performance Data Not Showing

**Solution:**
```dart
// Ensure Performance Monitoring is enabled
await FirebasePerformance.instance.setPerformanceCollectionEnabled(true);

// Check that traces are started and stopped correctly
final trace = FirebasePerformance.instance.newTrace('test');
await trace.start();
// ... operation ...
await trace.stop();
```

#### 4. High Crash Rate After Release

**Action Plan:**
1. Check Crashlytics dashboard for top crashes
2. Identify affected app version
3. Analyze stack traces
4. Reproduce issue locally
5. Create hotfix
6. Submit expedited review (if critical)

**Communication:**
- Update users via app store "What's New"
- Post on social media (if applicable)
- Email support requests

---

## Monitoring Checklist

### Pre-Release

- [ ] Firebase Crashlytics integrated
- [ ] Test crash reporting works
- [ ] Performance monitoring enabled
- [ ] Debug symbols uploaded
- [ ] Alert thresholds configured
- [ ] Privacy policy updated (if monitoring added)

### Post-Release (Week 1)

- [ ] Check crash-free users % daily
- [ ] Monitor top crashes
- [ ] Review ANR reports (Android)
- [ ] Check app startup time
- [ ] Review user ratings and reviews
- [ ] Respond to support emails

### Ongoing (Weekly)

- [ ] Review crash trends
- [ ] Check performance metrics
- [ ] Monitor user retention
- [ ] Analyze negative reviews
- [ ] Plan fixes for next release

### Quarterly

- [ ] Review monitoring strategy
- [ ] Optimize instrumentation
- [ ] Update alert thresholds
- [ ] Archive old crash reports
- [ ] Audit privacy compliance

---

## Metrics Targets

### Stability

- **Crash-free users:** 99.5%+ (iOS and Android)
- **Fatal crashes:** < 5 per 10,000 sessions
- **ANRs:** < 3 per 10,000 sessions (Android)

### Performance

- **App startup:** < 2 seconds (p95)
- **Search latency:** < 200ms (p95)
- **Frame rate:** 60 FPS (p95)
- **Memory usage:** < 100 MB (typical)

### User Experience

- **App rating:** 4.0+ stars
- **Retention (Day 1):** > 40%
- **Retention (Day 7):** > 20%
- **Retention (Day 30):** > 10%

### Quality

- **Test coverage:** 80%+
- **Critical bugs:** 0
- **High priority bugs:** < 3
- **Support response time:** < 24 hours

---

## Additional Resources

### Documentation

- [Firebase Crashlytics Docs](https://firebase.google.com/docs/crashlytics)
- [Firebase Performance Docs](https://firebase.google.com/docs/perf-mon)
- [Sentry Flutter Docs](https://docs.sentry.io/platforms/flutter/)
- [App Store Connect Analytics](https://developer.apple.com/app-store-connect/)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)

### Tools

- [Flutter DevTools](https://docs.flutter.dev/tools/devtools)
- [Xcode Instruments](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/)
- [Android Profiler](https://developer.android.com/studio/profile)

---

**Last Updated:** 2026-02-03
**Review Frequency:** Quarterly
**Next Review:** 2026-05-01
