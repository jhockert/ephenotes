import 'dart:math';
import 'package:objectbox/objectbox.dart';
import 'package:ephenotes/data/models/note.dart';

/// Monitors database health and detects corruption or storage issues.
///
/// Provides methods to check database integrity, monitor storage space,
/// and perform automatic recovery when possible.
class DatabaseHealthMonitor {
  final Store _store;

  DatabaseHealthMonitor(this._store);

  static const int _minStorageBytes = 10 * 1024 * 1024; // 10MB minimum
  static const int _criticalStorageBytes = 5 * 1024 * 1024; // 5MB critical

  /// Performs a comprehensive health check on the database.
  Future<DatabaseHealthResult> performHealthCheck() async {
    final results = <HealthCheckResult>[];

    // Check database accessibility
    results.add(await _checkDatabaseAccessibility());

    // Check data integrity
    results.add(await _checkDataIntegrity());

    // Check storage space
    results.add(await _checkStorageSpace());

    // Check database size and performance
    results.add(await _checkDatabasePerformance());

    // Determine overall health
    final hasErrors = results.any((r) => r.status == HealthStatus.error);
    final hasWarnings = results.any((r) => r.status == HealthStatus.warning);

    final overallStatus = hasErrors
        ? HealthStatus.error
        : hasWarnings
            ? HealthStatus.warning
            : HealthStatus.healthy;

    return DatabaseHealthResult(
      overallStatus: overallStatus,
      checks: results,
      timestamp: DateTime.now(),
    );
  }

  /// Checks if the database is accessible and not corrupted.
  Future<HealthCheckResult> _checkDatabaseAccessibility() async {
    try {
      // Try to access the notes box
      final noteBox = _store.box<Note>();

      // Try to perform a basic operation
      final count = noteBox.count();

      return HealthCheckResult(
        checkName: 'Database Accessibility',
        status: HealthStatus.healthy,
        message: 'Database is accessible and functional',
        details: '$count notes in database',
      );
    } catch (e) {
      return HealthCheckResult(
        checkName: 'Database Accessibility',
        status: HealthStatus.error,
        message: 'Database is not accessible',
        details: e.toString(),
        error: e,
      );
    }
  }

  /// Checks data integrity by validating existing notes.
  Future<HealthCheckResult> _checkDataIntegrity() async {
    try {
      final noteBox = _store.box<Note>();
      final notes = noteBox.getAll();

      int corruptedNotes = 0;
      final corruptionDetails = <String>[];

      for (final note in notes) {
        try {
          // Validate note structure
          if (note.id.isEmpty) {
            corruptedNotes++;
            corruptionDetails.add('Note with empty ID found');
          }

          if (note.content.length > 140) {
            corruptedNotes++;
            corruptionDetails
                .add('Note exceeds 140 character limit: ${note.id}');
          }

          // Check for invalid timestamps
          if (note.createdAt
              .isAfter(DateTime.now().add(const Duration(days: 1)))) {
            corruptedNotes++;
            corruptionDetails.add('Note has future creation date: ${note.id}');
          }

          if (note.updatedAt.isBefore(note.createdAt)) {
            corruptedNotes++;
            corruptionDetails
                .add('Note has invalid update timestamp: ${note.id}');
          }

          // Check for invalid state combinations
          if (note.isArchived && note.isPinned) {
            corruptedNotes++;
            corruptionDetails
                .add('Note is both archived and pinned: ${note.id}');
          }
        } catch (e) {
          corruptedNotes++;
          corruptionDetails.add('Error validating note: $e');
        }
      }

      if (corruptedNotes > 0) {
        final severity = corruptedNotes > notes.length * 0.1
            ? HealthStatus.error
            : HealthStatus.warning;

        return HealthCheckResult(
          checkName: 'Data Integrity',
          status: severity,
          message:
              '$corruptedNotes corrupted notes found out of ${notes.length}',
          details: corruptionDetails.join('\n'),
        );
      }

      return HealthCheckResult(
        checkName: 'Data Integrity',
        status: HealthStatus.healthy,
        message: 'All ${notes.length} notes are valid',
      );
    } catch (e) {
      return HealthCheckResult(
        checkName: 'Data Integrity',
        status: HealthStatus.error,
        message: 'Cannot validate data integrity',
        details: e.toString(),
        error: e,
      );
    }
  }

  /// Checks available storage space.
  static Future<HealthCheckResult> _checkStorageSpace() async {
    try {
      // Try to estimate available space (this is platform-dependent)
      // For a more accurate implementation, you'd use platform-specific APIs
      final availableBytes = await _getAvailableStorageSpace();

      if (availableBytes < _criticalStorageBytes) {
        return HealthCheckResult(
          checkName: 'Storage Space',
          status: HealthStatus.error,
          message: 'Critical: Only ${_formatBytes(availableBytes)} available',
          details: 'Less than ${_formatBytes(_criticalStorageBytes)} remaining',
        );
      }

      if (availableBytes < _minStorageBytes) {
        return HealthCheckResult(
          checkName: 'Storage Space',
          status: HealthStatus.warning,
          message: 'Low storage: ${_formatBytes(availableBytes)} available',
          details: 'Consider freeing up space',
        );
      }

      return HealthCheckResult(
        checkName: 'Storage Space',
        status: HealthStatus.healthy,
        message: '${_formatBytes(availableBytes)} available',
      );
    } catch (e) {
      return HealthCheckResult(
        checkName: 'Storage Space',
        status: HealthStatus.warning,
        message: 'Cannot determine storage space',
        details: e.toString(),
        error: e,
      );
    }
  }

