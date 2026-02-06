# Property-Based Testing Framework

This directory contains the property-based testing (PBT) framework for ephenotes, including generators, matchers, and example tests.

## Overview

Property-based testing is a testing methodology where you define properties (invariants) that should hold for all valid inputs, and the framework generates many random test cases to verify these properties.

## Framework Components

### 1. Core Framework (`test/helpers/property_based_testing.dart`)

The main PBT framework providing:
- `Generator<T>` - Base class for creating random test data
- `forAll()` - Execute property tests with single generator
- `forAll2()`, `forAll3()` - Execute property tests with multiple generators
- `testProperty()` - Integration with flutter_test framework
- `PropertyTestConfig` - Configuration for test execution

**Example Usage:**
```dart
testProperty('strings have valid length', () {
  forAll(
    stringGenerator(maxLength: 10),
    (String value) {
      expect(value.length, lessThanOrEqualTo(10));
    },
  );
});
```

### 2. Note Generators (`test/helpers/note_generators.dart`)

Generators for creating random Note objects and related data:

- `stringGenerator()` - Random strings with length constraints
- `dateTimeGenerator()` - Random dates within ranges
- `noteGenerator()` - Valid Note objects with configurable constraints
- `noteListGenerator()` - Lists of Note objects
- `searchQueryGenerator()` - Various search query patterns
- `mixedNoteListGenerator()` - Lists with active/archived notes
- Specialized generators for testing edge cases

**Example Usage:**
```dart
forAll(
  noteGenerator(allowLongContent: true),
  (Note note) {
    // Test note properties
    expect(note.id, isNotEmpty);
  },
);
```

### 3. Custom Matchers (`test/helpers/note_matchers.dart`)

Semantic matchers for Note-specific assertions:

- `hasValidContentLength()` - Content ≤ 140 characters
- `hasValidArchivePinState()` - Not both archived and pinned
- `hasValidTimestamps()` - updatedAt ≥ createdAt
- `hasValidPriorityOrdering()` - Correct priority-based sorting
- `containsOnlyActiveNotes()` - No archived notes in list
- `isSubsetOf()` - List is subset of another list

**Example Usage:**
```dart
expect(note, hasValidContentLength());
expect(notes, hasValidPriorityOrdering());
```

## Configuration

### Test Iterations
By default, each property runs 100 random test cases. Configure with:

```dart
// Global configuration
PropertyTestConfig.defaultIterations = 200;

// Per-test configuration
testProperty('my property', () {
  forAll(generator, property, iterations: 50);
});
```

### Random Seed
For reproducible test runs:

```dart
PropertyTestConfig.seed = 12345;
```

## Core Properties Tested

### Property 1: Note Content Integrity
- **Validates**: Requirements 1.1, 1.2
- **Rule**: Note content never exceeds 140 characters
- **Generator**: `stringGenerator(maxLength: 200)`

### Property 2: Archive-Pin Relationship Invariant
- **Validates**: Requirements 1.4, 5.1
- **Rule**: Notes cannot be both archived and pinned
- **Generator**: `noteWithArchivePinStateGenerator()`

### Property 3: Search Result Consistency
- **Validates**: Requirements 4.1, 4.2
- **Rule**: Search results are subset of active notes
- **Generator**: `mixedNoteListGenerator()` + `searchQueryGenerator()`

### Property 4: Timestamp Monotonicity
- **Validates**: Requirements 1.1, 1.2
- **Rule**: updatedAt ≥ createdAt always
- **Generator**: `noteWithTimestampVariationsGenerator()`

### Property 5: Priority-Based Ordering
- **Validates**: Requirements 3.1, 3.2
- **Rule**: Pinned notes first, then by priority High→Medium→Low
- **Generator**: `noteListGenerator()`

### Property 6: Data Persistence Integrity
- **Validates**: Requirements NFR-4.1, NFR-4.2
- **Rule**: Save/load cycles preserve data exactly
- **Generator**: `noteListGenerator()`

## Running Property-Based Tests

### Run All Property Tests
```bash
flutter test test/property/
```

### Run Specific Property Test
```bash
flutter test test/property/note_properties_example_test.dart
```

### Run Framework Tests
```bash
flutter test test/property/property_test_framework_test.dart
```

## Writing New Property Tests

### 1. Define the Property
Identify an invariant that should always hold:
```dart
// Property: All notes in search results contain the query text
```

### 2. Create or Use Generators
```dart
final noteGenerator = noteListGenerator();
final queryGenerator = searchQueryGenerator();
```

### 3. Write the Test
```dart
testProperty('search results contain query text', () {
  forAll2(
    noteGenerator,
    queryGenerator,
    (List<Note> notes, String query) {
      final results = searchNotes(notes, query);
      for (final note in results) {
        expect(note, containsText(query));
      }
    },
  );
});
```

### 4. Add Custom Matchers (if needed)
```dart
Matcher containsText(String text) {
  return _ContainsText(text);
}
```

## Best Practices

### Generator Design
- **Constrain inputs intelligently** - Don't just generate random data
- **Include edge cases** - Empty strings, boundary values, null values
- **Test invalid inputs** - When appropriate for error handling

### Property Selection
- **Focus on invariants** - Rules that should never be violated
- **Test business logic** - Core domain rules and constraints
- **Avoid implementation details** - Test behavior, not implementation

### Failure Analysis
When a property test fails:
1. **Examine the failing input** - What made this case special?
2. **Check if it's a real bug** - Or if the property needs refinement
3. **Add as unit test** - Convert interesting cases to regression tests

### Performance Considerations
- **Limit iterations for slow tests** - Use fewer iterations for expensive operations
- **Use smaller generators** - Don't generate huge lists unless necessary
- **Profile test execution** - Identify bottlenecks in generators

## Integration with Existing Tests

Property-based tests complement existing unit and widget tests:

- **Unit tests** - Test specific examples and edge cases
- **Property tests** - Test universal rules across many inputs
- **Widget tests** - Test UI behavior with property-generated data
- **Integration tests** - Test end-to-end workflows with random data

## Troubleshooting

### Common Issues

**Property fails intermittently:**
- Set a fixed seed for reproducible runs
- Check if the property is too strict
- Verify generator constraints

**Tests are too slow:**
- Reduce iteration count
- Optimize generators
- Use smaller data sets

**Generator produces invalid data:**
- Add constraints to generators
- Validate generator output
- Use specialized generators for edge cases

### Debugging Tips

```dart
// Add logging to see generated values
forAll(generator, (value) {
  print('Testing with: $value');
  // ... test logic
});

// Use smaller iteration counts during development
testProperty('my property', () {
  forAll(generator, property, iterations: 10);
});
```

## References

- [Property-Based Testing Concepts](https://hypothesis.works/articles/what-is-property-based-testing/)
- [QuickCheck Paper](https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/quick.pdf)
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)