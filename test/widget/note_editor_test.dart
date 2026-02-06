import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/data/models/note.dart';

class MockNotesBloc extends Mock implements NotesBloc {}

class FakeNotesEvent extends Fake implements NotesEvent {}

void main() {
  late MockNotesBloc mockNotesBloc;

  setUpAll(() {
    registerFallbackValue(FakeNotesEvent());
  });

  setUp(() {
    mockNotesBloc = MockNotesBloc();
    when(() => mockNotesBloc.add(any())).thenReturn(null);
    when(() => mockNotesBloc.state).thenReturn(NotesLoaded(notes: const [], lastUpdated: DateTime.now()));
    when(() => mockNotesBloc.stream)
        .thenAnswer((_) => Stream.value(NotesLoaded(notes: const [], lastUpdated: DateTime.now())));
  });

  testWidgets('NoteEditor shows character counter and enforces max length',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NotesBloc>.value(
          value: mockNotesBloc,
          child: const NoteEditorScreen(),
        ),
      ),
    );

    // Enter 140 characters
    final longText = 'a' * 200;
    await tester.enterText(find.byType(TextField), longText);
    await tester.pumpAndSettle();

    // Counter should show 140/140 due to enforced max length
    expect(find.text('140/140'), findsOneWidget);

    // Save should dispatch CreateNote when content is not empty
    // Tap the AppBar Save button (avoid ambiguity with ColorPicker's check icon)
    await tester.tap(find.widgetWithIcon(IconButton, Icons.check));
    await tester.pumpAndSettle();

    verify(() => mockNotesBloc.add(any())).called(1);
  });

  testWidgets('Text formatting toggles and font size selection update style',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<NotesBloc>.value(
          value: mockNotesBloc,
          child: const NoteEditorScreen(),
        ),
      ),
    );

    // Initially not bold
    TextField tf = tester.widget(find.byType(TextField));
    expect(tf.style!.fontWeight, isNot(FontWeight.bold));

    // Tap Bold
    await tester.tap(find.byIcon(Icons.format_bold));
    await tester.pumpAndSettle();

    tf = tester.widget(find.byType(TextField));
    expect(tf.style!.fontWeight, equals(FontWeight.bold));

    // Tap Italic
    await tester.tap(find.byIcon(Icons.format_italic));
    await tester.pumpAndSettle();

    tf = tester.widget(find.byType(TextField));
    expect(tf.style!.fontStyle, equals(FontStyle.italic));

    // Tap Underline
    await tester.tap(find.byIcon(Icons.format_underline));
    await tester.pumpAndSettle();

    tf = tester.widget(find.byType(TextField));
    expect(tf.style!.decoration, equals(TextDecoration.underline));

    // Change font size to Large via dropdown
    await tester.tap(find.byType(DropdownButton<FontSize>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Large').last);
    await tester.pumpAndSettle();

    tf = tester.widget(find.byType(TextField));
    expect(tf.style!.fontSize, equals(16.0));
  });
}
