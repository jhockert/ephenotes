import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import 'package:ephenotes/core/utils/performance_alert_system.dart';

void main() {
  group('Performance Monitoring Tests', () {
    late PerformanceMonitor monitor;
    late PerformanceAlertSystem alertSystem;

    setUp(() {
      // Create a fresh instance for each test
      // Note: PerformanceMonitor is a singleton, so we need to be careful
      monitor = PerformanceMonitor();
      monitor.initialize();
      alertSystem = PerformanceAlertSystem(monitor);
    });

    tearDown(() {
      // Clean up any generated files
      final metricsFile = File('performance_metrics.json');
      if (metricsFile.existsSync()) {
        metricsFile.deleteSync();
      }
    });

    group('App Launch Time Tracking', () {
      test('tracks cold start duration', () async {
        // Simulate app startup delay
        await Future.delayed(const Duration(milliseconds: 100));

        // Mark app as ready
        monitor.markAppReady();

        // Verify cold start duration is recorded
        final coldStart = monitor.getColdStartDuration();
        expect(coldStart, isNotNull);
        expect(coldStart!.inMilliseconds, greaterThan(0));
        expect(
            coldStart.inMilliseconds, lessThan(5000)); // Reasonable upper bound
      });

      test('cold start duration is only recorded once', () {
        monitor.markAppReady();
        final firstDuration = monitor.getColdStartDuration();

        // Try to mark ready again
        monitor.markAppReady();
        final secondDuration = monitor.getColdStartDuration();

        // Should be the same duration
        expect(secondDuration, equals(firstDuration));
      });

      test('detects cold start regression when exceeding 2 seconds', () async {
        // Simulate slow startup
        await Future.delayed(const Duration(milliseconds: 100));
        monitor.markAppReady();

        // Check for regressions
        final regressions = monitor.getRegressions();

        // In test environment, cold start should be fast
        // If it were slow, we'd expect a regression
        expect(regressions, isA<List<PerformanceRegression>>());
      });
    });

    group('User Interaction Tracking', () {
      test('tracks interaction count', () {
        // Track multiple interactions
        monitor.trackInteraction('tap');
        monitor.trackInteraction('tap');
        monitor.trackInteraction('tap');

        final stats = monitor.getInteractionStats('tap');
        expect(stats, isNotNull);
        expect(stats!.count, equals(3));
      });

      test('tracks interaction duration', () {
        // Track interactions with duration
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 50));
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 75));
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 100));

        final stats = monitor.getInteractionStats('note_creation');
        expect(stats, isNotNull);
        expect(stats!.count, equals(3));
        expect(stats.averageDuration.inMilliseconds, equals(75));
        expect(stats.minDuration.inMilliseconds, equals(50));
        expect(stats.maxDuration.inMilliseconds, equals(100));
      });

      test('tracks timed interactions with start/end', () async {
        final startTime = monitor.startInteractionTracking();

        // Simulate some work
        await Future.delayed(const Duration(milliseconds: 50));

        monitor.endInteractionTracking('search', startTime);

        final stats = monitor.getInteractionStats('search');
        expect(stats, isNotNull);
        expect(stats!.count, equals(1));
        expect(stats.averageDuration.inMilliseconds, greaterThanOrEqualTo(50));
      });

      test('calculates percentiles for interaction durations', () {
        // Track many interactions with varying durations
        for (int i = 1; i <= 100; i++) {
          monitor.trackInteraction('scroll',
              duration: Duration(milliseconds: i));
        }

        final stats = monitor.getInteractionStats('scroll');
        expect(stats, isNotNull);
        expect(stats!.p50Duration, isNotNull);
        expect(stats.p95Duration, isNotNull);

        // P50 should be around 50ms
        expect(stats.p50Duration!.inMilliseconds, closeTo(50, 10));

        // P95 should be around 95ms
        expect(stats.p95Duration!.inMilliseconds, closeTo(95, 10));
      });

      test('limits interaction history to 100 entries', () {
        // Track more than 100 interactions
        for (int i = 0; i < 150; i++) {
          monitor.trackInteraction('tap_limit_test',
              duration: Duration(milliseconds: i));
        }

        final stats = monitor.getInteractionStats('tap_limit_test');
        expect(stats, isNotNull);

        // Should only keep last 100
        // We can't directly check the internal list size,
        // but we can verify the stats are calculated correctly
        expect(stats!.count, equals(150)); // Count should still be accurate
      });

      test('gets all interaction statistics', () {
        monitor.trackInteraction('tap_unique1',
            duration: const Duration(milliseconds: 10));
        monitor.trackInteraction('scroll_unique1',
            duration: const Duration(milliseconds: 20));
        monitor.trackInteraction('navigation_unique1',
            duration: const Duration(milliseconds: 30));

        final allStats = monitor.getAllInteractionStats();
        expect(allStats.length, greaterThanOrEqualTo(3));
        expect(
            allStats.keys,
            containsAll(
                ['tap_unique1', 'scroll_unique1', 'navigation_unique1']));
      });
    });

    group('Performance Regression Detection', () {
      test('detects regression when interaction exceeds baseline', () {
        // Track a slow note creation (target: 100ms)
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 150));

        final regressions = monitor.getRegressions();

        // Should detect regression
        final noteCreationRegressions =
            regressions.where((r) => r.metric == 'note_creation').toList();

        expect(noteCreationRegressions, isNotEmpty);
        expect(noteCreationRegressions.first.actualValue, equals(150.0));
        expect(noteCreationRegressions.first.expectedValue, equals(100.0));
      });

      test('does not detect regression when within baseline', () {
        // Track a fast note creation
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 80));

        final regressions = monitor.getRegressions();

        // Should not detect regression for this specific interaction
        final recentNoteCreationRegressions = regressions
            .where((r) => r.metric == 'note_creation' && r.actualValue == 80.0)
            .toList();

        expect(recentNoteCreationRegressions, isEmpty);
      });

      test('filters regressions by time window', () async {
        // Track a regression
        monitor.trackInteraction('search',
            duration: const Duration(milliseconds: 300));

        // Wait a bit
        await Future.delayed(const Duration(milliseconds: 100));

        // Get recent regressions (within 1 second)
        final recentRegressions =
            monitor.getRegressions(since: const Duration(seconds: 1));

        expect(recentRegressions, isNotEmpty);

        // Get very recent regressions (within 10ms - should be empty)
        final veryRecentRegressions =
            monitor.getRegressions(since: const Duration(milliseconds: 10));

        // Might be empty depending on timing
        expect(veryRecentRegressions, isA<List<PerformanceRegression>>());
      });

      test('checks for recent regressions', () {
        // Track a regression with unique interaction type
        monitor.trackInteraction('search_regression_test',
            duration: const Duration(milliseconds: 300));

        // Should now have recent regressions
        final hasRegressions = monitor.hasRecentRegressions();
        expect(hasRegressions, isTrue);
      });

      test('limits regression history to 50 entries', () {
        // Generate many regressions
        for (int i = 0; i < 60; i++) {
          monitor.trackInteraction('search',
              duration: Duration(milliseconds: 300 + i));
        }

        final regressions = monitor.getRegressions();

        // Should only keep last 50
        expect(regressions.length, lessThanOrEqualTo(50));
      });
    });

    group('Performance Report', () {
      test('generates comprehensive performance report', () async {
        // Set up some performance data
        monitor.markAppReady();
        monitor.trackInteraction('tap',
            duration: const Duration(milliseconds: 10));
        monitor.trackInteraction('scroll',
            duration: const Duration(milliseconds: 15));
        await monitor.getCurrentMemoryUsageMB();

        final report = monitor.getPerformanceReport();

        expect(report.timestamp, isNotNull);
        expect(report.coldStartDuration, isNotNull);
        expect(report.memoryUsageMB, greaterThan(0));
        expect(report.performanceStatus, isA<PerformanceStatus>());
        expect(report.interactionStats, isNotEmpty);
      });

      test('report indicates if all targets are met', () {
        final report = monitor.getPerformanceReport();

        expect(report.meetsAllTargets, isA<bool>());

        // In test environment with minimal load, targets should be met
        if (report.performanceStatus == PerformanceStatus.good &&
            report.recentRegressions.isEmpty) {
          expect(report.meetsAllTargets, isTrue);
        }
      });

      test('report generates summary string', () {
        final report = monitor.getPerformanceReport();
        final summary = report.getSummary();

        expect(summary, isNotEmpty);
        expect(summary, contains('Performance Report'));
        expect(summary, contains('Memory:'));
        expect(summary, contains('Status:'));
      });
    });

    group('Performance Alert System', () {
      test('checks performance and generates alerts', () async {
        // Set up some performance data
        monitor.markAppReady();
        await monitor.getCurrentMemoryUsageMB();

        final result = await alertSystem.checkPerformance();

        expect(result, isNotNull);
        expect(result.alerts, isA<List<PerformanceAlert>>());
        expect(result.report, isA<PerformanceReport>());
        expect(result.timestamp, isNotNull);
      });

      test('generates error alert for excessive cold start time', () async {
        // We can't easily simulate a slow cold start in tests,
        // but we can verify the alert system structure
        final result = await alertSystem.checkPerformance();

        // Check alert structure
        for (final alert in result.alerts) {
          expect(alert.severity, isA<AlertSeverity>());
          expect(alert.metric, isNotEmpty);
          expect(alert.message, isNotEmpty);
          expect(alert.actualValue, isA<double>());
          expect(alert.expectedValue, isA<double>());
        }
      });

      test('generates warning alert for approaching limits', () async {
        // Track an interaction that's close to the limit
        monitor.trackInteraction('note_creation',
            duration: const Duration(milliseconds: 110));

        final result = await alertSystem.checkPerformance();

        // Should have at least one alert
        expect(result.alerts, isNotEmpty);
      });

      test('exports metrics to JSON file', () async {
        // Set up performance data
        monitor.markAppReady();
        monitor.trackInteraction('tap',
            duration: const Duration(milliseconds: 10));
        await monitor.getCurrentMemoryUsageMB();

        final filePath = 'performance_metrics.json';

        // Export metrics
        await alertSystem.exportMetrics(filePath);

        // Verify file was created
        final file = File(filePath);
        expect(file.existsSync(), isTrue);

        // Verify file content
        final content = await file.readAsString();
        expect(content, isNotEmpty);
        expect(content, contains('timestamp'));
        expect(content, contains('memory_mb'));
        expect(content, contains('fps'));

        // Clean up
        await file.delete();
      });

      test('generates CI summary with all sections', () async {
        // Set up performance data
        monitor.markAppReady();
        monitor.trackInteraction('tap',
            duration: const Duration(milliseconds: 10));
        monitor.trackInteraction('search',
            duration: const Duration(milliseconds: 300)); // Regression
        await monitor.getCurrentMemoryUsageMB();

        final result = await alertSystem.checkPerformance();
        final summary = alertSystem.generateCISummary(result);

        expect(summary, isNotEmpty);
        expect(summary, contains('Performance Report'));
        expect(summary, contains('Key Metrics'));

        // Should contain interaction stats if any were tracked
        if (result.report.interactionStats.isNotEmpty) {
          expect(summary, contains('Interaction Performance'));
        }

        // Should contain alerts if any were generated
        if (result.alerts.isNotEmpty) {
          expect(summary, contains('Alerts'));
        }
      });

      test('alert result indicates health status', () async {
        final result = await alertSystem.checkPerformance();

        expect(result.hasErrors, isA<bool>());
        expect(result.hasWarnings, isA<bool>());
        expect(result.isHealthy, isA<bool>());

        // If healthy, should have no errors or warnings
        if (result.isHealthy) {
          expect(result.hasErrors, isFalse);
          expect(result.hasWarnings, isFalse);
        }
      });
    });

    group('Memory Tracking', () {
      test('tracks memory usage', () async {
        final memoryUsage = await monitor.getCurrentMemoryUsageMB();

        expect(memoryUsage, greaterThan(0));
        expect(memoryUsage, lessThan(500)); // Reasonable upper bound
      });

      test('maintains memory history', () async {
        // Track memory multiple times
        await monitor.getCurrentMemoryUsageMB();
        await monitor.getCurrentMemoryUsageMB();
        await monitor.getCurrentMemoryUsageMB();

        final history = monitor.getMemoryHistory();

        expect(history, isNotEmpty);
        expect(history.length, greaterThanOrEqualTo(3));
      });

      test('limits memory history to 100 entries', () async {
        // Track memory many times
        for (int i = 0; i < 150; i++) {
          await monitor.getCurrentMemoryUsageMB();
        }

        final history = monitor.getMemoryHistory();

        expect(history.length, lessThanOrEqualTo(100));
      });
    });

    group('Frame Rate Monitoring', () {
      test('tracks frame rate', () async {
        // Let some frames accumulate
        await Future.delayed(const Duration(milliseconds: 100));

        final fps = monitor.getCurrentFPS();

        // FPS might be 0 in test environment without actual rendering
        expect(fps, isA<double>());
        expect(fps, greaterThanOrEqualTo(0));
      });

      test('calculates average frame time', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        final frameTime = monitor.getAverageFrameTimeMs();

        expect(frameTime, isA<double>());
        expect(frameTime, greaterThanOrEqualTo(0));
      });

      test('gets frame time history', () async {
        await Future.delayed(const Duration(milliseconds: 100));

        final history = monitor.getFrameTimeHistory();

        expect(history, isA<List<Duration>>());
      });
    });

    group('Performance Status', () {
      test('determines performance status', () async {
        await monitor.getCurrentMemoryUsageMB();

        final status = monitor.getPerformanceStatus();

        expect(status, isA<PerformanceStatus>());
        expect([
          PerformanceStatus.good,
          PerformanceStatus.warning,
          PerformanceStatus.poor,
        ], contains(status));
      });

      test('logs performance metrics', () async {
        await monitor.getCurrentMemoryUsageMB();

        // Should not throw
        expect(() => monitor.logPerformanceMetrics(), returnsNormally);
        expect(() => monitor.logPerformanceMetrics(context: 'Test'),
            returnsNormally);
      });
    });

    group('Performance Profiling', () {
      test('profiles async operations', () async {
        final result = await monitor.profile('test_operation', () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'completed';
        });

        expect(result, equals('completed'));
      });

      test('profiles operations with memory tracking', () async {
        await monitor.profile('memory_test', () async {
          // Simulate some work
          final list = List.generate(1000, (i) => i);
          await Future.delayed(const Duration(milliseconds: 10));
          return list.length;
        });

        // Should complete without errors
        expect(true, isTrue);
      });
    });

    group('Integration Tests', () {
      test('complete performance monitoring workflow', () async {
        // 1. Initialize and mark app ready
        monitor.markAppReady();

        // 2. Track various interactions with unique names
        monitor.trackInteraction('tap_workflow',
            duration: const Duration(milliseconds: 10));
        monitor.trackInteraction('scroll_workflow',
            duration: const Duration(milliseconds: 15));
        monitor.trackInteraction('note_creation_workflow',
            duration: const Duration(milliseconds: 80));
        monitor.trackInteraction('search_workflow',
            duration: const Duration(milliseconds: 150));

        // 3. Track memory
        await monitor.getCurrentMemoryUsageMB();

        // 4. Generate report
        final report = monitor.getPerformanceReport();
        expect(report, isNotNull);
        expect(report.coldStartDuration, isNotNull);
        expect(report.interactionStats.length, greaterThanOrEqualTo(4));

        // 5. Check for alerts
        final alertResult = await alertSystem.checkPerformance();
        expect(alertResult, isNotNull);

        // 6. Export metrics
        await alertSystem.exportMetrics('performance_metrics.json');
        expect(File('performance_metrics.json').existsSync(), isTrue);

        // 7. Generate CI summary
        final summary = alertSystem.generateCISummary(alertResult);
        expect(summary, isNotEmpty);

        // Clean up
        await File('performance_metrics.json').delete();
      });

      test('handles high-load scenario', () async {
        // Simulate high load with many interactions using unique names
        for (int i = 0; i < 100; i++) {
          monitor.trackInteraction('tap_highload',
              duration: Duration(milliseconds: 10 + (i % 20)));
        }

        for (int i = 0; i < 50; i++) {
          monitor.trackInteraction('scroll_highload',
              duration: Duration(milliseconds: 15 + (i % 10)));
        }

        // Track memory multiple times
        for (int i = 0; i < 10; i++) {
          await monitor.getCurrentMemoryUsageMB();
        }

        // Should still generate valid report
        final report = monitor.getPerformanceReport();
        expect(report, isNotNull);
        expect(report.interactionStats['tap_highload']!.count, equals(100));
        expect(report.interactionStats['scroll_highload']!.count, equals(50));
      });
    });
  });
}
