/// Comprehensive error handling system for ephenotes.
///
/// Defines specific error types, user-friendly messages, and recovery strategies.
library;

/// Base class for all application errors.
///
/// Provides structured error information including user-friendly messages,
/// error codes, and recovery suggestions.
abstract class AppError implements Exception {
  /// User-friendly error message to display to users.
  final String userMessage;

  /// Technical error message for debugging.
  final String technicalMessage;

  /// Unique error code for tracking and analytics.
  final String errorCode;

  /// Suggested recovery actions for the user.
  final List<ErrorRecoveryAction> recoveryActions;

  /// Whether this error is recoverable.
  final bool isRecoverable;

  /// Severity level of the error.
  final ErrorSeverity severity;

  const AppError({
    required this.userMessage,
    required this.technicalMessage,
    required this.errorCode,
    this.recoveryActions = const [],
    this.isRecoverable = true,
    this.severity = ErrorSeverity.medium,
  });

  @override
  String toString() => technicalMessage;
}

/// Storage-related errors.
class StorageError extends AppError {
  final StorageErrorType storageType;
  final Object? originalError;

  const StorageError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    required this.storageType,
    this.originalError,
    super.recoveryActions = const [],
    super.isRecoverable = true,
    super.severity = ErrorSeverity.high,
  });
}

/// Database corruption errors.
class DatabaseCorruptionError extends StorageError {
  /// Whether automatic recovery was attempted.
  final bool recoveryAttempted;

  /// Whether automatic recovery was successful.
  final bool recoverySuccessful;

  const DatabaseCorruptionError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    this.recoveryAttempted = false,
    this.recoverySuccessful = false,
    super.originalError,
    super.recoveryActions = const [],
    super.isRecoverable = true,
  }) : super(
          storageType: StorageErrorType.corruption,
          severity: ErrorSeverity.critical,
        );
}

/// Storage full errors.
class StorageFullError extends StorageError {
  /// Available storage space in bytes.
  final int availableBytes;

  /// Required storage space in bytes.
  final int requiredBytes;

  const StorageFullError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    required this.availableBytes,
    required this.requiredBytes,
    super.originalError,
    super.recoveryActions = const [],
    super.isRecoverable = true,
  }) : super(
          storageType: StorageErrorType.storageFull,
          severity: ErrorSeverity.high,
        );
}

/// Network-related errors (for future use).
class NetworkError extends AppError {
  final NetworkErrorType networkType;

  const NetworkError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    required this.networkType,
    super.recoveryActions = const [],
    super.isRecoverable = true,
    super.severity = ErrorSeverity.medium,
  });
}

/// Validation errors for user input.
class ValidationError extends AppError {
  final String fieldName;
  final dynamic invalidValue;

  const ValidationError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    required this.fieldName,
    this.invalidValue,
    super.recoveryActions = const [],
    super.isRecoverable = true,
    super.severity = ErrorSeverity.low,
  });
}

/// Permission-related errors.
class PermissionError extends AppError {
  final String permissionType;

  const PermissionError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    required this.permissionType,
    super.recoveryActions = const [],
    super.isRecoverable = true,
    super.severity = ErrorSeverity.medium,
  });
}

/// Unknown or unexpected errors.
class UnknownError extends AppError {
  final Object? originalError;
  final StackTrace? stackTrace;

  const UnknownError({
    required super.userMessage,
    required super.technicalMessage,
    required super.errorCode,
    this.originalError,
    this.stackTrace,
    super.recoveryActions = const [],
    super.isRecoverable = false,
    super.severity = ErrorSeverity.critical,
  });
}

/// Types of storage errors.
enum StorageErrorType {
  /// Database file is corrupted.
  corruption,

  /// Storage space is full.
  storageFull,

  /// Permission denied to access storage.
  permissionDenied,

  /// Storage device is not available.
  deviceUnavailable,

  /// Database is locked by another process.
  databaseLocked,

  /// General I/O error.
  ioError,
}

/// Types of network errors.
enum NetworkErrorType {
  /// No internet connection.
  noConnection,

  /// Connection timeout.
  timeout,

  /// Server error.
  serverError,

  /// Authentication failed.
  authenticationFailed,
}

/// Error severity levels.
enum ErrorSeverity {
  /// Low severity - user can continue normally.
  low,

  /// Medium severity - some functionality may be affected.
  medium,

  /// High severity - significant functionality is affected.
  high,

  /// Critical severity - app may not function properly.
  critical,
}

/// Recovery actions that users can take.
class ErrorRecoveryAction {
  /// Display label for the action.
  final String label;

  /// Description of what the action does.
  final String description;

  /// Function to execute when action is selected.
  final Future<void> Function() action;

  /// Whether this action is the primary/recommended action.
  final bool isPrimary;

  const ErrorRecoveryAction({
    required this.label,
    required this.description,
    required this.action,
    this.isPrimary = false,
  });
}
