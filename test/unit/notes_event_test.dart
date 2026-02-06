import 'package:flutter_test/flutter_test.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/data/models/note.dart';

void main() {
  test('CreateNote props and equality', () {
    final note = Note(
        id: '1',
        content: 'a',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
    final e1 = CreateNote(note);
    final e2 = CreateNote(note);

    expect(e1.props, equals([note]));
    expect(e1, equals(e2));
  });

  test('UpdateNote props', () {
    final note = Note(
        id: '1',
        content: 'b',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now());
    final e = UpdateNote(note);
    expect(e.props, equals([note]));
  });

  test('Delete/Archive/Unarchive/Pin/Unpin props', () {
    const delete = DeleteNote('1');
    const archive = ArchiveNote('2');
    const unarchive = UnarchiveNote('3');
    const pin = PinNote('4');
    const unpin = UnpinNote('5');

    expect(delete.props, equals(['1']));
    expect(archive.props, equals(['2']));
    expect(unarchive.props, equals(['3']));
    expect(pin.props, equals(['4']));
    expect(unpin.props, equals(['5']));
  });

  test('Search and ClearSearch props', () {
    const s = SearchNotes('query');
    const c = ClearSearch();
    expect(s.props, equals(['query']));
    expect(c.props, equals([]));
  });

  test('ToggleArchiveView props', () {
    const t = ToggleArchiveView(true);
    expect(t.props, equals([true]));
  });
}
