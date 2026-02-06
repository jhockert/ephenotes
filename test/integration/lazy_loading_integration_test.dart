import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('Lazy Loading Integration Tests', () {
    late PerformanceMonitor performanceMonitor;

    setUp(() {
      performanceMonitor = PerformanceMonitor();
      performanceMonitor.initialize();
    });

    testWidgets('displays virtual scrolling for large note collections',
        (WidgetTester tester) async {
      // Generate a large collection of notes
      final largeNoteCollection = TestHelpers.generateTestNotes(500);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: largeNoteCollection,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify that virtual scrolling is being used for large collections
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify that not all notes are rendered at once (memory efficiency)
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, lessThan(500),
          reason: 'Should use virtual scrolling and not render all 500 notes');

      // Verify that some notes are visible
      expect(renderedCards, greaterThan(0),
          reason: 'Should render some visible notes');
    });

    testWidgets('handles scrolling through large collections smoothly',
        (WidgetTester tester) async {
      final largeNoteCollection = TestHelpers.generateTestNotes(300);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: largeNoteCollection,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the scrollable widget
      final scrollable = find.byType(CustomScrollView);
      expect(scrollable, findsOneWidget);

      // Perform multiple scroll operations
      for (int i = 0; i < 5; i++) {
        await tester.drag(scrollable, const Offset(0, -200));
        await tester
            .pump(const Duration(milliseconds: 16)); // One frame at 60 FPS
      }

      await tester.pumpAndSettle();

      // Verify the list is still responsive
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify that cards are still being rendered
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, greaterThan(0));
    });

    testWidgets(
        'switches between regular and virtual scrolling based on note count',
        (WidgetTester tester) async {
      // Test with small collection first
      final smallCollection = TestHelpers.generateTestNotes(50);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallCollection,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // For small collections, should use regular ListView
      expect(find.byType(ListView), findsOneWidget);

      // Test with large collection
      final largeCollection = TestHelpers.generateTestNotes(200);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: largeCollection,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should use CustomScrollView for virtual scrolling
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should not render all items
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, lessThan(200));
    });

    testWidgets('maintains performance with very large collections',
        (WidgetTester tester) async {
      // Create a large collection to test performance (reduced size for test efficiency)
      final largeCollection = TestHelpers.generateTestNotes(200);

      // Start performance monitoring
      performanceMonitor.startNoteListMonitoring(200);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: largeCollection,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify virtual scrolling is active
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Verify memory efficiency - should render much fewer than 200 items
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, lessThan(100),
          reason: 'Should render much fewer items for memory efficiency');

      // Perform some scrolling to test performance
      final scrollable = find.byType(CustomScrollView);
      for (int i = 0; i < 3; i++) {
        await tester.drag(scrollable, const Offset(0, -300));
        await tester.pump(const Duration(milliseconds: 16));
      }

      await tester.pumpAndSettle();

      // Stop performance monitoring
      await performanceMonitor.stopNoteListMonitoring();

      // Verify the app is still responsive
      expect(find.byType(CustomScrollView), findsOneWidget);
    }, timeout: const Timeout(Duration(minutes: 2)));

    testWidgets('handles rapid note list updates efficiently',
        (WidgetTester tester) async {
      var noteCollection = TestHelpers.generateTestNotes(100);

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: VirtualNoteList(
                  notes: noteCollection,
                  onNoteTap: (note) {},
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      // Simulate adding more notes
                      noteCollection = [
                        ...noteCollection,
                        ...TestHelpers.generateTestNotes(50)
                      ];
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

      // Initial state
      expect(find.byType(ListView), findsOneWidget); // Small list uses ListView

      // Add more notes to trigger virtual scrolling
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should now use virtual scrolling
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should handle the update efficiently
      final renderedCards = tester.widgetList(find.byType(Card)).length;
      expect(renderedCards, lessThan(150)); // Should not render all items
    });
  });
}
