import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/data/models/note.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('VirtualNoteList', () {
    late List<Note> testNotes;

    setUp(() {
      testNotes =
          TestHelpers.generateTestNotes(150); // Generate 150 notes for testing
    });

    testWidgets('renders small lists normally', (WidgetTester tester) async {
      final smallNotes = testNotes.take(50).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallNotes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      // For small lists, should use regular ListView
      expect(find.byType(ListView), findsOneWidget);

      // Should render visible items (not necessarily all items due to viewport)
      final cardCount = tester.widgetList(find.byType(Card)).length;
      expect(cardCount, greaterThan(0));
      expect(cardCount, lessThanOrEqualTo(50));
    });

    testWidgets('uses virtual scrolling for large lists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: testNotes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      // Should use CustomScrollView for large lists
      expect(find.byType(CustomScrollView), findsOneWidget);

      // Should not render all items at once (virtual scrolling)
      final cardCount = tester.widgetList(find.byType(Card)).length;
      expect(cardCount, lessThan(testNotes.length));
    });

    testWidgets('handles empty list gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: const [],
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsNothing);
    });

    testWidgets('calls onNoteTap when note is tapped',
        (WidgetTester tester) async {
      Note? tappedNote;
      final smallNotes = testNotes.take(10).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallNotes,
              onNoteTap: (note) {
                tappedNote = note;
              },
            ),
          ),
        ),
      );

      // Tap the first note
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(tappedNote, equals(smallNotes.first));
    });

    testWidgets('calls onNoteLongPress when note is long pressed',
        (WidgetTester tester) async {
      Note? longPressedNote;
      final smallNotes = testNotes.take(10).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallNotes,
              onNoteTap: (note) {},
              onNoteLongPress: (note) {
                longPressedNote = note;
              },
            ),
          ),
        ),
      );

      // Long press the first note
      await tester.longPress(find.byType(Card).first);
      await tester.pumpAndSettle();

      expect(longPressedNote, equals(smallNotes.first));
    });

    testWidgets('uses custom item builder when provided',
        (WidgetTester tester) async {
      final smallNotes = testNotes.take(10).toList();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallNotes,
              onNoteTap: (note) {},
              customItemBuilder: (note) => Container(
                key: ValueKey('custom-${note.id}'),
                child: Text(note.content),
              ),
            ),
          ),
        ),
      );

      // Should use custom builder instead of NoteCard
      expect(find.byType(Card), findsNothing);
      expect(find.byKey(ValueKey('custom-${smallNotes.first.id}')),
          findsOneWidget);
    });

    testWidgets('applies padding correctly', (WidgetTester tester) async {
      final smallNotes = testNotes.take(10).toList();
      const testPadding = EdgeInsets.all(16.0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: smallNotes,
              onNoteTap: (note) {},
              padding: testPadding,
            ),
          ),
        ),
      );

      // For small lists, should find ListView with padding
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, equals(testPadding));
    });

    testWidgets('scrolls smoothly with large lists',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VirtualNoteList(
              notes: testNotes,
              onNoteTap: (note) {},
            ),
          ),
        ),
      );

      // Scroll down
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Should still be responsive
      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    group('Performance', () {
      testWidgets('limits rendered items for memory efficiency',
          (WidgetTester tester) async {
        // Generate a very large list
        final largeNotes = TestHelpers.generateTestNotes(1000);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualNoteList(
                notes: largeNotes,
                onNoteTap: (note) {},
              ),
            ),
          ),
        );

        // Should not render all 1000 items at once
        final cardCount = tester.widgetList(find.byType(Card)).length;
        expect(cardCount, lessThan(100)); // Should be much less than total
      });

      testWidgets('maintains smooth scrolling with large datasets',
          (WidgetTester tester) async {
        final largeNotes = TestHelpers.generateTestNotes(500);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualNoteList(
                notes: largeNotes,
                onNoteTap: (note) {},
              ),
            ),
          ),
        );

        // Perform multiple scroll operations
        for (int i = 0; i < 5; i++) {
          await tester.drag(
              find.byType(CustomScrollView), const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 16)); // One frame
        }

        // Should complete without hanging
        await tester.pumpAndSettle();
        expect(find.byType(CustomScrollView), findsOneWidget);
      });
    });
  });
}
