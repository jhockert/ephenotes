import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:ephenotes/core/error/error_handler.dart';

void main() {
  group('Error Handling Tests', () {
    test('should handle validation errors correctly', () {
      final error = ValidationError(
        userMessage: 'Note content cannot exceed 140 characters.',
        technicalMessage: 'Note content length: 150',
        errorCode: 'VALIDATION_CONTENT_LENGTH',
        fieldName: 'content',
        invalidValue: 'A' * 150,
      );

      expect(error.userMessage, 'Note content cannot exceed 140 characters.');
      expect(error.errorCode, 'VALIDATION_CONTENT_LENGTH');
      expect(error.fieldName, 'content');
      expect(error.isRecoverable, true);
      expect(error.severity, ErrorSeverity.low);
    });

    test('should handle storage errors correctly', () {
      const error = StorageError(
        userMessage: 'There was a problem accessing your notes.',
        technicalMessage: 'Database connection failed',
        errorCode: 'STORAGE_001',
        storageType: StorageErrorType.ioError,
      );

      expect(error.userMessage, 'There was a problem accessing your notes.');
      expect(error.storageType, StorageErrorType.ioError);
      expect(error.severity, ErrorSeverity.high);
    });

    test('should handle database corruption errors correctly', () {
      const error = DatabaseCorruptionError(
        userMessage: 'Your notes database appears to be corrupted.',
        technicalMessage: 'Hive database corruption detected',
        errorCode: 'DB_CORRUPT_001',
        recoveryAttempted: true,
        recoverySuccessful: false,
      );

      expect(error.userMessage, 'Your notes database appears to be corrupted.');
      expect(error.recoveryAttempted, true);
      expect(error.recoverySuccessful, false);
      expect(error.severity, ErrorSeverity.critical);
    });

    test('should handle storage full errors correctly', () {
      const error = StorageFullError(
        userMessage: 'Your device storage is full.',
        technicalMessage: 'Storage full error',
        errorCode: 'STORAGE_FULL_001',
        availableBytes: 0,
        requiredBytes: 1024,
      );

      expect(error.userMessage, 'Your device storage is full.');
      expect(error.availableBytes, 0);
      expect(error.requiredBytes, 1024);
      expect(error.severity, ErrorSeverity.high);
    });

    test('should convert generic exceptions to structured errors', () {
      final genericException = Exception('Something went wrong');
      final appError = ErrorHandler.handleError(genericException);

      expect(appError, isA<UnknownError>());
      expect(appError.userMessage, 'Something went wrong. Please try again.');
      expect(appError.isRecoverable, false);
      expect(appError.severity, ErrorSeverity.critical);
    });

    test('should handle argument errors as validation errors', () {
      final argumentError = ArgumentError('Invalid input');
      final appError = ErrorHandler.handleError(argumentError);

      expect(appError, isA<ValidationError>());
      expect(appError.userMessage, 'Please check your input and try again.');
      expect(appError.severity, ErrorSeverity.low);
    });

    test('should preserve existing AppError instances', () {
      const originalError = ValidationError(
        userMessage: 'Original message',
        technicalMessage: 'Original technical message',
        errorCode: 'ORIGINAL_001',
        fieldName: 'test',
      );

      final handledError = ErrorHandler.handleError(originalError);

      expect(handledError, same(originalError));
    });
  });

  group('Error Recovery Actions', () {
    test('should provide recovery actions for errors', () {
      final error = StorageError(
        userMessage: 'Storage error',
        technicalMessage: 'Storage error details',
        errorCode: 'STORAGE_001',
        storageType: StorageErrorType.ioError,
        recoveryActions: [
          ErrorRecoveryAction(
            label: 'Retry',
            description: 'Try again',
            action: () async {},
            isPrimary: true,
          ),
        ],
      );

      expect(error.recoveryActions.length, 1);
      expect(error.recoveryActions.first.label, 'Retry');
      expect(error.recoveryActions.first.isPrimary, true);
    });

    test('should identify primary recovery action', () {
      final actions = [
        ErrorRecoveryAction(
          label: 'Secondary',
          description: 'Secondary action',
          action: () async {},
          isPrimary: false,
        ),
        ErrorRecoveryAction(
          label: 'Primary',
          description: 'Primary action',
          action: () async {},
          isPrimary: true,
        ),
      ];

      StorageError(
        userMessage: 'Storage error',
        technicalMessage: 'Storage error details',
        errorCode: 'STORAGE_001',
        storageType: StorageErrorType.ioError,
        recoveryActions: actions,
      );

      final primaryAction = actions.firstWhere((action) => action.isPrimary);
      expect(primaryAction.label, 'Primary');
    });
  });
}
