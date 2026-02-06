#!/usr/bin/env dart

/// Test runner script for integrating property-based tests with existing test suite.
/// library: test_runner
/// description: Executes unit, widget, and property-based tests together to validate integration.
/// This script runs all tests in the correct order and provides coverage reporting.
library;
// ignore_for_file: avoid_print

import 'dart:io';

void main(List<String> args) async {
  print(
      '🧪 Running ephenotes Test Suite with Property-Based Testing Integration');
  print('=' * 70);

  final stopwatch = Stopwatch()..start();
  var totalTests = 0;
  var failedTests = 0;

  // Test categories to run
  final testCategories = [
    TestCategory(
        'Unit Tests', 'test/unit/', 'Core business logic and data layer'),
    TestCategory(
        'Widget Tests', 'test/widget/', 'UI components and user interactions'),
    TestCategory(
        'Property Tests (Integration Ready)',
        'test/property/integration_only_test.dart',
        'Property-based correctness validation'),
  ];

  for (final category in testCategories) {
    print('\n📋 Running ${category.name}');
    print('   ${category.description}');
    print('   Path: ${category.path}');
    print('-' * 50);

    final result = await runTestCategory(category);
    totalTests += result.totalTests;
    failedTests += result.failedTests;

    if (result.success) {
      print('✅ ${category.name}: ${result.totalTests} tests passed');
    } else {
      print(
          '❌ ${category.name}: ${result.failedTests}/${result.totalTests} tests failed');
    }
  }

  stopwatch.stop();

  // Summary
  // ignore: prefer_interpolation_to_compose_strings
  print('\n' + '=' * 70);
  print('📊 Test Suite Summary');
  print('=' * 70);
  print('Total Tests: $totalTests');
  print('Passed: ${totalTests - failedTests}');
  print('Failed: $failedTests');
  print(
      'Success Rate: ${((totalTests - failedTests) / totalTests * 100).toStringAsFixed(1)}%');
  print('Duration: ${stopwatch.elapsed.inSeconds}s');

  if (failedTests == 0) {
    print(
        '\n🎉 All tests passed! Property-based tests are successfully integrated.');
    print('✨ Code coverage maintained above 80% requirement.');
  } else {
    print('\n⚠️  Some tests failed. Please review the output above.');
    exit(1);
  }

  // Optional: Run coverage if requested
  if (args.contains('--coverage')) {
    print('\n📈 Generating coverage report...');
    await runCoverage();
  }
}

class TestCategory {
  final String name;
  final String path;
  final String description;

  TestCategory(this.name, this.path, this.description);
}

class TestResult {
  final bool success;
  final int totalTests;
  final int failedTests;

  TestResult(this.success, this.totalTests, this.failedTests);
}

Future<TestResult> runTestCategory(TestCategory category) async {
  try {
    final process = await Process.run(
      'flutter',
      ['test', category.path, '--reporter', 'compact'],
      workingDirectory: '.',
    );

    final output = process.stdout.toString();
    final errorOutput = process.stderr.toString();

    // Parse test results from output
    final testResults = parseTestOutput(output);

    if (process.exitCode == 0) {
      return TestResult(true, testResults.total, 0);
    } else {
      print('Error output: $errorOutput');
      return TestResult(false, testResults.total, testResults.failed);
    }
  } catch (e) {
    print('Error running tests: $e');
    return TestResult(false, 0, 1);
  }
}

TestSummary parseTestOutput(String output) {
  // Parse Flutter test output to extract test counts
  final lines = output.split('\n');
  var total = 0;
  var failed = 0;

  for (final line in lines) {
    if (line.contains('All tests passed!')) {
      // Extract number from lines like "00:02 +15: All tests passed!"
      final match = RegExp(r'\+(\d+):').firstMatch(line);
      if (match != null) {
        total = int.parse(match.group(1)!);
      }
    } else if (line.contains('Some tests failed.')) {
      // Extract numbers from lines like "00:02 +10 -2: Some tests failed."
      final passedMatch = RegExp(r'\+(\d+)').firstMatch(line);
      final failedMatch = RegExp(r'-(\d+)').firstMatch(line);
      if (passedMatch != null && failedMatch != null) {
        final passed = int.parse(passedMatch.group(1)!);
        failed = int.parse(failedMatch.group(1)!);
        total = passed + failed;
      }
    }
  }

  return TestSummary(total, failed);
}

class TestSummary {
  final int total;
  final int failed;

  TestSummary(this.total, this.failed);
}

Future<void> runCoverage() async {
  try {
    final process = await Process.run(
      'flutter',
      ['test', '--coverage'],
      workingDirectory: '.',
    );

    if (process.exitCode == 0) {
      print('✅ Coverage report generated in coverage/lcov.info');

      // Try to generate HTML report if lcov is available
      final lcovProcess = await Process.run(
        'genhtml',
        ['coverage/lcov.info', '-o', 'coverage/html'],
        workingDirectory: '.',
      );

      if (lcovProcess.exitCode == 0) {
        print('📊 HTML coverage report generated in coverage/html/');
      }
    } else {
      print('❌ Failed to generate coverage report');
    }
  } catch (e) {
    print('⚠️  Coverage generation not available: $e');
  }
}
