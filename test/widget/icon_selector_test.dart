import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/widgets/icon_selector.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  testWidgets('IconSelector calls onIconSelected when tapping an icon',
      (tester) async {
    IconCategory? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              body: IconSelector(
                selectedIcon: selected,
                onIconSelected: (icon) {
                  setState(() {
                    selected = icon;
                  });
                },
              ),
            );
          },
        ),
      ),
    );

    // Tap 'Work' icon label
    await tester.tap(find.text('Work'));
    await tester.pumpAndSettle();

    // Selected should be work and label should be bold
    final textWidget = tester.firstWidget<Text>(find.text('Work'));
    expect(textWidget.style!.fontWeight, equals(FontWeight.bold));
  });
}
