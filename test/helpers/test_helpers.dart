import 'dart:math';
import 'package:ephenotes/data/models/note.dart';
import 'package:uuid/uuid.dart';

/// Test helper utilities for generating test data and common test operations.
class TestHelpers {
  static const _uuid = Uuid();
  static final _random = Random();

  /// Generate a list of test notes with realistic data for performance testing.
  static List<Note> generateTestNotes(int count) {
    final notes = <Note>[];
    final now = DateTime.now();

    // Sample content variations for realistic testing
    final contentSamples = [
      'Meeting notes for project review',
      'Grocery list: milk, bread, eggs, cheese',
      'Remember to call dentist for appointment',
      'Ideas for weekend trip to the mountains',
      'Book recommendation: The Art of Clean Code',
      'Fix the leaky faucet in the kitchen',
      'Birthday party planning checklist',
      'Workout routine: 30 min cardio, weights',
      'Recipe: homemade pizza dough ingredients',
      'Travel itinerary for business trip',
      'Gift ideas for anniversary celebration',
      'Home improvement: paint living room',
      'Study notes for certification exam',
      'Budget planning for next quarter',
      'Car maintenance: oil change due',
      'Garden tasks: plant tomatoes, water herbs',
      'Movie night suggestions with friends',
      'Important documents to organize',
      'Health goals: drink more water daily',
      'Creative writing prompt ideas',
    ];

    for (int i = 0; i < count; i++) {
      // Create realistic timestamps with some variation
      final createdAt = now.subtract(Duration(
        days: _random.nextInt(365),
        hours: _random.nextInt(24),
        minutes: _random.nextInt(60),
      ));

      final updatedAt = createdAt.add(Duration(
        hours: _random.nextInt(48),
        minutes: _random.nextInt(60),
      ));

      // Select random content with some variation
      var content = contentSamples[_random.nextInt(contentSamples.length)];

      // Add some variation to content
      if (_random.nextBool()) {
        content = '$content - ${_random.nextInt(1000)}';
      }

      // Ensure content doesn't exceed 140 characters
      if (content.length > 140) {
        content = content.substring(0, 140);
      }

      // Create realistic distribution of priorities
      NotePriority priority;
      final priorityRand = _random.nextInt(100);
      if (priorityRand < 20) {
        priority = NotePriority.high;
      } else if (priorityRand < 50) {
        priority = NotePriority.normal;
      } else {
        priority = NotePriority.low;
      }

      // Create realistic distribution of colors
      final colors = NoteColor.values;
      final color = colors[_random.nextInt(colors.length)];

      // Some notes have icons
      IconCategory? iconCategory;
      if (_random.nextInt(100) < 60) {
        // 60% chance of having an icon
        final icons = IconCategory.values;
        iconCategory = icons[_random.nextInt(icons.length)];
      }

      // Realistic pin distribution (about 10% pinned)
      final isPinned = _random.nextInt(100) < 10;

      // Realistic archive distribution (about 20% archived)
      final isArchived = _random.nextInt(100) < 20;

      // Archived notes can't be pinned
      final actualIsPinned = isArchived ? false : isPinned;

      // Random formatting
      final isBold = _random.nextInt(100) < 15;
      final isItalic = _random.nextInt(100) < 10;
      final isUnderlined = _random.nextInt(100) < 5;

      // Random font size
      final fontSizes = FontSize.values;
      final fontSize = fontSizes[_random.nextInt(fontSizes.length)];

      // Random list type
      final listTypes = ListType.values;
      final listType = listTypes[_random.nextInt(listTypes.length)];

      final note = Note(
        id: _uuid.v4(),
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
        color: color,
        priority: priority,
        iconCategory: iconCategory,
        isPinned: actualIsPinned,
        isArchived: isArchived,
        isBold: isBold,
        isItalic: isItalic,
        isUnderlined: isUnderlined,
        fontSize: fontSize,
        listType: listType,
      );

      notes.add(note);
    }

    return notes;
  }

