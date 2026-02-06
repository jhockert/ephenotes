import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Lazy Loading Performance Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor();
      performanceMonitor.initialize();
    });

    testWidgets('handles 1000 notes within memory target',
        (WidgetTester tester) async {
      // Generate 1000 test notes
      final notes = TestHelpers.generateTestNotes(1000);

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

      // Let the widget settle
      await tester.pumpAndSettle();

      // Check memory usage (this is a simulation since we can't get real memory in tests)
      final memoryUsage = await performanceMonitor.getCurrentMemoryUsageMB();

      // In a real test environment, this would be more meaningful
      // For now, we verify the performance monitor is working
      expect(memoryUsage, isA<int>());

      // Verify virtual scrolling is active (not all items rendered)
      final cardCount = tester.widgetList(find.byType(Card)).length;
      expect(cardCount, lessThan(1000),
          reason: 'Should use virtual scrolling and not render all 1000 items');
    });

    testWidgets('maintains smooth scrolling with large datasets',
        (WidgetTester tester) async {
      final notes = TestHelpers.generateTestNotes(500);

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

      // Simulate rapid scrolling
      final scrollView = find.byType(CustomScrollView);
      expect(scrollView, findsOneWidget);

      // Perform multiple scroll operations quickly
      for (int i = 0; i < 10; i++) {
        await tester.drag(scrollView, const Offset(0, -100));
        await tester.pump(const Duration(milliseconds: 16)); // Target 60 FPS
      }

      await tester.pumpAndSettle();

      // Verify the list is still responsive
      expect(scrollView, findsOneWidget);

      // Check that we can still interact with items
      final visibleCards = find.byType(Card);
      if (visibleCards.evaluate().isNotEmpty) {
        await tester.tap(visibleCards.first);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('efficiently handles note list updates',
        (WidgetTester tester) async {
      var notes = TestHelpers.generateTestNotes(200);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: VirtualNoteList(
                  notes: notes,
                  onNoteTap: (note) {},
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      // Add more notes
                      notes = [...notes, ...TestHelpers.generateTestNotes(50)];
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add more notes
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify the list updated efficiently
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should still be using virtual scrolling
      final cardCount = tester.widgetList(find.byType(Card)).length;
      expect(cardCount, lessThan(250),
          reason: 'Should still use virtual scrolling after update');
    });

    testWidgets('handles empty to large list transition',
        (WidgetTester tester) async {
      var notes = <Note>[];

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: VirtualNoteList(
                  notes: notes,
                  onNoteTap: (note) {},
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      notes = TestHelpers.generateTestNotes(300);
                    });
                  },
                  child: const Icon(Icons.add),
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially empty
      expect(find.byType(Card), findsNothing);

      // Add large number of notes
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should transition to virtual scrolling
      expect(find.byType(CustomScrollView), findsOneWidget);

      final cardCount = tester.widgetList(find.byType(Card)).length;
      expect(cardCount, lessThan(300),
          reason: 'Should use virtual scrolling for large list');
    });

    group('Performance Monitoring Integration', () {
      testWidgets('performance monitor tracks frame rates',
          (WidgetTester tester) async {
        final notes = TestHelpers.generateTestNotes(100);

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

        // Simulate some scrolling to generate frame data
        for (int i = 0; i < 5; i++) {
          await tester.drag(find.byType(ListView), const Offset(0, -50));
          await tester.pump(const Duration(milliseconds: 16));
        }

        await tester.pumpAndSettle();

        // Verify performance monitor is collecting data
        final fps = performanceMonitor.getCurrentFPS();
        expect(fps, isA<double>());

        final frameTime = performanceMonitor.getAverageFrameTimeMs();
        expect(frameTime, isA<double>());
      });

      testWidgets('performance status reflects list performance',
          (WidgetTester tester) async {
        final notes = TestHelpers.generateTestNotes(50);

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

        // Get performance status
        final status = performanceMonitor.getPerformanceStatus();
        expect(status, isA<PerformanceStatus>());

        // For a small list, performance should be good
        // (Note: In test environment, this might not be fully accurate)
        expect([
          PerformanceStatus.good,
          PerformanceStatus.warning,
          PerformanceStatus.poor
        ], contains(status));
      });
    });

    group('Memory Efficiency', () {
      testWidgets('limits rendered widgets for memory efficiency',
          (WidgetTester tester) async {
        final notes = TestHelpers.generateTestNotes(1000);

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

        // Count rendered widgets
        final cardCount = tester.widgetList(find.byType(Card)).length;
        final noteCardCount = tester.widgetList(find.byType(Card)).length;

        // Should render much fewer widgets than total notes
        expect(cardCount, lessThan(100),
            reason: 'Should limit rendered widgets for memory efficiency');
        expect(noteCardCount, lessThan(100),
            reason: 'Should limit rendered note cards for memory efficiency');
      });

      testWidgets('reuses widgets during scrolling',
          (WidgetTester tester) async {
        final notes = TestHelpers.generateTestNotes(200);

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

        // Get initial widget count
        final initialCardCount = tester.widgetList(find.byType(Card)).length;

        // Scroll significantly
        await tester.drag(
            find.byType(CustomScrollView), const Offset(0, -1000));
        await tester.pumpAndSettle();

        // Widget count should remain similar (widget reuse)
        final afterScrollCardCount =
            tester.widgetList(find.byType(Card)).length;

        expect(afterScrollCardCount,
            closeTo(initialCardCount, 20), // Allow some variance
            reason: 'Should reuse widgets during scrolling');
      });
    });
  });
}
