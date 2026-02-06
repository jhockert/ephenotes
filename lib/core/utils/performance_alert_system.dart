import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'performance_monitor.dart';

/// Performance alert system for CI/CD integration.
///
/// Features:
/// - Automated performance regression detection
/// - CI/CD pipeline integration
/// - Alert generation and reporting
/// - Performance metrics export
class PerformanceAlertSystem {
  final PerformanceMonitor _monitor;

  PerformanceAlertSystem(this._monitor);

  /// Check for performance regressions and generate alerts.
  Future<PerformanceAlertResult> checkPerformance() async {
    final report = _monitor.getPerformanceReport();
    final alerts = <PerformanceAlert>[];

    // Check cold start time
    if (report.coldStartDuration != null) {
      if (report.coldStartDuration!.inMilliseconds > 2000) {
        alerts.add(PerformanceAlert(
          severity: AlertSeverity.error,
          metric: 'cold_start',
          message: 'Cold start time exceeded 2 seconds: '
              '${report.coldStartDuration!.inMilliseconds}ms',
          actualValue: report.coldStartDuration!.inMilliseconds.toDouble(),
          expectedValue: 2000.0,
        ));
      } else if (report.coldStartDuration!.inMilliseconds > 1800) {
        alerts.add(PerformanceAlert(
          severity: AlertSeverity.warning,
          metric: 'cold_start',
          message: 'Cold start time approaching limit: '
              '${report.coldStartDuration!.inMilliseconds}ms',
          actualValue: report.coldStartDuration!.inMilliseconds.toDouble(),
          expectedValue: 2000.0,
        ));
      }
    }

    // Check memory usage
    if (report.memoryUsageMB > 100) {
      alerts.add(PerformanceAlert(
        severity: AlertSeverity.error,
        metric: 'memory_usage',
        message: 'Memory usage exceeded 100MB: ${report.memoryUsageMB}MB',
        actualValue: report.memoryUsageMB.toDouble(),
        expectedValue: 100.0,
      ));
    } else if (report.memoryUsageMB > 90) {
      alerts.add(PerformanceAlert(
        severity: AlertSeverity.warning,
        metric: 'memory_usage',
        message: 'Memory usage approaching limit: ${report.memoryUsageMB}MB',
        actualValue: report.memoryUsageMB.toDouble(),
        expectedValue: 100.0,
      ));
    }

    // Check FPS
    if (report.currentFPS > 0 && report.currentFPS < 54) {
      alerts.add(PerformanceAlert(
        severity: AlertSeverity.error,
        metric: 'fps',
        message: 'FPS below 54: ${report.currentFPS.toStringAsFixed(1)}',
        actualValue: report.currentFPS,
        expectedValue: 60.0,
      ));
    } else if (report.currentFPS > 0 && report.currentFPS < 57) {
      alerts.add(PerformanceAlert(
        severity: AlertSeverity.warning,
        metric: 'fps',
        message: 'FPS below target: ${report.currentFPS.toStringAsFixed(1)}',
        actualValue: report.currentFPS,
        expectedValue: 60.0,
      ));
    }

    // Check interaction metrics
    for (final stat in report.interactionStats.values) {
      final target = _getInteractionTarget(stat.interactionType);
      if (target != null && stat.averageDuration.inMilliseconds > target) {
        alerts.add(PerformanceAlert(
          severity: AlertSeverity.warning,
          metric: stat.interactionType,
          message: '${stat.interactionType} average duration exceeded target: '
              '${stat.averageDuration.inMilliseconds}ms (target: ${target}ms)',
          actualValue: stat.averageDuration.inMilliseconds.toDouble(),
          expectedValue: target.toDouble(),
        ));
      }
    }

    // Add recent regressions as alerts
    for (final regression in report.recentRegressions) {
      alerts.add(PerformanceAlert(
        severity: regression.deviationPercent > 50
            ? AlertSeverity.error
            : AlertSeverity.warning,
        metric: regression.metric,
        message: regression.description,
        actualValue: regression.actualValue,
        expectedValue: regression.expectedValue,
      ));
    }

    return PerformanceAlertResult(
      alerts: alerts,
      report: report,
      timestamp: DateTime.now(),
    );
  }

  /// Get target duration for interaction type.
  int? _getInteractionTarget(String interactionType) {
    switch (interactionType) {
      case 'note_creation':
        return 100; // 100ms
      case 'search':
        return 200; // 200ms
      case 'tap':
        return 50; // 50ms
      case 'scroll':
        return 16; // 16ms (60 FPS)
      case 'navigation':
        return 300; // 300ms
      default:
        return null;
    }
  }

  /// Export performance metrics to JSON for CI/CD.
  Future<void> exportMetrics(String filePath) async {
    final report = _monitor.getPerformanceReport();
    final alertResult = await checkPerformance();

    final data = {
      'timestamp': report.timestamp.toIso8601String(),
      'cold_start_ms': report.coldStartDuration?.inMilliseconds,
      'memory_mb': report.memoryUsageMB,
      'fps': report.currentFPS,
      'frame_time_ms': report.averageFrameTimeMs,
      'status': report.performanceStatus.name,
      'interactions': report.interactionStats.map(
        (key, value) => MapEntry(key, {
          'count': value.count,
          'avg_ms': value.averageDuration.inMilliseconds,
          'min_ms': value.minDuration.inMilliseconds,
          'max_ms': value.maxDuration.inMilliseconds,
          'p50_ms': value.p50Duration?.inMilliseconds,
          'p95_ms': value.p95Duration?.inMilliseconds,
        }),
      ),
      'regressions': report.recentRegressions
          .map((r) => {
                'metric': r.metric,
                'actual': r.actualValue,
                'expected': r.expectedValue,
                'deviation_percent': r.deviationPercent,
                'description': r.description,
                'timestamp': r.timestamp.toIso8601String(),
              })
          .toList(),
      'alerts': alertResult.alerts
          .map((a) => {
                'severity': a.severity.name,
                'metric': a.metric,
                'message': a.message,
                'actual': a.actualValue,
                'expected': a.expectedValue,
              })
          .toList(),
      'meets_targets': report.meetsAllTargets,
    };

    final file = File(filePath);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(data),
    );

