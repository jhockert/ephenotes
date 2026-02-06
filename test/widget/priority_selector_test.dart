import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/priority_selector.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  testWidgets('PrioritySelector updates selected when tapped', (tester) async {
    NotePriority selected = NotePriority.normal;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: PrioritySelector(
                selectedPriority: selected,
                onPrioritySelected: (p) {
                  setState(() {
                    selected = p;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    // Medium label should be present
    expect(find.text('Medium'), findsOneWidget);

    // Tap High
    await tester.tap(find.text('High'));
    await tester.pumpAndSettle();

    // Now the High label should be bold (selected)
    final textWidget = tester.firstWidget<Text>(find.text('High'));
    expect(textWidget.style!.fontWeight, equals(FontWeight.bold));
  });
}
