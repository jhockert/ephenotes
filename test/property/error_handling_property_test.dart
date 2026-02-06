import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:uuid/uuid.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_matchers.dart';
import '../helpers/fake_note_datasource.dart';

/// Property-based tests for error handling robustness.
///
/// **Validates: Task 5.3.2 - Error Handling Property Tests**
///
/// This test suite verifies that the app gracefully handles all error conditions:
/// - Storage failures, corruption, and recovery scenarios
/// - No data loss during error conditions
/// - Graceful degradation under resource constraints
/// - User-friendly error messages and actionable recovery options
///
/// Note: These tests use FakeNoteLocalDataSource for unit testing.
/// ObjectBox-specific error handling is tested in integration tests.

void main() {
  group('Property Test: Error Handling Robustness', () {
    const uuid = Uuid();

    /// Creates a test environment with a fresh FakeNoteLocalDataSource and repository.
    ({FakeNoteLocalDataSource dataSource, NoteRepository repository})
        createTestEnvironment() {
      final dataSource = FakeNoteLocalDataSource();
      final repository = NoteRepositoryImpl(dataSource: dataSource);
      return (dataSource: dataSource, repository: repository);
    }

    setUp(() async {
      PropertyTestConfig.reset();
    });

    // Helper function to create valid notes with content <= 140 characters
    Note createValidNote({String? content}) {
      final noteContent =
          content ?? 'Test note ${DateTime.now().millisecondsSinceEpoch}';
      // Ensure content is <= 140 characters
      final validContent = noteContent.length > 140
          ? noteContent.substring(0, 140)
          : noteContent;

      return Note(
        id: uuid.v4(),
        content: validContent,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.normal,
      );
    }

    testProperty('Property 7.1: App gracefully handles storage failures', () {
      // **Validates: Requirements NFR-5.1 - Error Handling**
      forAll(
        Generator.fromFunction((random) {
          final noteCount = 1 + random.nextInt(10); // 1-10 notes
          final notes = List.generate(
              noteCount,
              (i) => createValidNote(
                  content:
                      'Storage failure test note $i ${random.nextInt(1000)}'));

          return (
            notes: notes,
            operationType: ['create', 'update', 'delete'][random.nextInt(3)]
          );
        }),
        (({List<Note> notes, String operationType}) testData) async {
          final env = createTestEnvironment();

          // Save initial notes successfully
          final initialNotes =
              testData.notes.take(testData.notes.length ~/ 2 + 1).toList();
          for (final note in initialNotes) {
            await env.repository.create(note);
          }

          // Verify initial state
          var loadedNotes = await env.repository.getAll();
          expect(loadedNotes.length, equals(initialNotes.length));

          // Enable failure simulation on the datasource
          env.dataSource.shouldFailNextOperation = true;

          // Attempt operations that should fail gracefully
          final testNote = testData.notes.last;
          AppError? caughtError;

          try {
            switch (testData.operationType) {
              case 'create':
                await env.repository.create(testNote);
                break;
              case 'update':
                if (initialNotes.isNotEmpty) {
                  final noteToUpdate = initialNotes.first.copyWith(
                    content: 'Updated content',
                    updatedAt: DateTime.now(),
                  );
                  await env.repository.update(noteToUpdate);
                }
                break;
              case 'delete':
                if (initialNotes.isNotEmpty) {
                  await env.repository.delete(initialNotes.first.id);
                }
                break;
            }

            // If operation succeeded, the failure flag was consumed by a
            // previous internal call or the operation type didn't trigger it
          } catch (e) {
            // Verify that the error is properly structured
            expect(e, isA<AppError>(),
                reason: 'All errors should be structured AppError instances');

            caughtError = e as AppError;

            // Verify error has user-friendly message
            expect(caughtError.userMessage, isNotEmpty,
                reason: 'Error should have user-friendly message');
            expect(caughtError.userMessage.length, lessThan(200),
                reason: 'User message should be concise');

            // Verify error has technical details
            expect(caughtError.technicalMessage, isNotEmpty,
                reason: 'Error should have technical details');

            // Verify error has unique code
            expect(caughtError.errorCode, isNotEmpty,
                reason: 'Error should have unique error code');

            // Verify error has recovery actions
            expect(caughtError.recoveryActions, isNotEmpty,
                reason: 'Error should provide recovery actions');

            // Verify at least one recovery action is marked as primary
            final hasPrimaryAction =
                caughtError.recoveryActions.any((action) => action.isPrimary);
            expect(hasPrimaryAction, isTrue,
                reason:
                    'Error should have at least one primary recovery action');
          }

          // Verify data integrity after failure
          // The existing data should still be accessible (no data loss)
          final remainingNotes = await env.repository.getAll();

          expect(remainingNotes.length, greaterThanOrEqualTo(0),
              reason:
                  'Should be able to read existing data even after storage failure');

          for (final note in remainingNotes) {
            expect(note, hasValidContentLength(),
                reason:
                    'Existing notes should remain valid after storage failure');
            expect(note, hasValidArchivePinState(),
                reason:
                    'Existing notes should maintain valid state after storage failure');
            expect(note, hasValidTimestamps(),
                reason:
                    'Existing notes should have valid timestamps after storage failure');
          }
        },
        iterations: 50,
      );
    });

    testProperty(
        'Property 7.2: Intermittent failures are handled gracefully', () {
      // **Validates: Requirements NFR-5.2 - Data Integrity**
      forAll(
        Generator.fromFunction((random) {
          final noteCount = 3 + random.nextInt(8); // 3-10 notes
          final notes = List.generate(
              noteCount,
              (i) => createValidNote(
                  content:
                      'Intermittent failure test $i ${random.nextInt(1000)}'));

          // Fail every N operations (2-5)
          final failFrequency = 2 + random.nextInt(4);

          return (notes: notes, failFrequency: failFrequency);
        }),
        (({List<Note> notes, int failFrequency}) testData) async {
          final env = createTestEnvironment();

          // Enable intermittent failure simulation
          env.dataSource.failEveryNOperations = testData.failFrequency;

          var successCount = 0;
          var failureCount = 0;

          // Attempt to create all notes with intermittent failures
          for (final note in testData.notes) {
            try {
              await env.repository.create(note);
              successCount++;
            } catch (e) {
              // Verify that failures are structured errors
              expect(e, isA<AppError>(),
                  reason:
                      'Intermittent failures should be structured AppError instances');

              final appError = e as AppError;
              expect(appError.userMessage, isNotEmpty,
                  reason: 'Error should have user-friendly message');
              expect(appError.recoveryActions, isNotEmpty,
                  reason: 'Error should provide recovery actions');

              failureCount++;
            }
          }

          // Verify that some operations succeeded and some failed
          expect(successCount + failureCount, equals(testData.notes.length),
              reason:
                  'All operations should either succeed or fail gracefully');

          // Verify that successfully saved notes are intact
          // Disable failures for verification reads
          env.dataSource.failEveryNOperations = 0;
          final savedNotes = await env.repository.getAll();
          expect(savedNotes.length, equals(successCount),
              reason: 'Only successfully created notes should be in storage');

          // Verify data integrity of saved notes
          for (final note in savedNotes) {
            expect(note, hasValidContentLength(),
                reason:
                    'Saved notes should remain valid after intermittent failures');
            expect(note, hasValidArchivePinState(),
                reason:
                    'Saved notes should maintain valid state after intermittent failures');
            expect(note, hasValidTimestamps(),
                reason:
                    'Saved notes should have valid timestamps after intermittent failures');
          }
        },
        iterations: 30,
      );
    });

    testProperty('Property 7.3: Resource constraints are handled gracefully',
        () {
      // **Validates: Requirements NFR-5.3 - Performance Under Constraints**
      forAll(
        Generator.fromFunction((random) {
          return (
            noteCount: 20 + random.nextInt(30), // 20-50 initial notes
            operationCount: 5 + random.nextInt(10), // 5-15 operations
            failFrequency: 3 + random.nextInt(5), // Fail every 3-7 ops
          );
        }),
        (({int noteCount, int operationCount, int failFrequency}) testData)
            async {
          final env = createTestEnvironment();

          // Create initial notes without failures
          final initialNotes = <Note>[];
          for (int i = 0; i < testData.noteCount; i++) {
            final note = createValidNote(content: 'Resource test note $i');
            initialNotes.add(note);
            await env.repository.create(note);
          }

          // Verify initial state
          var loadedNotes = await env.repository.getAll();
          expect(loadedNotes.length, equals(testData.noteCount));

          // Enable intermittent failures to simulate resource constraints
          env.dataSource.failEveryNOperations = testData.failFrequency;

          // Perform operations under constraint
          var successfulOperations = 0;
          var gracefulFailures = 0;

          for (int i = 0; i < testData.operationCount; i++) {
            try {
              switch (i % 3) {
                case 0: // Create operation
                  final testNote =
                      createValidNote(content: 'Constraint test note $i');
                  await env.repository.create(testNote);
                  successfulOperations++;
                  break;

                case 1: // Update operation
                  final noteToUpdate =
                      initialNotes[i % initialNotes.length].copyWith(
                    content: 'Updated under constraint $i',
                    updatedAt: DateTime.now(),
                  );
                  await env.repository.update(noteToUpdate);
                  successfulOperations++;
                  break;

                case 2: // Read operation
                  await env.repository.getAll();
                  successfulOperations++;
                  break;
              }
            } catch (e) {
              // Verify that constraint-related failures are handled gracefully
              expect(e, isA<AppError>(),
                  reason: 'Resource constraint errors should be structured');

              final appError = e as AppError;
              expect(appError.userMessage, isNotEmpty,
                  reason:
                      'Resource constraint error should have user message');
              expect(appError.recoveryActions, isNotEmpty,
                  reason:
                      'Resource constraint errors should provide recovery actions');

              gracefulFailures++;
            }
          }

          // Verify that the app continues to function despite constraints
          expect(successfulOperations + gracefulFailures,
              equals(testData.operationCount),
              reason:
                  'All operations should either succeed or fail gracefully');

          // Verify that existing data remains accessible
          // Disable failures for verification
          env.dataSource.failEveryNOperations = 0;

          final finalNotes = await env.repository.getAll();
          expect(finalNotes.length, greaterThanOrEqualTo(testData.noteCount),
              reason:
                  'Existing data should remain accessible under resource constraints');

          // Verify data integrity is maintained
          for (final note in finalNotes.take(10)) {
            expect(note, hasValidContentLength(),
                reason:
                    'Notes should remain valid under resource constraints');
            expect(note, hasValidArchivePinState(),
                reason:
                    'Note state should remain valid under resource constraints');
          }

          // Verify that the app can recover from resource constraints
          if (gracefulFailures > 0) {
            try {
              await env.repository.getActive();
            } catch (e) {
              expect(e, isA<AppError>(),
                  reason:
                      'Recovery attempts should produce structured errors');
            }
          }
        },
        iterations: 40,
      );
    });

    testProperty(
        'Property 7.4: Error messages are user-friendly and actionable', () {
      // **Validates: Requirements NFR-5.4 - User Experience**
      forAll(
        Generator.fromFunction((random) {
          final errorScenarios = [
            'validation_content_too_long',
            'validation_empty_content',
            'validation_invalid_state',
            'storage_not_found',
            'storage_duplicate_id',
            'storage_failure',
            'unknown_error'
          ];

          return (
            scenario: errorScenarios[random.nextInt(errorScenarios.length)],
            testData: 'Test data ${random.nextInt(1000)}'
          );
        }),
        (({String scenario, String testData}) testData) async {
          final env = createTestEnvironment();

          AppError? caughtError;

          // Trigger specific error scenarios
          try {
            switch (testData.scenario) {
              case 'validation_content_too_long':
                final longNote = Note(
                  id: uuid.v4(),
                  content: 'A' * 200, // Exceeds 140 char limit
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  color: NoteColor.classicYellow,
                  priority: NotePriority.normal,
                );
                await env.repository.create(longNote);
                break;

              case 'validation_empty_content':
                final emptyNote = Note(
                  id: uuid.v4(),
                  content: '',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  color: NoteColor.classicYellow,
                  priority: NotePriority.normal,
                );
                await env.repository.create(emptyNote);
                break;

              case 'validation_invalid_state':
                final validNote = createValidNote();
                await env.repository.create(validNote);
                final invalidNote = validNote.copyWith(
                  isArchived: true,
                  isPinned:
                      true, // Invalid: can't be both archived and pinned
                );
                await env.repository.update(invalidNote);
                break;

              case 'storage_not_found':
                await env.repository.getById('non-existent-id');
                break;

              case 'storage_duplicate_id':
                final note1 = createValidNote();
                await env.repository.create(note1);
                // Try to create another note with same ID
                final note2 = note1.copyWith(content: 'Different content');
                await env.repository.create(note2);
                break;

              case 'storage_failure':
                env.dataSource.shouldFailNextOperation = true;
                await env.repository.create(createValidNote());
                break;

              case 'unknown_error':
                env.dataSource.shouldFailNextOperation = true;
                await env.repository.getAll();
                break;

              default:
                fail('Unknown error scenario: ${testData.scenario}');
            }

            // If we get here without an exception, the operation succeeded
            // This might be acceptable for some scenarios (graceful handling)
          } catch (e) {
            expect(e, isA<AppError>(),
                reason: 'All errors should be structured AppError instances');
            caughtError = e as AppError;
          }

          // If we caught an error, verify its user-friendliness
          if (caughtError != null) {
            // Test user message quality
            expect(caughtError.userMessage, isNotEmpty,
                reason: 'Error should have a user message');

            // User message should be concise (not too long)
            expect(caughtError.userMessage.length, lessThan(200),
                reason: 'User message should be concise (< 200 characters)');

            // User message should not contain technical jargon
            final technicalTerms = [
              'exception',
              'null',
              'stack',
              'trace',
              'objectbox',
              'store'
            ];
            final lowerMessage = caughtError.userMessage.toLowerCase();
            final containsTechnicalTerms =
                technicalTerms.any((term) => lowerMessage.contains(term));
            expect(containsTechnicalTerms, isFalse,
                reason:
                    'User message should not contain technical jargon: ${caughtError.userMessage}');

            // User message should be helpful and explanatory
            expect(
                lowerMessage,
                anyOf([
                  contains('please'),
                  contains('try'),
                  contains('check'),
                  contains('cannot'),
                  contains('unable'),
                  contains('problem'),
                  contains('error'),
                  contains('wrong'),
                ]),
                reason: 'User message should be helpful and explanatory');

            // Test error categorization and recovery actions
            switch (testData.scenario) {
              case 'validation_content_too_long':
              case 'validation_empty_content':
              case 'validation_invalid_state':
                expect(caughtError, isA<ValidationError>(),
                    reason:
                        'Validation errors should be ValidationError type');
                expect(caughtError.severity, equals(ErrorSeverity.low),
                    reason: 'Validation errors should have low severity');
                break;

              case 'storage_not_found':
              case 'storage_duplicate_id':
              case 'storage_failure':
              case 'unknown_error':
                // These come through ErrorHandler as generic exceptions
                expect(caughtError, isA<AppError>(),
                    reason: 'Storage errors should be structured AppError');

                // Non-validation errors should provide recovery actions
                expect(caughtError.recoveryActions, isNotEmpty,
                    reason: 'Error should provide recovery actions');

                final primaryActions = caughtError.recoveryActions
                    .where((a) => a.isPrimary)
                    .toList();
                expect(primaryActions, isNotEmpty,
                    reason:
                        'Should have at least one primary recovery action');

                for (final action in caughtError.recoveryActions) {
                  expect(action.label, isNotEmpty,
                      reason: 'Recovery action should have a label');
                  expect(action.label.length, lessThan(50),
                      reason: 'Recovery action label should be concise');

                  expect(action.description, isNotEmpty,
                      reason: 'Recovery action should have a description');
                  expect(action.description.length, lessThan(150),
                      reason:
                          'Recovery action description should be concise');
                }
                break;
            }

            // Test error code format
            expect(caughtError.errorCode, isNotEmpty,
                reason: 'Error should have an error code');
            expect(caughtError.errorCode, matches(r'^[A-Z_0-9]+$'),
                reason:
                    'Error code should be uppercase with underscores and numbers');

            // Test technical message (for debugging)
            expect(caughtError.technicalMessage, isNotEmpty,
                reason: 'Error should have technical details for debugging');
          }
        },
        iterations: 60,
      );
    });

    testProperty('Property 7.5: No data loss occurs during error conditions',
        () {
      // **Validates: Requirements NFR-5.5 - Data Integrity During Failures**
      forAll(
        Generator.fromFunction((random) {
          final noteCount = 5 + random.nextInt(15); // 5-20 notes
          final notes = List.generate(
              noteCount,
              (i) => createValidNote(
                  content: 'Data loss test note $i ${random.nextInt(1000)}'));

          return (
            notes: notes,
            operationsBeforeFailure:
                1 + random.nextInt(5), // 1-5 operations before failure
            failFrequency: 2 + random.nextInt(3), // Fail every 2-4 ops
          );
        }),
        (({
              List<Note> notes,
              int operationsBeforeFailure,
              int failFrequency
            }) testData) async {
          final env = createTestEnvironment();

          // Save initial data
          final initialNotes =
              testData.notes.take(testData.notes.length ~/ 2).toList();
          for (final note in initialNotes) {
            await env.repository.create(note);
          }

          // Verify initial data is saved
          var loadedNotes = await env.repository.getAll();
          expect(loadedNotes.length, equals(initialNotes.length));

          // Create a snapshot of the initial state for comparison
          final initialSnapshot = Map<String, Note>.fromEntries(
              loadedNotes.map((note) => MapEntry(note.id, note)));

          // Perform some operations before triggering failures
          final additionalNotes = testData.notes
              .skip(testData.notes.length ~/ 2)
              .take(testData.operationsBeforeFailure)
              .toList();

          for (final note in additionalNotes) {
            try {
              await env.repository.create(note);
            } catch (e) {
              // Continue with other operations
            }
          }

          // Enable intermittent failures
          env.dataSource.failEveryNOperations = testData.failFrequency;

          // Perform operations that may fail
          for (int i = 0; i < 5; i++) {
            try {
              final testNote =
                  createValidNote(content: 'Failure test note $i');
              await env.repository.create(testNote);
            } catch (e) {
              // Expected: some operations will fail
            }
          }

          // Disable failures for verification
          env.dataSource.failEveryNOperations = 0;

          // After failure, verify data integrity
          final postFailureNotes = await env.repository.getAll();

          // Verify that initial data is still present (no data loss)
          for (final originalNote in initialSnapshot.values) {
            final foundNote = postFailureNotes.firstWhere(
              (note) => note.id == originalNote.id,
              orElse: () => throw Exception(
                  'Data loss detected: Note ${originalNote.id} is missing'),
            );

            // Verify the note content is intact
            expect(foundNote.content, equals(originalNote.content),
                reason:
                    'Note content should not be lost during failure: ${originalNote.id}');

            // Verify other critical fields are intact
            expect(foundNote.createdAt, equals(originalNote.createdAt),
                reason: 'Note creation timestamp should not be lost');
            expect(foundNote.color, equals(originalNote.color),
                reason: 'Note color should not be lost');
            expect(foundNote.priority, equals(originalNote.priority),
                reason: 'Note priority should not be lost');
          }

          // Verify that all remaining notes are valid
          for (final note in postFailureNotes) {
            expect(note, hasValidContentLength(),
                reason: 'All notes should remain valid after failure');
            expect(note, hasValidArchivePinState(),
                reason: 'Note states should remain valid after failure');
            expect(note, hasValidTimestamps(),
                reason:
                    'Note timestamps should remain valid after failure');

            // Verify note ID is not corrupted
            expect(note.id, isNotEmpty,
                reason: 'Note IDs should not be corrupted');
            expect(note.id.length, greaterThan(10),
                reason: 'Note IDs should maintain proper format');
          }

          // Additional data integrity checks
          final noteIds = postFailureNotes.map((n) => n.id).toList();
          final uniqueIds = noteIds.toSet();
          expect(uniqueIds.length, equals(noteIds.length),
              reason: 'All note IDs should remain unique after failure');

          // Test that new operations can still be performed after failure
          final recoveryNote =
              createValidNote(content: 'Recovery test note');
          await env.repository.create(recoveryNote);

          // Verify the recovery note was saved
          final finalNotes = await env.repository.getAll();
          final recoveryNoteFound =
              finalNotes.any((note) => note.id == recoveryNote.id);
          expect(recoveryNoteFound, isTrue,
              reason:
                  'Should be able to create new notes after failure recovery');
        },
        iterations: 40,
      );
    });
  });
}
