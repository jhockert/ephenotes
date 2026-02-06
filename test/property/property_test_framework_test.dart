import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/note_matchers.dart';

/// Test suite for the property-based testing framework itself.
///
/// This file verifies that the PBT framework components work correctly
/// and demonstrates how to use them for testing Note-related properties.

void main() {
  group('Property-Based Testing Framework', () {
    setUp(() {
      // Reset random state for reproducible tests
      PropertyTestConfig.reset();
    });

    group('Basic Framework', () {
      testProperty('forAll executes specified number of iterations', () {
        int executionCount = 0;

        forAll(
          stringGenerator(maxLength: 10),
          (String value) {
            executionCount++;
            expect(value, isA<String>());
          },
          iterations: 50,
        );

        expect(executionCount, equals(50));
      });

      testProperty('forAll2 works with two generators', () {
        int executionCount = 0;

        forAll2(
          stringGenerator(maxLength: 5),
          intGenerator(max: 100),
          (String str, int num) {
            executionCount++;
            expect(str, isA<String>());
            expect(num, isA<int>());
            expect(num, lessThanOrEqualTo(100));
          },
          iterations: 25,
        );

        expect(executionCount, equals(25));
      });

      test('PropertyTestFailure provides context on failure', () {
        expect(
          () => forAll(
            Generator.constant('test'),
            (String value) {
              throw Exception('Test failure');
            },
            iterations: 1,
          ),
          throwsA(isA<PropertyTestFailure>()
              .having((e) => e.message, 'message', contains('iteration 1/1'))),
        );
      });
    });

    group('String Generator', () {
      testProperty('generates strings within length constraints', () {
        forAll(
          stringGenerator(minLength: 5, maxLength: 10),
          (String value) {
            expect(value.length, greaterThanOrEqualTo(5));
            expect(value.length, lessThanOrEqualTo(10));
          },
        );
      });

      testProperty('respects empty string constraints', () {
        forAll(
          stringGenerator(minLength: 0, maxLength: 0),
          (String value) {
            expect(value, equals(''));
          },
        );
      });

      testProperty('generates non-empty strings when specified', () {
        forAll(
          stringGenerator(minLength: 1, maxLength: 20, allowEmpty: false),
          (String value) {
            expect(value, isNotEmpty);
          },
        );
      });
    });

    group('DateTime Generator', () {
      testProperty('generates dates within specified range', () {
        final minDate = DateTime(2020, 1, 1);
        final maxDate = DateTime(2025, 12, 31);

        forAll(
          dateTimeGenerator(minDate: minDate, maxDate: maxDate),
          (DateTime value) {
            expect(value.isAfter(minDate) || value.isAtSameMomentAs(minDate),
                isTrue);
            expect(value.isBefore(maxDate) || value.isAtSameMomentAs(maxDate),
                isTrue);
          },
        );
      });
    });

    group('Note Generator', () {
      testProperty('generates valid Note objects', () {
        forAll(
          noteGenerator(),
          (Note note) {
            expect(note.id, isNotEmpty);
            expect(note.content.length, lessThanOrEqualTo(140));
            expect(
                note.updatedAt.isAfter(note.createdAt) ||
                    note.updatedAt.isAtSameMomentAs(note.createdAt),
                isTrue);
            expect(note, hasValidArchivePinState());
          },
        );
      });

      testProperty('can generate notes with long content when allowed', () {
        bool foundLongContent = false;

        forAll(
          noteGenerator(allowLongContent: true),
          (Note note) {
            expect(note, isA<Note>());
            if (note.content.length > 140) {
              foundLongContent = true;
            }
          },
        );

        // With 100 iterations and random content up to 200 chars,
        // we should find at least one note with content > 140 chars
        expect(foundLongContent, isTrue);
      });

      testProperty('respects archive-pin constraints by default', () {
        forAll(
          noteGenerator(),
          (Note note) {
            expect(note, hasValidArchivePinState());
          },
        );
      });

      testProperty('can generate invalid archive-pin combinations when allowed',
          () {
        bool foundInvalidState = false;

        forAll(
          noteGenerator(allowArchivedAndPinned: true),
          (Note note) {
            if (note.isArchived && note.isPinned) {
              foundInvalidState = true;
            }
          },
        );

        // Should eventually generate some invalid combinations
        expect(foundInvalidState, isTrue);
      });
    });

    group('Note List Generator', () {
      testProperty('generates lists within specified length range', () {
        forAll(
          noteListGenerator(minLength: 3, maxLength: 7),
          (List<Note> notes) {
            expect(notes.length, greaterThanOrEqualTo(3));
            expect(notes.length, lessThanOrEqualTo(7));
          },
        );
      });

      testProperty('all generated notes are valid', () {
        forAll(
          noteListGenerator(maxLength: 10),
          (List<Note> notes) {
            for (final note in notes) {
              expect(note, hasValidContentLength());
              expect(note, hasValidTimestamps());
              expect(note, hasValidArchivePinState());
            }
          },
        );
      });
    });

    group('Search Query Generator', () {
      testProperty('generates various types of search queries', () {
        final queryTypes = <String>{};

        forAll(
          searchQueryGenerator(),
          (String query) {
            expect(query, isA<String>());

            // Categorize query types for verification
            if (query.isEmpty) {
              queryTypes.add('empty');
            } else if (query.contains(' ')) {
              queryTypes.add('multi-word');
            } else if (query.length > 50) {
              queryTypes.add('long');
            } else if (RegExp(r'[!@#$%^&*()]').hasMatch(query)) {
              queryTypes.add('special-chars');
            } else {
              queryTypes.add('single-word');
            }
          },
        );

        // Should generate diverse query types
        expect(queryTypes.length, greaterThan(2));
      });
    });

    group('Mixed Note List Generator', () {
      testProperty('generates lists with specified archived ratio', () {
        forAll(
          mixedNoteListGenerator(
              minLength: 10, maxLength: 10, archivedRatio: 0.5),
          (List<Note> notes) {
            expect(notes.length, equals(10));

            final archivedCount = notes.where((n) => n.isArchived).length;
            final activeCount = notes.where((n) => !n.isArchived).length;

            // Should be roughly 50/50 split (allowing for rounding)
            expect(archivedCount, inInclusiveRange(4, 6));
            expect(activeCount, inInclusiveRange(4, 6));
            expect(archivedCount + activeCount, equals(10));
          },
        );
      });

      testProperty('archived notes are never pinned', () {
        forAll(
          mixedNoteListGenerator(),
          (List<Note> notes) {
            for (final note in notes) {
              if (note.isArchived) {
                expect(note.isPinned, isFalse);
              }
            }
          },
        );
      });
    });
  });

  group('Custom Matchers', () {
    test('hasValidContentLength matcher works correctly', () {
      final validNote = Note(
        id: 'test',
        content: 'Valid content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final invalidNote = Note(
        id: 'test',
        content: 'x' * 141, // Too long
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(validNote, hasValidContentLength());
      expect(invalidNote, isNot(hasValidContentLength()));
    });

    test('hasValidArchivePinState matcher works correctly', () {
      final validNote1 = Note(
        id: 'test',
        content: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isArchived: false,
        isPinned: true,
      );

      final validNote2 = Note(
        id: 'test',
        content: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isArchived: true,
        isPinned: false,
      );

      final invalidNote = Note(
        id: 'test',
        content: 'Test',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isArchived: true,
        isPinned: true,
      );

      expect(validNote1, hasValidArchivePinState());
      expect(validNote2, hasValidArchivePinState());
      expect(invalidNote, isNot(hasValidArchivePinState()));
    });

    test('hasValidTimestamps matcher works correctly', () {
      final now = DateTime.now();
      final earlier = now.subtract(Duration(hours: 1));

      final validNote = Note(
        id: 'test',
        content: 'Test',
        createdAt: earlier,
        updatedAt: now,
      );

      final invalidNote = Note(
        id: 'test',
        content: 'Test',
        createdAt: now,
        updatedAt: earlier,
      );

      expect(validNote, hasValidTimestamps());
      expect(invalidNote, isNot(hasValidTimestamps()));
    });

    test('containsOnlyActiveNotes matcher works correctly', () {
      final activeNotes = [
        Note(
            id: '1',
            content: 'Test 1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()),
        Note(
            id: '2',
            content: 'Test 2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()),
      ];

      final mixedNotes = [
        Note(
            id: '1',
            content: 'Test 1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now()),
        Note(
            id: '2',
            content: 'Test 2',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isArchived: true),
      ];

      expect(activeNotes, containsOnlyActiveNotes());
      expect(mixedNotes, isNot(containsOnlyActiveNotes()));
    });
  });
}
