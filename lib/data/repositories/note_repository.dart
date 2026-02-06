import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:ephenotes/core/error/error_handler.dart';

/// Abstract repository interface for note operations.
///
/// Defines the contract for managing notes in the application.
/// This abstraction allows for easy testing and potential future
/// implementation of cloud sync or other storage mechanisms.
abstract class NoteRepository {
  /// Retrieves all notes.
  Future<List<Note>> getAll();

  /// Retrieves a note by its ID.
  Future<Note> getById(String id);

  /// Creates a new note.
  Future<void> create(Note note);

  /// Updates an existing note.
  Future<void> update(Note note);

  /// Deletes a note permanently.
  Future<void> delete(String id);

  /// Retrieves all active (non-archived) notes.
  Future<List<Note>> getActive();

  /// Retrieves all archived notes.
  Future<List<Note>> getArchived();

  /// Retrieves all pinned notes (only active, non-archived).
  Future<List<Note>> getPinned();
}

/// Implementation of [NoteRepository] using a local datasource.
class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _dataSource;

  /// Creates a [NoteRepositoryImpl] with the given datasource.
  NoteRepositoryImpl({required NoteLocalDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<List<Note>> getAll() async {
    try {
      return await _dataSource.getAllNotes();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<Note> getById(String id) async {
    try {
      return await _dataSource.getNoteById(id);
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> create(Note note) async {
    try {
      // Validate note content doesn't exceed 140 characters
      if (note.content.length > 140) {
        throw ValidationError(
          userMessage: 'Note content cannot exceed 140 characters.',
          technicalMessage: 'Note content length: ${note.content.length}',
          errorCode: 'VALIDATION_CONTENT_LENGTH',
          fieldName: 'content',
          invalidValue: note.content,
        );
      }

      // Validate note content is not empty
      if (note.content.trim().isEmpty) {
        throw ValidationError(
          userMessage: 'Note content cannot be empty.',
          technicalMessage: 'Empty note content provided',
          errorCode: 'VALIDATION_CONTENT_EMPTY',
          fieldName: 'content',
          invalidValue: note.content,
        );
      }

      await _dataSource.createNote(note);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> update(Note note) async {
    try {
      // Validate note content doesn't exceed 140 characters
      if (note.content.length > 140) {
        throw ValidationError(
          userMessage: 'Note content cannot exceed 140 characters.',
          technicalMessage: 'Note content length: ${note.content.length}',
          errorCode: 'VALIDATION_CONTENT_LENGTH',
          fieldName: 'content',
          invalidValue: note.content,
        );
      }

      // Validate note content is not empty
      if (note.content.trim().isEmpty) {
        throw ValidationError(
          userMessage: 'Note content cannot be empty.',
          technicalMessage: 'Empty note content provided',
          errorCode: 'VALIDATION_CONTENT_EMPTY',
          fieldName: 'content',
          invalidValue: note.content,
        );
      }

      // Validate archive-pin invariant
      if (note.isArchived && note.isPinned) {
        throw const ValidationError(
          userMessage: 'A note cannot be both archived and pinned.',
          technicalMessage: 'Invalid state: archived=true, pinned=true',
          errorCode: 'VALIDATION_ARCHIVE_PIN_INVARIANT',
          fieldName: 'state',
          invalidValue: 'archived+pinned',
        );
      }

      await _dataSource.updateNote(note);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      if (id.trim().isEmpty) {
        throw ValidationError(
          userMessage: 'Invalid note ID provided.',
          technicalMessage: 'Empty note ID',
          errorCode: 'VALIDATION_ID_EMPTY',
          fieldName: 'id',
          invalidValue: id,
        );
      }

      await _dataSource.deleteNote(id);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getActive() async {
    try {
      return await _dataSource.getActiveNotes();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getArchived() async {
    try {
      return await _dataSource.getArchivedNotes();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getPinned() async {
    try {
      return await _dataSource.getPinnedNotes();
    } catch (e, stackTrace) {
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }
}