    if (kDebugMode) {
      print('Performance metrics exported to: $filePath');
    }
  }

  /// Generate CI/CD summary for GitHub Actions.
  String generateCISummary(PerformanceAlertResult result) {
    final buffer = StringBuffer();

    buffer.writeln('## 📊 Performance Report');
    buffer.writeln('');

    // Overall status
    final hasErrors =
        result.alerts.any((a) => a.severity == AlertSeverity.error);
    final hasWarnings =
        result.alerts.any((a) => a.severity == AlertSeverity.warning);

    if (!hasErrors && !hasWarnings) {
      buffer.writeln('✅ **All performance targets met!**');
    } else if (hasErrors) {
      buffer.writeln('❌ **Performance regressions detected**');
    } else {
      buffer.writeln('⚠️ **Performance warnings detected**');
    }
    buffer.writeln('');

    // Key metrics
    buffer.writeln('### Key Metrics');
    buffer.writeln('');

    final report = result.report;
    if (report.coldStartDuration != null) {
      final coldStartIcon =
          report.coldStartDuration!.inMilliseconds <= 2000 ? '✅' : '❌';
      buffer.writeln('- $coldStartIcon **Cold Start:** '
          '${report.coldStartDuration!.inMilliseconds}ms (target: <2000ms)');
    }

    final memoryIcon = report.memoryUsageMB <= 100 ? '✅' : '❌';
    buffer.writeln('- $memoryIcon **Memory Usage:** '
        '${report.memoryUsageMB}MB (target: <100MB)');

    if (report.currentFPS > 0) {
      final fpsIcon = report.currentFPS >= 54 ? '✅' : '❌';
      buffer.writeln('- $fpsIcon **Frame Rate:** '
          '${report.currentFPS.toStringAsFixed(1)} FPS (target: 60 FPS)');
    }

    buffer.writeln(
        '- **Frame Time:** ${report.averageFrameTimeMs.toStringAsFixed(2)}ms');
    buffer.writeln('');

    // Interaction stats
    if (report.interactionStats.isNotEmpty) {
      buffer.writeln('### Interaction Performance');
      buffer.writeln('');
      buffer.writeln('| Interaction | Count | Avg Duration | P95 Duration |');
      buffer.writeln('|-------------|-------|--------------|--------------|');

      for (final stat in report.interactionStats.values) {
        final target = _getInteractionTarget(stat.interactionType);
        final avgMs = stat.averageDuration.inMilliseconds;
        final icon = target != null && avgMs <= target ? '✅' : '⚠️';

        buffer.writeln('| $icon ${stat.interactionType} | '
            '${stat.count} | '
            '${avgMs}ms | '
            '${stat.p95Duration?.inMilliseconds ?? '-'}ms |');
      }
      buffer.writeln('');
    }

    // Alerts
    if (result.alerts.isNotEmpty) {
      buffer.writeln('### 🚨 Alerts');
      buffer.writeln('');

      final errors =
          result.alerts.where((a) => a.severity == AlertSeverity.error);
      final warnings =
          result.alerts.where((a) => a.severity == AlertSeverity.warning);

      if (errors.isNotEmpty) {
        buffer.writeln('#### Errors');
        for (final alert in errors) {
          buffer.writeln('- ❌ **${alert.metric}:** ${alert.message}');
        }
        buffer.writeln('');
      }

      if (warnings.isNotEmpty) {
        buffer.writeln('#### Warnings');
        for (final alert in warnings) {
          buffer.writeln('- ⚠️ **${alert.metric}:** ${alert.message}');
        }
        buffer.writeln('');
      }
    }

    // Recommendations
    if (hasErrors || hasWarnings) {
      buffer.writeln('### 💡 Recommendations');
      buffer.writeln('');

      if (result.alerts.any((a) => a.metric == 'cold_start')) {
        buffer.writeln(
            '- Optimize app initialization and reduce startup dependencies');
      }
      if (result.alerts.any((a) => a.metric == 'memory_usage')) {
        buffer.writeln('- Review memory usage and implement lazy loading');
      }
      if (result.alerts.any((a) => a.metric == 'fps')) {
        buffer.writeln('- Optimize animations and reduce widget rebuilds');
      }
      buffer.writeln('');
    }

    return buffer.toString();
  }
}

/// Performance alert severity.
enum AlertSeverity {
  info,
  warning,
  error,
}

/// Performance alert.
class PerformanceAlert {
  final AlertSeverity severity;
  final String metric;
  final String message;
  final double actualValue;
  final double expectedValue;

  const PerformanceAlert({
    required this.severity,
    required this.metric,
    required this.message,
    required this.actualValue,
    required this.expectedValue,
  });

  double get deviationPercent => (actualValue / expectedValue - 1) * 100;
}

/// Performance alert result.
class PerformanceAlertResult {
  final List<PerformanceAlert> alerts;
  final PerformanceReport report;
  final DateTime timestamp;

  const PerformanceAlertResult({
    required this.alerts,
    required this.report,
    required this.timestamp,
  });

  bool get hasErrors => alerts.any((a) => a.severity == AlertSeverity.error);
  bool get hasWarnings =>
      alerts.any((a) => a.severity == AlertSeverity.warning);
  bool get isHealthy => alerts.isEmpty;
}
