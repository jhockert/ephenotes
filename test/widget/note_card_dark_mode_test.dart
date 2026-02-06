import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/presentation/widgets/note_card.dart';
import 'package:ephenotes/core/constants/app_colors.dart';

void main() {
  group('NoteCard dark mode text color', () {
    const noteColors = NoteColor.values;

    for (final color in noteColors) {
      testWidgets('text is readable for $color in dark mode', (tester) async {
        final note = Note(
          id: '1',
          content: 'Test note',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          color: color,
          priority: NotePriority.normal,
          isPinned: false,
          isArchived: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: NoteCard(
              note: note,
              onTap: () {},
            ),
          ),
        );

        final textFinder = find.text('Test note');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        final expectedColor = AppColors.noteTextColor(Brightness.dark, color);
        expect(textWidget.style?.color, expectedColor);
      });
    }

    testWidgets('text is readable for all colors in light mode',
        (tester) async {
      for (final color in noteColors) {
        final note = Note(
          id: '2',
          content: 'Light note',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          color: color,
          priority: NotePriority.low,
          isPinned: false,
          isArchived: false,
        );

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: NoteCard(
              note: note,
              onTap: () {},
            ),
          ),
        );

        final textFinder = find.text('Light note');
        expect(textFinder, findsOneWidget);

        final textWidget = tester.widget<Text>(textFinder);
        final expectedColor = AppColors.noteTextColor(Brightness.light, color);
        expect(textWidget.style?.color, expectedColor);
      }
    });
  });
}
