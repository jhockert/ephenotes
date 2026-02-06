import 'dart:io';
import 'package:objectbox/objectbox.dart';
import 'package:ephenotes/core/error/app_error.dart';

/// Service for handling and categorizing errors throughout the application.
///
/// Provides methods to convert generic exceptions into structured [AppError]
/// instances with user-friendly messages and recovery actions.
class ErrorHandler {
  /// Converts a generic exception into a structured [AppError].
  static AppError handleError(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    // Handle ObjectBox-specific errors
    if (error is ObjectBoxException) {
      return _handleObjectBoxError(error, stackTrace);
    }

    // Handle file system errors
    if (error is FileSystemException) {
      return _handleFileSystemError(error, stackTrace);
    }

    // Handle storage-related errors
    if (error is IOException) {
      return _handleIOError(error, stackTrace);
    }

    // Handle validation errors
    if (error is ArgumentError || error is FormatException) {
      return _handleValidationError(error, stackTrace);
    }

    // Handle generic exceptions
    if (error is Exception) {
      return _handleGenericException(error, stackTrace);
    }

    // Handle unknown errors
    return UnknownError(
      userMessage: 'An unexpected error occurred. Please try again.',
      technicalMessage: 'Unknown error: ${error.toString()}',
      errorCode: 'UNKNOWN_001',
      originalError: error,
      stackTrace: stackTrace,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Retry',
          description: 'Try the operation again',
          action: () async {
            // This will be implemented by the calling code
          },
          isPrimary: true,
        ),
        ErrorRecoveryAction(
          label: 'Report Issue',
          description: 'Report this issue to help improve the app',
          action: () async {
            // This could open a feedback form or email
          },
        ),
      ],
    );
  }

  /// Handles ObjectBox database errors.
  static AppError _handleObjectBoxError(
      ObjectBoxException error, StackTrace? stackTrace) {
    final errorMessage = error.message.toLowerCase();

    // Check for database corruption
    if (_isDatabaseCorruption(error)) {
      return DatabaseCorruptionError(
        userMessage:
            'Your notes database appears to be corrupted. We\'ll try to recover your data.',
        technicalMessage:
            'ObjectBox database corruption detected: ${error.message}',
        errorCode: 'DB_CORRUPT_001',
        originalError: error,
        recoveryActions: [
          ErrorRecoveryAction(
            label: 'Restart App',
            description: 'Restart the app to attempt recovery',
            action: () async {},
            isPrimary: true,
          ),
          ErrorRecoveryAction(
            label: 'Report Issue',
            description: 'Report this issue for assistance',
            action: () async {},
          ),
        ],
      );
    }

    // Check for database lock or access issues
    if (errorMessage.contains('lock') ||
        errorMessage.contains('access') ||
        errorMessage.contains('busy')) {
      return StorageError(
        userMessage:
            'The notes database is temporarily unavailable. Please try again in a moment.',
        technicalMessage: 'Database locked or busy: ${error.message}',
        errorCode: 'DB_LOCK_001',
        storageType: StorageErrorType.databaseLocked,
        originalError: error,
        recoveryActions: [
          ErrorRecoveryAction(
            label: 'Retry',
            description: 'Try again in a few seconds',
            action: () async {
              await Future.delayed(const Duration(seconds: 2));
            },
            isPrimary: true,
          ),
        ],
      );
    }

    // Generic ObjectBox error
    return StorageError(
      userMessage:
          'There was a problem accessing your notes. Please try again.',
      technicalMessage: 'ObjectBox error: ${error.message}',
      errorCode: 'OBJECTBOX_001',
      storageType: StorageErrorType.ioError,
      originalError: error,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Retry',
          description: 'Try the operation again',
          action: () async {},
          isPrimary: true,
        ),
      ],
    );
  }

  /// Handles file system errors.
  static AppError _handleFileSystemError(
      FileSystemException error, StackTrace? stackTrace) {
    // Check for storage full
    if (_isStorageFullError(error)) {
      return StorageFullError(
        userMessage:
            'Your device storage is full. Please free up some space and try again.',
        technicalMessage: 'Storage full: ${error.message}',
        errorCode: 'STORAGE_FULL_001',
        availableBytes: 0, // Would be calculated in real implementation
        requiredBytes: 1024, // Estimated requirement
        originalError: error,
        recoveryActions: [
          ErrorRecoveryAction(
            label: 'Free Up Space',
            description: 'Open device settings to manage storage',
            action: () async {
              // This would open device storage settings
            },
            isPrimary: true,
          ),
          ErrorRecoveryAction(
            label: 'Archive Old Notes',
            description: 'Archive some notes to free up space',
            action: () async {
              // This would navigate to archive management
            },
          ),
        ],
      );
    }

    // Check for permission denied
    if (error.osError?.errorCode == 13) {
      // EACCES
      return PermissionError(
        userMessage: 'Permission denied. The app cannot access storage.',
        technicalMessage: 'File permission error: ${error.message}',
        errorCode: 'PERMISSION_001',
        permissionType: 'storage',
        recoveryActions: [
          ErrorRecoveryAction(
            label: 'Check Permissions',
            description: 'Open app settings to grant storage permission',
            action: () async {
              // This would open app settings
            },
            isPrimary: true,
          ),
        ],
      );
    }

    // Generic file system error
    return StorageError(
      userMessage:
          'There was a problem accessing your files. Please try again.',
      technicalMessage: 'File system error: ${error.message}',
      errorCode: 'FS_001',
      storageType: StorageErrorType.ioError,
      originalError: error,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Retry',
          description: 'Try the operation again',
          action: () async {},
          isPrimary: true,
        ),
      ],
    );
  }

  /// Handles I/O errors.
  static AppError _handleIOError(IOException error, StackTrace? stackTrace) {
    return StorageError(
      userMessage:
          'There was a problem reading or writing data. Please try again.',
      technicalMessage: 'I/O error: ${error.toString()}',
      errorCode: 'IO_001',
      storageType: StorageErrorType.ioError,
      originalError: error,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Retry',
          description: 'Try the operation again',
          action: () async {},
          isPrimary: true,
        ),
      ],
    );
  }

  /// Handles validation errors.
  static AppError _handleValidationError(Object error, StackTrace? stackTrace) {
    String fieldName = 'input';
    String userMessage = 'Please check your input and try again.';

    // Check for specific validation errors
    final errorMessage = error.toString().toLowerCase();
    if (errorMessage.contains('140 character')) {
      fieldName = 'content';
      userMessage = 'Note content cannot exceed 140 characters.';
    } else if (errorMessage.contains('empty')) {
      userMessage = 'This field cannot be empty.';
    }

    return ValidationError(
      userMessage: userMessage,
      technicalMessage: 'Validation error: ${error.toString()}',
      errorCode: 'VALIDATION_001',
      fieldName: fieldName,
      invalidValue: null,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Edit Input',
          description: 'Correct the input and try again',
          action: () async {},
          isPrimary: true,
        ),
      ],
    );
  }

  /// Handles generic exceptions.
  static AppError _handleGenericException(
      Exception error, StackTrace? stackTrace) {
    return UnknownError(
      userMessage: 'Something went wrong. Please try again.',
      technicalMessage: 'Exception: ${error.toString()}',
      errorCode: 'EXCEPTION_001',
      originalError: error,
      stackTrace: stackTrace,
      recoveryActions: [
        ErrorRecoveryAction(
          label: 'Retry',
          description: 'Try the operation again',
          action: () async {},
          isPrimary: true,
        ),
      ],
    );
  }

  /// Checks if an ObjectBox error indicates database corruption.
  static bool _isDatabaseCorruption(ObjectBoxException error) {
    final message = error.message.toLowerCase();
    return message.contains('corrupt') ||
        message.contains('invalid') ||
        message.contains('damaged') ||
        message.contains('bad file') ||
        message.contains('not a valid');
  }

  /// Checks if a file system error indicates storage is full.
  static bool _isStorageFullError(FileSystemException error) {
    return error.osError?.errorCode == 28 || // ENOSPC (No space left on device)
        error.message.toLowerCase().contains('no space') ||
        error.message.toLowerCase().contains('disk full');
  }

  /// Gets user-friendly error messages for common error types.
  static String getUserFriendlyMessage(AppError error) {
    switch (error) {
      case DatabaseCorruptionError _:
        return 'Your notes database needs repair. Please restart the app.';
      case StorageFullError _:
        return 'Your device is running out of storage space. Please free up some space to continue.';
      case ValidationError _:
        return error.userMessage;
      case PermissionError _:
        return 'The app needs permission to access your device storage.';
      case NetworkError _:
        return 'Please check your internet connection and try again.';
      default:
        return error.userMessage;
    }
  }

  /// Gets appropriate recovery actions for an error.
  static List<ErrorRecoveryAction> getRecoveryActions(AppError error) {
    if (error.recoveryActions.isNotEmpty) {
      return error.recoveryActions;
    }

    // Default recovery actions based on error type
    return switch (error) {
      StorageError _ || DatabaseCorruptionError _ => [
          ErrorRecoveryAction(
            label: 'Retry',
            description: 'Try the operation again',
            action: () async {},
            isPrimary: true,
          ),
          ErrorRecoveryAction(
            label: 'Get Help',
            description: 'Contact support for assistance',
            action: () async {},
          ),
        ],
      _ => [
          ErrorRecoveryAction(
            label: 'Retry',
            description: 'Try again',
            action: () async {},
            isPrimary: true,
          ),
        ],
    };
  }
}
