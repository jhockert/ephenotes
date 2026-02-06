import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  group('NoteSorting', () {
    group('sortByPriority', () {
      test('sorts pinned notes before unpinned notes', () {
        final notes = [
          Note(
            id: '1',
            content: 'Unpinned note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: '2',
            content: 'Pinned note',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: NotePriority.normal,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        expect(sorted[0].isPinned, isTrue);
        expect(sorted[1].isPinned, isFalse);
      });

      test('sorts by priority within pinned notes (High → Normal → Low)', () {
        final notes = [
          Note(
            id: '1',
            content: 'Low priority pinned',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.low,
            isPinned: true,
          ),
          Note(
            id: '2',
            content: 'High priority pinned',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: NotePriority.high,
            isPinned: true,
          ),
          Note(
            id: '3',
            content: 'Medium priority pinned',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            priority: NotePriority.normal,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        expect(sorted[0].priority, NotePriority.high);
        expect(sorted[1].priority, NotePriority.normal);
        expect(sorted[2].priority, NotePriority.low);
      });

      test('sorts by priority within unpinned notes (High → Normal → Low)', () {
        final notes = [
          Note(
            id: '1',
            content: 'Low priority unpinned',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.low,
            isPinned: false,
          ),
          Note(
            id: '2',
            content: 'High priority unpinned',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: '3',
            content: 'Medium priority unpinned',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            priority: NotePriority.normal,
            isPinned: false,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        expect(sorted[0].priority, NotePriority.high);
        expect(sorted[1].priority, NotePriority.normal);
        expect(sorted[2].priority, NotePriority.low);
      });

      test('sorts by creation date within same priority (newer first)', () {
        final notes = [
          Note(
            id: '1',
            content: 'Older note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: '2',
            content: 'Newer note',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: NotePriority.normal,
            isPinned: false,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        expect(sorted[0].createdAt, DateTime(2026, 1, 2)); // Newer first
        expect(sorted[1].createdAt, DateTime(2026, 1, 1)); // Older second
      });

      test('sorts complex mix of pinned/unpinned with different priorities',
          () {
        final notes = [
          Note(
            id: '1',
            content: 'Unpinned Low',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.low,
            isPinned: false,
          ),
          Note(
            id: '2',
            content: 'Pinned Medium',
            createdAt: DateTime(2026, 1, 2),
            updatedAt: DateTime(2026, 1, 2),
            priority: NotePriority.normal,
            isPinned: true,
          ),
          Note(
            id: '3',
            content: 'Unpinned High',
            createdAt: DateTime(2026, 1, 3),
            updatedAt: DateTime(2026, 1, 3),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: '4',
            content: 'Pinned High',
            createdAt: DateTime(2026, 1, 4),
            updatedAt: DateTime(2026, 1, 4),
            priority: NotePriority.high,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Expected order:
        // 1. Pinned High (id: '4')
        // 2. Pinned Medium (id: '2')
        // 3. Unpinned High (id: '3')
        // 4. Unpinned Low (id: '1')

        expect(sorted[0].id, '4'); // Pinned High
        expect(sorted[1].id, '2'); // Pinned Medium
        expect(sorted[2].id, '3'); // Unpinned High
        expect(sorted[3].id, '1'); // Unpinned Low
      });

      test('handles empty list', () {
        final notes = <Note>[];
        final sorted = NoteSorting.sortByPriority(notes);
        expect(sorted, isEmpty);
      });

      test('handles single note', () {
        final notes = [
          Note(
            id: '1',
            content: 'Single note',
            createdAt: DateTime(2026, 1, 1),
            updatedAt: DateTime(2026, 1, 1),
            priority: NotePriority.normal,
            isPinned: false,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);
        expect(sorted.length, 1);
        expect(sorted[0].id, '1');
      });

      // Additional comprehensive tests for task 4.1.3
      test('sorts mixed priority levels with comprehensive scenarios', () {
        final notes = [
          // Multiple notes of each priority level, both pinned and unpinned
          Note(
            id: '1',
            content: 'Unpinned Low 1',
            createdAt: DateTime(2026, 1, 1, 10, 0),
            updatedAt: DateTime(2026, 1, 1, 10, 0),
            priority: NotePriority.low,
            isPinned: false,
          ),
          Note(
            id: '2',
            content: 'Unpinned Low 2',
            createdAt: DateTime(2026, 1, 1, 11, 0),
            updatedAt: DateTime(2026, 1, 1, 11, 0),
            priority: NotePriority.low,
            isPinned: false,
          ),
          Note(
            id: '3',
            content: 'Pinned Medium 1',
            createdAt: DateTime(2026, 1, 1, 12, 0),
            updatedAt: DateTime(2026, 1, 1, 12, 0),
            priority: NotePriority.normal,
            isPinned: true,
          ),
          Note(
            id: '4',
            content: 'Pinned Medium 2',
            createdAt: DateTime(2026, 1, 1, 13, 0),
            updatedAt: DateTime(2026, 1, 1, 13, 0),
            priority: NotePriority.normal,
            isPinned: true,
          ),
          Note(
            id: '5',
            content: 'Unpinned High 1',
            createdAt: DateTime(2026, 1, 1, 14, 0),
            updatedAt: DateTime(2026, 1, 1, 14, 0),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: '6',
            content: 'Unpinned High 2',
            createdAt: DateTime(2026, 1, 1, 15, 0),
            updatedAt: DateTime(2026, 1, 1, 15, 0),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: '7',
            content: 'Pinned High 1',
            createdAt: DateTime(2026, 1, 1, 16, 0),
            updatedAt: DateTime(2026, 1, 1, 16, 0),
            priority: NotePriority.high,
            isPinned: true,
          ),
          Note(
            id: '8',
            content: 'Pinned High 2',
            createdAt: DateTime(2026, 1, 1, 17, 0),
            updatedAt: DateTime(2026, 1, 1, 17, 0),
            priority: NotePriority.high,
            isPinned: true,
          ),
          Note(
            id: '9',
            content: 'Unpinned Medium 1',
            createdAt: DateTime(2026, 1, 1, 18, 0),
            updatedAt: DateTime(2026, 1, 1, 18, 0),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: '10',
            content: 'Pinned Low 1',
            createdAt: DateTime(2026, 1, 1, 19, 0),
            updatedAt: DateTime(2026, 1, 1, 19, 0),
            priority: NotePriority.low,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Expected order:
        // Pinned High (newest first): '8', '7'
        // Pinned Medium (newest first): '4', '3'
        // Pinned Low: '10'
        // Unpinned High (newest first): '6', '5'
        // Unpinned Medium: '9'
        // Unpinned Low (newest first): '2', '1'

        final expectedOrder = [
          '8',
          '7',
          '4',
          '3',
          '10',
          '6',
          '5',
          '9',
          '2',
          '1'
        ];

        expect(sorted.length, 10);
        for (int i = 0; i < sorted.length; i++) {
          expect(sorted[i].id, expectedOrder[i],
              reason:
                  'Note at position $i should be ${expectedOrder[i]} but was ${sorted[i].id}');
        }
      });

      test(
          'verifies pinned vs unpinned priority ordering with all combinations',
          () {
        final notes = [
          // Create one note for each combination of pin status and priority
          Note(
            id: 'unpinned_high',
            content: 'Unpinned High Priority',
            createdAt: DateTime(2026, 1, 1, 10, 0),
            updatedAt: DateTime(2026, 1, 1, 10, 0),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: 'unpinned_medium',
            content: 'Unpinned Medium Priority',
            createdAt: DateTime(2026, 1, 1, 11, 0),
            updatedAt: DateTime(2026, 1, 1, 11, 0),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'unpinned_low',
            content: 'Unpinned Low Priority',
            createdAt: DateTime(2026, 1, 1, 12, 0),
            updatedAt: DateTime(2026, 1, 1, 12, 0),
            priority: NotePriority.low,
            isPinned: false,
          ),
          Note(
            id: 'pinned_high',
            content: 'Pinned High Priority',
            createdAt: DateTime(2026, 1, 1, 13, 0),
            updatedAt: DateTime(2026, 1, 1, 13, 0),
            priority: NotePriority.high,
            isPinned: true,
          ),
          Note(
            id: 'pinned_medium',
            content: 'Pinned Medium Priority',
            createdAt: DateTime(2026, 1, 1, 14, 0),
            updatedAt: DateTime(2026, 1, 1, 14, 0),
            priority: NotePriority.normal,
            isPinned: true,
          ),
          Note(
            id: 'pinned_low',
            content: 'Pinned Low Priority',
            createdAt: DateTime(2026, 1, 1, 15, 0),
            updatedAt: DateTime(2026, 1, 1, 15, 0),
            priority: NotePriority.low,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Expected order: All pinned first (by priority), then all unpinned (by priority)
        final expectedOrder = [
          'pinned_high',
          'pinned_medium',
          'pinned_low',
          'unpinned_high',
          'unpinned_medium',
          'unpinned_low'
        ];

        expect(sorted.length, 6);
        for (int i = 0; i < sorted.length; i++) {
          expect(sorted[i].id, expectedOrder[i]);
        }

        // Verify pinned section comes first
        final pinnedSection = sorted.take(3).toList();
        final unpinnedSection = sorted.skip(3).toList();

        for (final note in pinnedSection) {
          expect(note.isPinned, isTrue,
              reason: 'First 3 notes should be pinned');
        }

        for (final note in unpinnedSection) {
          expect(note.isPinned, isFalse,
              reason: 'Last 3 notes should be unpinned');
        }
      });

      test('sorts same-priority notes by creation date with precise timing',
          () {
        final baseTime = DateTime(2026, 1, 1, 10, 0, 0);

        final notes = [
          Note(
            id: 'high_1',
            content: 'High Priority - Oldest',
            createdAt: baseTime,
            updatedAt: baseTime,
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: 'high_2',
            content: 'High Priority - Middle',
            createdAt: baseTime.add(const Duration(minutes: 30)),
            updatedAt: baseTime.add(const Duration(minutes: 30)),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: 'high_3',
            content: 'High Priority - Newest',
            createdAt: baseTime.add(const Duration(hours: 1)),
            updatedAt: baseTime.add(const Duration(hours: 1)),
            priority: NotePriority.high,
            isPinned: false,
          ),
          Note(
            id: 'medium_1',
            content: 'Medium Priority - Oldest',
            createdAt: baseTime.add(const Duration(hours: 2)),
            updatedAt: baseTime.add(const Duration(hours: 2)),
            priority: NotePriority.normal,
            isPinned: true,
          ),
          Note(
            id: 'medium_2',
            content: 'Medium Priority - Newest',
            createdAt: baseTime.add(const Duration(hours: 3)),
            updatedAt: baseTime.add(const Duration(hours: 3)),
            priority: NotePriority.normal,
            isPinned: true,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Expected order:
        // Pinned Medium (newest first): medium_2, medium_1
        // Unpinned High (newest first): high_3, high_2, high_1
        final expectedOrder = [
          'medium_2',
          'medium_1',
          'high_3',
          'high_2',
          'high_1'
        ];

        expect(sorted.length, 5);
        for (int i = 0; i < sorted.length; i++) {
          expect(sorted[i].id, expectedOrder[i]);
        }

        // Verify creation date ordering within same priority groups
        // Pinned medium notes should be newest first
        expect(sorted[0].createdAt.isAfter(sorted[1].createdAt), isTrue);

        // Unpinned high notes should be newest first
        expect(sorted[2].createdAt.isAfter(sorted[3].createdAt), isTrue);
        expect(sorted[3].createdAt.isAfter(sorted[4].createdAt), isTrue);
      });

      test('handles all same priority notes with different creation times', () {
        final baseTime = DateTime(2026, 1, 1, 10, 0, 0);

        final notes = [
          Note(
            id: 'note_1',
            content: 'Same Priority - Created at 10:00',
            createdAt: baseTime,
            updatedAt: baseTime,
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'note_2',
            content: 'Same Priority - Created at 10:15',
            createdAt: baseTime.add(const Duration(minutes: 15)),
            updatedAt: baseTime.add(const Duration(minutes: 15)),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'note_3',
            content: 'Same Priority - Created at 10:30',
            createdAt: baseTime.add(const Duration(minutes: 30)),
            updatedAt: baseTime.add(const Duration(minutes: 30)),
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'note_4',
            content: 'Same Priority - Created at 10:45',
            createdAt: baseTime.add(const Duration(minutes: 45)),
            updatedAt: baseTime.add(const Duration(minutes: 45)),
            priority: NotePriority.normal,
            isPinned: false,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Should be ordered newest first: note_4, note_3, note_2, note_1
        final expectedOrder = ['note_4', 'note_3', 'note_2', 'note_1'];

        expect(sorted.length, 4);
        for (int i = 0; i < sorted.length; i++) {
          expect(sorted[i].id, expectedOrder[i]);
        }

        // Verify each note is newer than the next
        for (int i = 0; i < sorted.length - 1; i++) {
          expect(sorted[i].createdAt.isAfter(sorted[i + 1].createdAt), isTrue,
              reason:
                  'Note at index $i should be newer than note at index ${i + 1}');
        }
      });

      test('edge case: all notes have same priority and creation time', () {
        final sameTime = DateTime(2026, 1, 1, 10, 0, 0);

        final notes = [
          Note(
            id: 'note_1',
            content: 'Same everything 1',
            createdAt: sameTime,
            updatedAt: sameTime,
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'note_2',
            content: 'Same everything 2',
            createdAt: sameTime,
            updatedAt: sameTime,
            priority: NotePriority.normal,
            isPinned: false,
          ),
          Note(
            id: 'note_3',
            content: 'Same everything 3',
            createdAt: sameTime,
            updatedAt: sameTime,
            priority: NotePriority.normal,
            isPinned: false,
          ),
        ];

        final sorted = NoteSorting.sortByPriority(notes);

        // Should maintain stable sort - original order preserved when all criteria are equal
        expect(sorted.length, 3);

        // All notes should have same priority and pin status
        for (final note in sorted) {
          expect(note.priority, NotePriority.normal);
          expect(note.isPinned, isFalse);
          expect(note.createdAt, sameTime);
        }
      });
    });
  });
}
