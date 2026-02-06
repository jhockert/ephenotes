import 'package:ephenotes/data/models/note.dart';
import 'package:uuid/uuid.dart';
import 'property_based_testing.dart';

/// Generators for creating random Note objects and related data for property-based testing.
///
/// These generators create valid and invalid test data to thoroughly test
/// note-related functionality across a wide range of inputs.

const _uuid = Uuid();

/// Generate random strings with configurable length constraints
Generator<String> stringGenerator({
  int minLength = 0,
  int maxLength = 100,
  bool allowEmpty = true,
  bool allowUnicode = true,
}) {
  return Generator.fromFunction((random) {
    if (!allowEmpty && minLength == 0) {
      minLength = 1;
    }

    final length = minLength + random.nextInt(maxLength - minLength + 1);
    if (length == 0) return '';

    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      if (allowUnicode && random.nextInt(10) < 2) {
        // 20% chance for Unicode
        // Include some Unicode characters for testing
        final unicodeRanges = [
          [0x0020, 0x007E], // Basic Latin
          [0x00A0, 0x00FF], // Latin-1 Supplement
          [0x1F600, 0x1F64F], // Emoticons
        ];
        final range = unicodeRanges[random.nextInt(unicodeRanges.length)];
        final codePoint = range[0] + random.nextInt(range[1] - range[0] + 1);

        // Check if adding this character would exceed the length
        final char = String.fromCharCode(codePoint);
        if (buffer.length + char.length <= length) {
          buffer.write(char);
        } else {
          // Fall back to ASCII if Unicode would exceed length
          final asciiChar = 32 + random.nextInt(95);
          buffer.writeCharCode(asciiChar);
        }
      } else {
        // ASCII printable characters
        final char = 32 + random.nextInt(95); // Space to ~
        buffer.writeCharCode(char);
      }
    }

    // Ensure we don't exceed the requested length due to Unicode
    final result = buffer.toString();
    return result.length > length ? result.substring(0, length) : result;
  });
}

/// Generate random DateTime objects within a reasonable range
Generator<DateTime> dateTimeGenerator({
  DateTime? minDate,
  DateTime? maxDate,
}) {
  return Generator.fromFunction((random) {
    final min = minDate ?? DateTime(2020, 1, 1);
    final max = maxDate ?? DateTime(2030, 12, 31);

    // Ensure max is after min
    final actualMin = min.isBefore(max) ? min : max;
    final actualMax = min.isBefore(max) ? max : min;

    final range =
        actualMax.millisecondsSinceEpoch - actualMin.millisecondsSinceEpoch;

    // Handle edge case where dates are the same
    if (range <= 0) {
      return actualMin;
    }

    // Ensure range is within valid int range
    final safeRange = range > 0x7FFFFFFF ? 0x7FFFFFFF : range;
    final randomMillis =
        actualMin.millisecondsSinceEpoch + random.nextInt(safeRange);

    return DateTime.fromMillisecondsSinceEpoch(randomMillis);
  });
}

/// Generate random UUIDs
Generator<String> uuidGenerator() {
  return Generator.fromFunction((_) => _uuid.v4());
}

/// Generate random NoteColor values
Generator<NoteColor> noteColorGenerator() {
  return Generator.oneOf(NoteColor.values);
}

/// Generate random NotePriority values
Generator<NotePriority> notePriorityGenerator() {
  return Generator.oneOf(NotePriority.values);
}

/// Generate random IconCategory values (including null)
Generator<IconCategory?> iconCategoryGenerator({bool allowNull = true}) {
  final values = <IconCategory?>[...IconCategory.values];
  if (allowNull) values.add(null);
  return Generator.oneOf(values);
}

/// Generate random FontSize values
Generator<FontSize> fontSizeGenerator() {
  return Generator.oneOf(FontSize.values);
}

/// Generate random ListType values
Generator<ListType> listTypeGenerator() {
  return Generator.oneOf(ListType.values);
}

/// Generate random boolean values
Generator<bool> boolGenerator() {
  return Generator.fromFunction((random) => random.nextBool());
}

/// Generate random integers within a range
Generator<int> intGenerator({int min = 0, int max = 1000}) {
  return Generator.fromFunction(
      (random) => min + random.nextInt(max - min + 1));
}

/// Generate valid Note objects with random but valid data
Generator<Note> noteGenerator({
  bool allowLongContent = false,
  bool allowArchivedAndPinned = false,
  bool ensureValidTimestamps = true,
}) {
  return Generator.fromFunction((random) {
    final createdAt = dateTimeGenerator().generate(random);
    final updatedAt = ensureValidTimestamps
        ? dateTimeGenerator(minDate: createdAt).generate(random)
        : dateTimeGenerator().generate(random);

    final isArchived = boolGenerator().generate(random);
    final isPinned = allowArchivedAndPinned
        ? boolGenerator().generate(random)
        : isArchived
            ? false
            : boolGenerator().generate(random);

    final maxContentLength = allowLongContent ? 200 : 140;

    // Generate content and ensure it doesn't exceed the limit
    // Also ensure content is not empty (at least 1 character)
    var content = stringGenerator(
      minLength: 1, // Ensure at least 1 character
      maxLength: maxContentLength,
      allowEmpty: false, // Don't allow empty strings
    ).generate(random);

    // Truncate if necessary (this handles Unicode characters properly)
    if (content.length > maxContentLength) {
      content = content.substring(0, maxContentLength);
    }

    // Ensure content is not just whitespace
    if (content.trim().isEmpty) {
      content = 'Test note ${random.nextInt(1000)}';
    }

    return Note(
      id: uuidGenerator().generate(random),
      content: content,
      createdAt: createdAt,
      updatedAt: updatedAt,
      color: noteColorGenerator().generate(random),
      priority: notePriorityGenerator().generate(random),
      iconCategory: iconCategoryGenerator().generate(random),
      isPinned: isPinned,
      isArchived: isArchived,
      isBold: boolGenerator().generate(random),
      isItalic: boolGenerator().generate(random),
      isUnderlined: boolGenerator().generate(random),
      fontSize: fontSizeGenerator().generate(random),
      listType: listTypeGenerator().generate(random),
    );
  });
}