  /// Generate test notes with specific characteristics for targeted testing.
  static List<Note> generateTestNotesWithCharacteristics({
    required int count,
    bool allPinned = false,
    bool allArchived = false,
    NotePriority? forcePriority,
    NoteColor? forceColor,
  }) {
    final notes = generateTestNotes(count);

    return notes.map((note) {
      return note.copyWith(
        isPinned: allArchived ? false : (allPinned ? true : note.isPinned),
        isArchived: allArchived,
        priority: forcePriority ?? note.priority,
        color: forceColor ?? note.color,
      );
    }).toList();
  }

  /// Generate a large dataset for stress testing.
  static List<Note> generateLargeTestDataset({int size = 1000}) {
    return generateTestNotes(size);
  }

  /// Generate notes with varying content lengths for testing content handling.
  static List<Note> generateNotesWithVaryingContentLengths(int count) {
    final notes = <Note>[];
    final baseNotes = generateTestNotes(count);

    for (int i = 0; i < count; i++) {
      final baseNote = baseNotes[i];

      // Create content of varying lengths
      String content;
      final lengthCategory = i % 4;

      switch (lengthCategory) {
        case 0: // Very short
          content = 'Short';
          break;
        case 1: // Medium
          content = 'This is a medium length note with some details';
          break;
        case 2: // Long
          content =
              'This is a much longer note that contains quite a bit more information and details about various topics';
          break;
        case 3: // Maximum length
          content = 'A' * 140; // Exactly 140 characters
          break;
        default:
          content = baseNote.content;
      }

      notes.add(baseNote.copyWith(content: content));
    }

    return notes;
  }

  /// Create a note with specific properties for testing.
  static Note createTestNote({
    String? id,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteColor? color,
    NotePriority? priority,
    IconCategory? iconCategory,
    bool? isPinned,
    bool? isArchived,
    bool? isBold,
    bool? isItalic,
    bool? isUnderlined,
    FontSize? fontSize,
    ListType? listType,
  }) {
    final now = DateTime.now();

    return Note(
      id: id ?? _uuid.v4(),
      content: content ?? 'Test note content',
      createdAt: createdAt ?? now.subtract(const Duration(hours: 1)),
      updatedAt: updatedAt ?? now,
      color: color ?? NoteColor.classicYellow,
      priority: priority ?? NotePriority.normal,
      iconCategory: iconCategory,
      isPinned: isPinned ?? false,
      isArchived: isArchived ?? false,
      isBold: isBold ?? false,
      isItalic: isItalic ?? false,
      isUnderlined: isUnderlined ?? false,
      fontSize: fontSize ?? FontSize.medium,
      listType: listType ?? ListType.none,
    );
  }

  /// Generate notes for testing priority-based sorting.
  static List<Note> generateNotesForSortingTest() {
    final notes = <Note>[];
    final now = DateTime.now();

    // Create notes with different priorities and pin states
    // High priority, pinned
    notes.add(createTestNote(
      content: 'High priority pinned note',
      priority: NotePriority.high,
      isPinned: true,
      createdAt: now.subtract(const Duration(hours: 1)),
    ));

    // High priority, not pinned
    notes.add(createTestNote(
      content: 'High priority unpinned note',
      priority: NotePriority.high,
      isPinned: false,
      createdAt: now.subtract(const Duration(hours: 2)),
    ));

    // Normal priority, pinned
    notes.add(createTestNote(
      content: 'Normal priority pinned note',
      priority: NotePriority.normal,
      isPinned: true,
      createdAt: now.subtract(const Duration(hours: 3)),
    ));

    // Normal priority, not pinned
    notes.add(createTestNote(
      content: 'Normal priority unpinned note',
      priority: NotePriority.normal,
      isPinned: false,
      createdAt: now.subtract(const Duration(hours: 4)),
    ));

    // Low priority, pinned
    notes.add(createTestNote(
      content: 'Low priority pinned note',
      priority: NotePriority.low,
      isPinned: true,
      createdAt: now.subtract(const Duration(hours: 5)),
    ));

    // Low priority, not pinned
    notes.add(createTestNote(
      content: 'Low priority unpinned note',
      priority: NotePriority.low,
      isPinned: false,
      createdAt: now.subtract(const Duration(hours: 6)),
    ));

    return notes;
  }
}
