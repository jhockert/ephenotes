import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/data/models/note.dart';

/// In-memory fake datasource for tests with error simulation capabilities.
class FakeNoteLocalDataSource implements NoteLocalDataSource {
  final Map<String, Note> _store = {};

  /// Flag to simulate operation failures for error testing
  bool shouldFailNextOperation = false;

  /// Counter for operations to simulate intermittent failures
  int _operationCount = 0;

  /// Simulate failure every N operations (0 = no intermittent failures)
  int failEveryNOperations = 0;

  /// Check if operation should fail and reset flag if needed
  bool _shouldFail() {
    _operationCount++;

    if (shouldFailNextOperation) {
      shouldFailNextOperation = false;
      return true;
    }

    if (failEveryNOperations > 0 &&
        _operationCount % failEveryNOperations == 0) {
      return true;
    }

    return false;
  }

  @override
  Future<void> createNote(Note note) async {
    if (_shouldFail()) throw Exception('Simulated create failure');
    if (_store.containsKey(note.id)) throw Exception('Note exists');
    _store[note.id] = note;
  }

  @override
  Future<void> deleteNote(String id) async {
    if (_shouldFail()) throw Exception('Simulated delete failure');
    _store.remove(id);
  }

  @override
  Future<List<Note>> getAllNotes() async {
    if (_shouldFail()) throw Exception('Simulated get all failure');
    return _store.values.toList();
  }

  @override
  Future<Note> getNoteById(String id) async {
    if (_shouldFail()) throw Exception('Simulated get by id failure');
    final note = _store[id];
    if (note == null) throw Exception('Not found');
    return note;
  }

  @override
  Future<List<Note>> getActiveNotes() async {
    if (_shouldFail()) throw Exception('Simulated get active failure');
    return _store.values.where((n) => !n.isArchived).toList();
  }

  @override
  Future<List<Note>> getArchivedNotes() async {
    if (_shouldFail()) throw Exception('Simulated get archived failure');
    return _store.values.where((n) => n.isArchived).toList();
  }

  @override
  Future<List<Note>> getPinnedNotes() async {
    if (_shouldFail()) throw Exception('Simulated get pinned failure');
    return _store.values.where((n) => n.isPinned && !n.isArchived).toList();
  }

  @override
  Future<void> updateNote(Note note) async {
    if (_shouldFail()) throw Exception('Simulated update failure');
    if (!_store.containsKey(note.id)) throw Exception('Not found');
    _store[note.id] = note;
  }

  /// Helper methods for testing

  /// Clear all data (useful for test cleanup)
  void clear() {
    _store.clear();
    _operationCount = 0;
    shouldFailNextOperation = false;
    failEveryNOperations = 0;
  }

  /// Get current store size
  int get size => _store.length;

  /// Check if store contains note with given ID
  bool contains(String id) => _store.containsKey(id);

  /// Create a note directly (bypasses error simulation)
  Future<void> create(Note note) async {
    _store[note.id] = note;
  }

  /// Get all notes directly (bypasses error simulation)
  Future<List<Note>> getAll() async {
    return _store.values.toList();
  }
}
