import 'package:ephenotes/data/models/note.dart';

/// Abstract interface for local note storage operations.
///
/// Defines the contract for storing and retrieving notes from local storage.
/// Implementations should handle the actual storage mechanism (Hive, SQLite, etc.).
abstract class NoteLocalDataSource {
  /// Retrieves all notes from local storage.
  ///
  /// Returns a list of all notes, including both active and archived notes.
  /// Returns an empty list if no notes exist.
  Future<List<Note>> getAllNotes();

  /// Retrieves a single note by its ID.
  ///
  /// Throws an exception if the note is not found.
  Future<Note> getNoteById(String id);

  /// Creates a new note in local storage.
  ///
  /// The note must have a unique ID. Throws an exception if a note
  /// with the same ID already exists.
  Future<void> createNote(Note note);

  /// Updates an existing note in local storage.
  ///
  /// Throws an exception if the note doesn't exist.
  Future<void> updateNote(Note note);

  /// Deletes a note from local storage.
  ///
  /// Throws an exception if the note doesn't exist.
  Future<void> deleteNote(String id);

  /// Retrieves all active (non-archived) notes.
  ///
  /// Returns notes where [Note.isArchived] is false.
  Future<List<Note>> getActiveNotes();

  /// Retrieves all archived notes.
  ///
  /// Returns notes where [Note.isArchived] is true.
  Future<List<Note>> getArchivedNotes();

  /// Retrieves all pinned notes.
  ///
  /// Returns notes where [Note.isPinned] is true.
  Future<List<Note>> getPinnedNotes();
}
