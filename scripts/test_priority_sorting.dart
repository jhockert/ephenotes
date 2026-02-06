// Simple verification script for priority-based sorting
// This is a standalone script to verify the sorting logic works correctly

// ignore_for_file: avoid_print

import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';

void main() {
  print('Testing priority-based note sorting...\n');

  // Create test notes with different priorities and pin status
  final notes = [
    Note(
      id: '1',
      content: 'Unpinned Low Priority',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
      priority: NotePriority.low,
      isPinned: false,
    ),
    Note(
      id: '2',
      content: 'Pinned Normal Priority',
      createdAt: DateTime(2026, 1, 2),
      updatedAt: DateTime(2026, 1, 2),
      priority: NotePriority.normal,
      isPinned: true,
    ),
    Note(
      id: '3',
      content: 'Unpinned High Priority',
      createdAt: DateTime(2026, 1, 3),
      updatedAt: DateTime(2026, 1, 3),
      priority: NotePriority.high,
      isPinned: false,
    ),
    Note(
      id: '4',
      content: 'Pinned High Priority',
      createdAt: DateTime(2026, 1, 4),
      updatedAt: DateTime(2026, 1, 4),
      priority: NotePriority.high,
      isPinned: true,
    ),
    Note(
      id: '5',
      content: 'Pinned Low Priority',
      createdAt: DateTime(2026, 1, 5),
      updatedAt: DateTime(2026, 1, 5),
      priority: NotePriority.low,
      isPinned: true,
    ),
  ];

  print('Original notes:');
  for (int i = 0; i < notes.length; i++) {
    final note = notes[i];
    print(
        '${i + 1}. ${note.content} (${note.isPinned ? 'Pinned' : 'Unpinned'}, ${note.priority.name})');
  }

  // Sort using the new priority-based sorting
  final sorted = NoteSorting.sortByPriority(notes);

  print('\nSorted notes (expected order):');
  print('1. Pinned High Priority (Pinned, high)');
  print('2. Pinned Normal Priority (Pinned, medium)');
  print('3. Pinned Low Priority (Pinned, low)');
  print('4. Unpinned High Priority (Unpinned, high)');
  print('5. Unpinned Low Priority (Unpinned, low)');

  print('\nActual sorted notes:');
  for (int i = 0; i < sorted.length; i++) {
    final note = sorted[i];
    print(
        '${i + 1}. ${note.content} (${note.isPinned ? 'Pinned' : 'Unpinned'}, ${note.priority.name})');
  }

  // Verify the sorting is correct
  final expectedOrder = ['4', '2', '5', '3', '1']; // IDs in expected order
  bool isCorrect = true;

  for (int i = 0; i < sorted.length; i++) {
    if (sorted[i].id != expectedOrder[i]) {
      isCorrect = false;
      break;
    }
  }

  print('\nSorting verification: ${isCorrect ? 'PASSED ✓' : 'FAILED ✗'}');

  if (isCorrect) {
    print('Priority-based sorting is working correctly!');
  } else {
    print('Priority-based sorting has issues.');
  }
}
