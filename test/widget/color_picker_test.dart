import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/color_picker.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  testWidgets('ColorPicker calls onColorSelected when a color is tapped',
      (tester) async {
    NoteColor? selected = NoteColor.classicYellow;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: ColorPicker(
                selectedColor: selected!,
                onColorSelected: (c) {
                  setState(() {
                    selected = c;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    // Initially classicYellow is selected, so check icon is present
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Tap on the second color (coralPink)
    final gestureDetectors = find.byType(GestureDetector);
    expect(gestureDetectors, findsNWidgets(NoteColor.values.length));

    await tester.tap(gestureDetectors.at(1));
    await tester.pumpAndSettle();

    // Now the selected color should have check icon (still one check)
    expect(find.byIcon(Icons.check), findsOneWidget);

    // And the displayed color name should be Coral Pink
    expect(find.text('Coral Pink'), findsOneWidget);
  });
}
