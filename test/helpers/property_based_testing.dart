import 'dart:math';
import 'package:flutter_test/flutter_test.dart';

/// Property-based testing framework for ephenotes.
///
/// This framework provides generators for creating random test data and
/// utilities for running property-based tests with configurable iterations.
///
/// Example usage:
/// ```dart
/// testProperty('note content never exceeds 140 characters', () {
///   forAll(
///     stringGenerator(maxLength: 200),
///     (String content) {
///       final note = Note.create(content: content);
///       expect(note.content.length, lessThanOrEqualTo(140));
///     },
///   );
/// });
/// ```

/// Configuration for property-based test execution
class PropertyTestConfig {
  /// Number of random test cases to generate per property
  static const int defaultIterations = 100;

  /// Random seed for reproducible test runs
  static int? seed;

  /// Get or create random instance
  static Random get random => _random ??= Random(seed);
  static Random? _random;

  /// Reset random instance (useful for testing)
  static void reset() {
    _random = null;
  }
}

/// Base class for all generators
abstract class Generator<T> {
  /// Generate a random value of type T
  T generate(Random random);

  /// Create a generator from a function
  static Generator<T> fromFunction<T>(T Function(Random) generator) {
    return _FunctionGenerator(generator);
  }

  /// Create a generator that always returns the same value
  static Generator<T> constant<T>(T value) {
    return Generator.fromFunction((_) => value);
  }

  /// Create a generator that picks from a list of values
  static Generator<T> oneOf<T>(List<T> values) {
    if (values.isEmpty) throw ArgumentError('Cannot pick from empty list');
    return Generator.fromFunction(
        (random) => values[random.nextInt(values.length)]);
  }

  /// Create a list generator
  static Generator<List<T>> list<T>(
    Generator<T> elementGenerator, {
    int minLength = 0,
    int maxLength = 10,
  }) {
    return Generator.fromFunction((random) {
      final length = minLength + random.nextInt(maxLength - minLength + 1);
      return List.generate(length, (_) => elementGenerator.generate(random));
    });
  }
}

/// Internal implementation of function-based generator
class _FunctionGenerator<T> extends Generator<T> {
  final T Function(Random) _generator;

  _FunctionGenerator(this._generator);

  @override
  T generate(Random random) => _generator(random);
}

/// Run a property-based test with the specified generator and property function
void forAll<T>(
  Generator<T> generator,
  void Function(T) property, {
  int iterations = PropertyTestConfig.defaultIterations,
}) {
  final random = PropertyTestConfig.random;

  for (int i = 0; i < iterations; i++) {
    try {
      final value = generator.generate(random);
      property(value);
    } catch (e, stackTrace) {
      // Re-throw with additional context about which iteration failed
      throw PropertyTestFailure(
        'Property failed on iteration ${i + 1}/$iterations',
        originalException: e,
        originalStackTrace: stackTrace,
      );
    }
  }
}

/// Run a property-based test with two generators
void forAll2<T1, T2>(
  Generator<T1> gen1,
  Generator<T2> gen2,
  void Function(T1, T2) property, {
  int iterations = PropertyTestConfig.defaultIterations,
}) {
  final random = PropertyTestConfig.random;

  for (int i = 0; i < iterations; i++) {
    try {
      final value1 = gen1.generate(random);
      final value2 = gen2.generate(random);
      property(value1, value2);
    } catch (e, stackTrace) {
      throw PropertyTestFailure(
        'Property failed on iteration ${i + 1}/$iterations',
        originalException: e,
        originalStackTrace: stackTrace,
      );
    }
  }
}

/// Run a property-based test with three generators
void forAll3<T1, T2, T3>(
  Generator<T1> gen1,
  Generator<T2> gen2,
  Generator<T3> gen3,
  void Function(T1, T2, T3) property, {
  int iterations = PropertyTestConfig.defaultIterations,
}) {
  final random = PropertyTestConfig.random;

  for (int i = 0; i < iterations; i++) {
    try {
      final value1 = gen1.generate(random);
      final value2 = gen2.generate(random);
      final value3 = gen3.generate(random);
      property(value1, value2, value3);
    } catch (e, stackTrace) {
      throw PropertyTestFailure(
        'Property failed on iteration ${i + 1}/$iterations',
        originalException: e,
        originalStackTrace: stackTrace,
      );
    }
  }
}

/// Exception thrown when a property-based test fails
class PropertyTestFailure implements Exception {
  final String message;
  final dynamic originalException;
  final StackTrace? originalStackTrace;

  PropertyTestFailure(
    this.message, {
    this.originalException,
    this.originalStackTrace,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PropertyTestFailure: $message');
    if (originalException != null) {
      buffer.write('\nOriginal exception: $originalException');
    }
    return buffer.toString();
  }
}

/// Wrapper for property-based tests that integrates with flutter_test
void testProperty(
  String description,
  void Function() body, {
  int iterations = PropertyTestConfig.defaultIterations,
}) {
  test(description, () {
    // Reset random state for each test
    PropertyTestConfig.reset();
    body();
  });
}
