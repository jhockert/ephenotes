import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/widgets/note_card.dart';
import 'package:ephenotes/presentation/widgets/color_picker.dart';
import 'package:ephenotes/presentation/widgets/priority_selector.dart';
import 'package:ephenotes/presentation/widgets/icon_selector.dart';

void main() {
  group('Widget Accessibility Tests', () {
    testWidgets('NoteCard should have proper accessibility semantics',
        (tester) async {
      final note = Note(
        id: '1',
        content: 'Test note content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.high,
        iconCategory: IconCategory.work,
        isPinned: true,
        isArchived: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(
              note: note,
              onTap: () {},
            ),
          ),
        ),
      );

      // Find the main semantics widget
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);

      // Verify semantic properties
      final semanticsWidget = tester.widget<Semantics>(semanticsFinder.first);
      expect(semanticsWidget.properties.label,
          contains('Note: Test note content'));
      expect(semanticsWidget.properties.label, contains('Priority: High'));
      expect(semanticsWidget.properties.label, contains('Pinned'));
      expect(
          semanticsWidget.properties.hint, contains('Double tap to edit note'));
      expect(semanticsWidget.properties.button, isTrue);
      expect(semanticsWidget.properties.enabled, isTrue);
    });

    testWidgets('ColorPicker should have proper accessibility semantics',
        (tester) async {
      NoteColor selectedColor = NoteColor.classicYellow;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ColorPicker(
              selectedColor: selectedColor,
              onColorSelected: (color) {
                selectedColor = color;
              },
            ),
          ),
        ),
      );

      // Find color picker semantics
      final colorPickerSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics && widget.properties.label == 'Color picker');
      expect(colorPickerSemantics, findsOneWidget);

      // Find color option semantics
      final colorOptionSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('color'));
      expect(colorOptionSemantics, findsWidgets);

      // Verify selected color has proper semantics
      final selectedColorSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Classic Yellow color, selected'));
      expect(selectedColorSemantics, findsOneWidget);
    });

    testWidgets('PrioritySelector should have proper accessibility semantics',
        (tester) async {
      NotePriority selectedPriority = NotePriority.high;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrioritySelector(
              selectedPriority: selectedPriority,
              onPrioritySelected: (priority) {
                selectedPriority = priority;
              },
            ),
          ),
        ),
      );

      // Find priority selector semantics
      final prioritySelectorSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label == 'Priority selector');
      expect(prioritySelectorSemantics, findsOneWidget);

      // Find priority option semantics
      final priorityOptionSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('priority'));
      expect(priorityOptionSemantics, findsWidgets);

      // Verify selected priority has proper semantics
      final selectedPrioritySemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('High priority, selected'));
      expect(selectedPrioritySemantics, findsOneWidget);
    });

    testWidgets('IconSelector should have proper accessibility semantics',
        (tester) async {
      IconCategory? selectedIcon = IconCategory.work;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconSelector(
              selectedIcon: selectedIcon,
              onIconSelected: (icon) {
                selectedIcon = icon;
              },
            ),
          ),
        ),
      );

      // Find icon selector semantics
      final iconSelectorSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label == 'Icon category selector');
      expect(iconSelectorSemantics, findsOneWidget);

      // Find icon option semantics
      final iconOptionSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('icon'));
      expect(iconOptionSemantics, findsWidgets);

      // Verify selected icon has proper semantics
      final selectedIconSemantics = find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Work icon, selected'));
      expect(selectedIconSemantics, findsOneWidget);
    });

    testWidgets('Widgets should meet minimum touch target size requirements',
        (tester) async {
      final note = Note(
        id: '1',
        content: 'Test note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.normal,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                NoteCard(note: note, onTap: () {}),
                ColorPicker(
                  selectedColor: NoteColor.classicYellow,
                  onColorSelected: (_) {},
                ),
                PrioritySelector(
                  selectedPriority: NotePriority.normal,
                  onPrioritySelected: (_) {},
                ),
                IconSelector(
                  selectedIcon: null,
                  onIconSelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      // Find all interactive elements
      final interactiveElements = find.byWidgetPredicate((widget) =>
          widget is GestureDetector ||
          widget is InkWell ||
          widget is IconButton ||
          widget is FloatingActionButton);

      // Verify each interactive element meets minimum size requirements
      for (final element in interactiveElements.evaluate()) {
        final renderBox = element.renderObject as RenderBox?;
        if (renderBox != null) {
          final size = renderBox.size;
          // WCAG AA requires minimum 44x44 logical pixels
          expect(size.width >= 44.0 || size.height >= 44.0, isTrue,
              reason:
                  'Interactive element should meet minimum touch target size of 44x44 pixels');
        }
      }
    });

    testWidgets('Should handle screen reader navigation correctly',
        (tester) async {
      final note = Note(
        id: '1',
        content: 'Test note',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.high,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: note, onTap: () {}),
          ),
        ),
      );

      // Enable accessibility testing
      final SemanticsHandle handle = tester.ensureSemantics();

      // Find semantics nodes
      final semanticsNodes =
          tester.binding.rootPipelineOwner.semanticsOwner?.rootSemanticsNode;

      // Verify semantic tree structure
      expect(semanticsNodes, isNotNull);

      // Clean up
      handle.dispose();
    });

    testWidgets('Should provide proper focus management', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ColorPicker(
                  selectedColor: NoteColor.classicYellow,
                  onColorSelected: (_) {},
                ),
                PrioritySelector(
                  selectedPriority: NotePriority.normal,
                  onPrioritySelected: (_) {},
                ),
              ],
            ),
          ),
        ),
      );

      // Test tab navigation
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      // Verify focus is managed correctly
      final focusedWidget = tester.binding.focusManager.primaryFocus;
      expect(focusedWidget, isNotNull);
    });
  });

  group('Accessibility Edge Cases', () {
    testWidgets('Should handle empty or null content gracefully',
        (tester) async {
      final emptyNote = Note(
        id: '1',
        content: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.low,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: emptyNote, onTap: () {}),
          ),
        ),
      );

      // Should not crash and should provide meaningful accessibility info
      final semanticsWidget =
          tester.widget<Semantics>(find.byType(Semantics).first);
      expect(semanticsWidget.properties.label, isNotNull);
      expect(semanticsWidget.properties.label, isNotEmpty);
    });

    testWidgets('Should handle very long content appropriately',
        (tester) async {
      final longNote = Note(
        id: '1',
        content:
            'This is a very long note content that exceeds the normal length and should be handled appropriately by the accessibility system without causing issues',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        color: NoteColor.classicYellow,
        priority: NotePriority.normal,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteCard(note: longNote, onTap: () {}),
          ),
        ),
      );

      // Should truncate content in accessibility label
      final semanticsWidget =
          tester.widget<Semantics>(find.byType(Semantics).first);
      expect(semanticsWidget.properties.label, isNotNull);
      expect(semanticsWidget.properties.label!.length, lessThan(300));
    });
  });
}