  /// Checks database performance and size.
  Future<HealthCheckResult> _checkDatabasePerformance() async {
    try {
      final noteBox = _store.box<Note>();
      final noteCount = noteBox.count();

      // Check if we're approaching the 1000 note limit
      if (noteCount > 900) {
        return HealthCheckResult(
          checkName: 'Database Performance',
          status: HealthStatus.warning,
          message: 'Approaching note limit: $noteCount/1000 notes',
          details: 'Consider archiving old notes',
        );
      }

      if (noteCount > 1000) {
        return HealthCheckResult(
          checkName: 'Database Performance',
          status: HealthStatus.error,
          message: 'Note limit exceeded: $noteCount/1000 notes',
          details: 'App performance may be degraded',
        );
      }

      // Measure basic operation performance
      final stopwatch = Stopwatch()..start();
      final query = noteBox.query().build();
      final notes = query.find();
      final limitedNotes = notes.take(min(100, noteCount)).toList();
      query.close();
      stopwatch.stop();

      final readTimeMs = stopwatch.elapsedMilliseconds;
      if (readTimeMs > 1000) {
        // More than 1 second to read 100 notes
        return HealthCheckResult(
          checkName: 'Database Performance',
          status: HealthStatus.warning,
          message: 'Slow database performance detected',
          details: 'Read time: ${readTimeMs}ms for ${limitedNotes.length} notes',
        );
      }

      return HealthCheckResult(
        checkName: 'Database Performance',
        status: HealthStatus.healthy,
        message: '$noteCount notes, read time: ${readTimeMs}ms',
      );
    } catch (e) {
      return HealthCheckResult(
        checkName: 'Database Performance',
        status: HealthStatus.error,
        message: 'Cannot assess database performance',
        details: e.toString(),
        error: e,
      );
    }
  }

  /// Attempts to repair database corruption.
  Future<RepairResult> attemptRepair() async {
    final repairedIssues = <String>[];
    final failedRepairs = <String>[];

    try {
      final noteBox = _store.box<Note>();
      final notes = noteBox.getAll();

      // Repair corrupted notes
      for (final note in notes) {
        try {
          bool needsRepair = false;
          Note repairedNote = note;

          // Fix content length issues
          if (note.content.length > 140) {
            repairedNote = repairedNote.copyWith(
              content: note.content.substring(0, 140),
            );
            needsRepair = true;
            repairedIssues.add('Truncated content for note ${note.id}');
          }

          // Fix invalid state combinations
          if (note.isArchived && note.isPinned) {
            repairedNote = repairedNote.copyWith(isPinned: false);
            needsRepair = true;
            repairedIssues.add('Removed pin from archived note ${note.id}');
          }

          // Fix invalid timestamps
          if (note.updatedAt.isBefore(note.createdAt)) {
            repairedNote = repairedNote.copyWith(updatedAt: note.createdAt);
            needsRepair = true;
            repairedIssues.add('Fixed timestamp for note ${note.id}');
          }

          if (needsRepair) {
            noteBox.put(repairedNote);
          }
        } catch (e) {
          failedRepairs.add('Failed to repair note ${note.id}: $e');
        }
      }

      return RepairResult(
        success: failedRepairs.isEmpty,
        repairedIssues: repairedIssues,
        failedRepairs: failedRepairs,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      return RepairResult(
        success: false,
        repairedIssues: repairedIssues,
        failedRepairs: ['Database repair failed: $e'],
        timestamp: DateTime.now(),
      );
    }
  }

  /// Estimates available storage space (simplified implementation).
  static Future<int> _getAvailableStorageSpace() async {
    try {
      // This is a simplified implementation
      // In a real app, you'd use platform-specific APIs to get accurate storage info

      // Return a reasonable estimate (this would be platform-specific in reality)
      return 100 * 1024 * 1024; // 100MB estimate
    } catch (e) {
      return 0;
    }
  }

  /// Formats bytes into human-readable format.
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }
}

/// Result of a database health check.
class DatabaseHealthResult {
  final HealthStatus overallStatus;
  final List<HealthCheckResult> checks;
  final DateTime timestamp;

  const DatabaseHealthResult({
    required this.overallStatus,
    required this.checks,
    required this.timestamp,
  });

  /// Gets all error checks.
  List<HealthCheckResult> get errors =>
      checks.where((c) => c.status == HealthStatus.error).toList();

  /// Gets all warning checks.
  List<HealthCheckResult> get warnings =>
      checks.where((c) => c.status == HealthStatus.warning).toList();

  /// Whether the database is healthy.
  bool get isHealthy => overallStatus == HealthStatus.healthy;

  /// Whether there are critical issues.
  bool get hasCriticalIssues => overallStatus == HealthStatus.error;
}

/// Result of an individual health check.
class HealthCheckResult {
  final String checkName;
  final HealthStatus status;
  final String message;
  final String? details;
  final Object? error;

  const HealthCheckResult({
    required this.checkName,
    required this.status,
    required this.message,
    this.details,
    this.error,
  });
}

/// Result of a database repair operation.
class RepairResult {
  final bool success;
  final List<String> repairedIssues;
  final List<String> failedRepairs;
  final DateTime timestamp;

  const RepairResult({
    required this.success,
    required this.repairedIssues,
    required this.failedRepairs,
    required this.timestamp,
  });

  /// Whether any issues were repaired.
  bool get hasRepairedIssues => repairedIssues.isNotEmpty;

  /// Whether any repairs failed.
  bool get hasFailedRepairs => failedRepairs.isNotEmpty;
}

/// Health status levels.
enum HealthStatus {
  healthy,
  warning,
  error,
}
