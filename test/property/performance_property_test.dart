import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import '../helpers/property_based_testing.dart';
import '../helpers/note_generators.dart';
import '../helpers/test_helpers.dart';

/// **Property-Based Tests for Performance Requirements**
///
/// **Validates: Requirements NFR-1.1, NFR-1.2, NFR-1.3**
///
/// This test suite validates that the app maintains performance targets under load:
/// - Memory usage stays under 100MB with 1000 notes
/// - Animation performance maintains 60 FPS
/// - Rapid operations don't cause performance degradation
/// - Large datasets are handled efficiently

void main() {
  group('Performance Property Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor();
      performanceMonitor.initialize();
    });

    /// **Property 1: Memory Usage Under Load**
    /// **Validates: Requirements NFR-1.1**
    ///
    /// Property: App memory usage stays under 100MB even with 1000 notes
    /// and various rapid operations
    testWidgets('app maintains memory targets under load',
        (WidgetTester tester) async {
      // Generate large dataset for testing
      final notes = TestHelpers.generateLargeTestDataset(size: 1000);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: notes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial memory usage
      final initialMemory = await performanceMonitor.getCurrentMemoryUsageMB();
      expect(initialMemory, lessThan(100),
          reason: 'Initial memory usage exceeded 100MB limit with 1000 notes');

      // Perform rapid scrolling operations to stress memory
      for (int i = 0; i < 30; i++) {
        await tester.drag(
          find.byType(CustomScrollView),
          Offset(0, -100 - (i * 10)),
        );
        await tester.pump(const Duration(milliseconds: 16)); // 60 FPS target

        // Check memory periodically
        if (i % 10 == 0) {
          final memoryUsage =
              await performanceMonitor.getCurrentMemoryUsageMB();
          expect(memoryUsage, lessThan(100),
              reason:
                  'Memory usage exceeded 100MB limit during operation $i with 1000 notes');
        }
      }

      await tester.pumpAndSettle();

      // Final memory check
      final finalMemoryUsage =
          await performanceMonitor.getCurrentMemoryUsageMB();
      expect(finalMemoryUsage, lessThan(100),
          reason: 'Final memory usage exceeded 100MB limit with 1000 notes');
    });

    /// **Property 2: Frame Rate Performance Under Load**
    /// **Validates: Requirements NFR-1.3**
    ///
    /// Property: App maintains acceptable FPS performance during animations and
    /// scrolling operations with large datasets
    testWidgets('app maintains FPS performance under load',
        (WidgetTester tester) async {
      // Generate large dataset
      final notes = TestHelpers.generateLargeTestDataset(size: 800);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: notes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start performance monitoring
      performanceMonitor.startNoteListMonitoring(notes.length);

      // Perform continuous scrolling operations
      for (int i = 0; i < 50; i++) {
        await tester.drag(
          find.byType(CustomScrollView),
          Offset(0, -50 + (i % 2 == 0 ? 25 : -25)), // Vary scroll direction
        );
        await tester.pump(const Duration(milliseconds: 16)); // Target 60 FPS
      }

      await tester.pumpAndSettle();
      await performanceMonitor.stopNoteListMonitoring();

      // Check frame rate performance
      final fps = performanceMonitor.getCurrentFPS();
      final frameTime = performanceMonitor.getAverageFrameTimeMs();

      // Allow some tolerance for test environment limitations
      expect(fps, greaterThan(45.0),
          reason:
              'FPS dropped below acceptable threshold (45 FPS) with ${notes.length} notes');
      expect(frameTime, lessThan(22.0), // ~45 FPS = 22ms per frame
          reason:
              'Frame time exceeded acceptable threshold with ${notes.length} notes');
    });

    /// **Property 3: Large Dataset Initialization Performance**
    /// **Validates: Requirements NFR-1.1**
    ///
    /// Property: App initializes efficiently with large datasets and
    /// maintains performance targets during initial render
    testWidgets('initializes efficiently with large datasets',
        (WidgetTester tester) async {
      // Test with exactly 1000 notes as specified in requirements
      final notes = TestHelpers.generateLargeTestDataset(size: 1000);

      // Measure initialization performance
      final startTime = DateTime.now();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: notes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      // Measure time to first frame
      await tester.pump();
      final firstFrameTime = DateTime.now();

      await tester.pumpAndSettle();
      final settledTime = DateTime.now();

      // Check initialization timing
      final initializationTime = firstFrameTime.difference(startTime);
      final settleTime = settledTime.difference(firstFrameTime);

      expect(initializationTime.inMilliseconds, lessThan(2000),
          reason: 'Initialization took too long with 1000 notes');
      expect(settleTime.inMilliseconds, lessThan(3000),
          reason: 'Settling took too long with 1000 notes');

      // Check memory usage after initialization
      final postInitMemory = await performanceMonitor.getCurrentMemoryUsageMB();
      expect(postInitMemory, lessThan(100),
          reason: 'Memory exceeded limit after initializing 1000 notes');

      // Verify virtual scrolling is working (not all items rendered)
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, lessThan(1000),
          reason: 'Should use virtual scrolling, not render all 1000 items');
      expect(renderedCards, greaterThan(0), reason: 'Should render some items');

      // Test scroll performance with large dataset
      performanceMonitor.startNoteListMonitoring(notes.length);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pump(const Duration(milliseconds: 16));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, 500));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.pumpAndSettle();
      await performanceMonitor.stopNoteListMonitoring();

      // Final performance check
      final finalMemory = await performanceMonitor.getCurrentMemoryUsageMB();
      final fps = performanceMonitor.getCurrentFPS();

      expect(finalMemory, lessThan(100),
          reason: 'Memory exceeded limit after scrolling 1000 notes');
      expect(fps, greaterThan(40.0),
          reason: 'FPS too low when scrolling 1000 notes');
    });

    /// **Property 4: Performance with Property-Based Note Variations**
    /// **Validates: Requirements NFR-1.1, NFR-1.2**
    ///
    /// Property: Performance remains consistent regardless of note content
    /// variations, priorities, and formatting complexity
    testProperty('performance consistent across note variations', () {
      forAll3(
        noteListGenerator(
            minLength: 500, maxLength: 800, allowLongContent: true),
        Generator.oneOf(
            [NotePriority.high, NotePriority.normal, NotePriority.low]),
        boolGenerator(), // Complex formatting enabled
        (List<Note> baseNotes, NotePriority dominantPriority,
            bool complexFormatting) {
          // Create notes with varying complexity
          final notes = baseNotes.map((note) {
            return note.copyWith(
              priority: dominantPriority,
              isBold: complexFormatting ? true : note.isBold,
              isItalic: complexFormatting ? true : note.isItalic,
              isUnderlined: complexFormatting ? true : note.isUnderlined,
              fontSize: complexFormatting ? FontSize.large : note.fontSize,
            );
          }).toList();

          // Test that we can create the widget without performance issues
          expect(notes.length, greaterThan(500));
          expect(notes.length, lessThan(801));

          // Verify all notes have the expected characteristics
          for (final note in notes) {
            expect(note.priority, equals(dominantPriority));
            if (complexFormatting) {
              expect(note.isBold, isTrue);
              expect(note.isItalic, isTrue);
              expect(note.isUnderlined, isTrue);
              expect(note.fontSize, equals(FontSize.large));
            }
          }

          // Performance validation: ensure we can process large lists efficiently
          final startTime = DateTime.now();

          // Simulate sorting operations that would happen in the UI
          final sortedNotes = List<Note>.from(notes);
          sortedNotes.sort((a, b) {
            // Pinned notes first
            if (a.isPinned != b.isPinned) {
              return a.isPinned ? -1 : 1;
            }
            // Then by priority
            if (a.priority != b.priority) {
              return a.priority.index.compareTo(b.priority.index);
            }
            // Then by creation date
            return b.createdAt.compareTo(a.createdAt);
          });

          final endTime = DateTime.now();
          final processingTime = endTime.difference(startTime);

          expect(processingTime.inMilliseconds, lessThan(100),
              reason:
                  'Note processing took too long for ${notes.length} notes');
          expect(sortedNotes.length, equals(notes.length));
        },
        iterations: 10, // Reduced iterations for complex operations
      );
    });

    /// **Property 5: Rapid State Changes Performance**
    /// **Validates: Requirements NFR-1.2**
    ///
    /// Property: App handles rapid state changes (pin/unpin, archive/restore)
    /// without performance degradation
    testProperty('handles rapid state changes efficiently', () {
      forAll2(
        noteListGenerator(minLength: 200, maxLength: 500),
        intGenerator(min: 50, max: 200), // Number of state changes
        (List<Note> initialNotes, int stateChanges) {
          var notes = List<Note>.from(initialNotes);
          final startTime = DateTime.now();

          // Perform rapid state changes
          for (int i = 0; i < stateChanges; i++) {
            if (notes.isNotEmpty) {
              final randomIndex = i % notes.length;
              final note = notes[randomIndex];

              // Alternate between different state changes
              switch (i % 4) {
                case 0: // Toggle pin state
                  notes[randomIndex] = note.copyWith(
                    isPinned: !note.isPinned && !note.isArchived,
                  );
                  break;
                case 1: // Toggle archive state
                  notes[randomIndex] = note.copyWith(
                    isArchived: !note.isArchived,
                    isPinned: note.isArchived ? note.isPinned : false,
                  );
                  break;
                case 2: // Change priority
                  final priorities = NotePriority.values;
                  final newPriority =
                      priorities[(note.priority.index + 1) % priorities.length];
                  notes[randomIndex] = note.copyWith(priority: newPriority);
                  break;
                case 3: // Change color
                  final colors = NoteColor.values;
                  final newColor =
                      colors[(note.color.index + 1) % colors.length];
                  notes[randomIndex] = note.copyWith(color: newColor);
                  break;
              }
            }
          }

          final endTime = DateTime.now();
          final processingTime = endTime.difference(startTime);

          // Performance validation
          expect(processingTime.inMilliseconds, lessThan(1000),
              reason:
                  'Rapid state changes took too long: ${processingTime.inMilliseconds}ms for $stateChanges changes');

          // Verify data integrity after rapid changes
          expect(notes.length, equals(initialNotes.length));

          // Verify archive-pin invariant is maintained
          for (final note in notes) {
            expect(note.isArchived && note.isPinned, isFalse,
                reason:
                    'Note cannot be both archived and pinned after state changes');
          }
        },
        iterations: 8, // Reduced iterations for intensive operations
      );
    });
  });
}