/// Generate lists of Note objects
Generator<List<Note>> noteListGenerator({
  int minLength = 0,
  int maxLength = 20,
  bool allowLongContent = false,
  bool allowArchivedAndPinned = false,
  bool ensureValidTimestamps = true,
}) {
  return Generator.list(
    noteGenerator(
      allowLongContent: allowLongContent,
      allowArchivedAndPinned: allowArchivedAndPinned,
      ensureValidTimestamps: ensureValidTimestamps,
    ),
    minLength: minLength,
    maxLength: maxLength,
  );
}

/// Generate search query strings (including edge cases)
Generator<String> searchQueryGenerator() {
  return Generator.fromFunction((random) {
    final queryTypes = [
      // Empty query
      () => '',
      // Single word
      () => stringGenerator(minLength: 1, maxLength: 20).generate(random),
      // Multiple words
      () => List.generate(
              1 + random.nextInt(4),
              (_) =>
                  stringGenerator(minLength: 1, maxLength: 10).generate(random))
          .join(' '),
      // Special characters
      () => '!@#\$%^&*()',
      // Unicode characters
      () => '🎉📝✨',
      // Very long query
      () => stringGenerator(minLength: 100, maxLength: 200).generate(random),
      // Whitespace variations
      () =>
          '  ${stringGenerator(minLength: 1, maxLength: 10).generate(random)}  ',
    ];

    final generator = queryTypes[random.nextInt(queryTypes.length)];
    return generator();
  });
}

/// Generate Note objects specifically for testing content length constraints
Generator<Note> noteWithContentLengthGenerator({
  required int minContentLength,
  required int maxContentLength,
}) {
  return Generator.fromFunction((random) {
    final baseNote = noteGenerator().generate(random);
    final content = stringGenerator(
      minLength: minContentLength,
      maxLength: maxContentLength,
    ).generate(random);

    return baseNote.copyWith(content: content);
  });
}

/// Generate Note objects with specific archive/pin combinations for testing invariants
Generator<Note> noteWithArchivePinStateGenerator() {
  return Generator.fromFunction((random) {
    final baseNote =
        noteGenerator(allowArchivedAndPinned: true).generate(random);

    // Generate all possible combinations of archive/pin states
    final states = [
      (isArchived: false, isPinned: false),
      (isArchived: false, isPinned: true),
      (isArchived: true, isPinned: false),
      (isArchived: true, isPinned: true), // Invalid state for testing
    ];

    final state = states[random.nextInt(states.length)];
    return baseNote.copyWith(
      isArchived: state.isArchived,
      isPinned: state.isPinned,
    );
  });
}

/// Generate Note objects with specific timestamp relationships for testing
Generator<Note> noteWithTimestampVariationsGenerator() {
  return Generator.fromFunction((random) {
    final baseNote =
        noteGenerator(ensureValidTimestamps: false, allowLongContent: false)
            .generate(random);

    // Generate various timestamp relationships
    final now = DateTime.now();
    final variations = [
      // Valid: updatedAt >= createdAt
      () {
        final created = dateTimeGenerator(maxDate: now).generate(random);
        final updated = dateTimeGenerator(
                minDate: created, maxDate: now.add(Duration(days: 1)))
            .generate(random);
        return baseNote.copyWith(createdAt: created, updatedAt: updated);
      },
      // Invalid: updatedAt < createdAt
      () {
        final updated = dateTimeGenerator(maxDate: now).generate(random);
        final created = dateTimeGenerator(
                minDate: updated.add(Duration(minutes: 1)),
                maxDate: now.add(Duration(days: 1)))
            .generate(random);
        return baseNote.copyWith(createdAt: created, updatedAt: updated);
      },
      // Edge case: same timestamp
      () {
        final timestamp = dateTimeGenerator().generate(random);
        return baseNote.copyWith(createdAt: timestamp, updatedAt: timestamp);
      },
    ];

    final variation = variations[random.nextInt(variations.length)];
    return variation();
  });
}

/// Generate mixed lists of active and archived notes for search testing
Generator<List<Note>> mixedNoteListGenerator({
  int minLength = 5,
  int maxLength = 20,
  double archivedRatio = 0.3,
}) {
  return Generator.fromFunction((random) {
    final length = minLength + random.nextInt(maxLength - minLength + 1);
    final archivedCount = (length * archivedRatio).round();

    final notes = <Note>[];

    // Generate archived notes
    for (int i = 0; i < archivedCount; i++) {
      final note = noteGenerator().generate(random);
      notes.add(note.copyWith(isArchived: true, isPinned: false));
    }

    // Generate active notes (mix of pinned and unpinned)
    for (int i = archivedCount; i < length; i++) {
      final note = noteGenerator().generate(random);
      notes.add(note.copyWith(isArchived: false));
    }

    // Shuffle the list
    notes.shuffle(random);
    return notes;
  });
}
