import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/datasources/local/note_local_datasource.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:ephenotes/core/error/error_handler.dart';
import 'package:ephenotes/objectbox.g.dart'; // Import generated ObjectBox code

/// ObjectBox implementation of [NoteLocalDataSource].
///
/// Stores notes in an ObjectBox database for fast, local persistence.
/// Includes comprehensive error handling and storage monitoring.
class ObjectBoxNoteDataSource implements NoteLocalDataSource {
  final Store _store;
  late final Box<Note> _noteBox;

  /// Creates an [ObjectBoxNoteDataSource] with the given ObjectBox store.
  ObjectBoxNoteDataSource({required Store store}) : _store = store {
    _noteBox = _store.box<Note>();
  }

  /// Checks if the box is accessible and handles corruption.
  Future<void> _ensureBoxHealth() async {
    try {
      // Try a simple operation to verify box health
      // Note: ObjectBox Store doesn't have an isOpen() method
      // We'll just try to access the box and catch any errors
      final _ = _noteBox.count();
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<List<Note>> getAllNotes() async {
    try {
      await _ensureBoxHealth();
      return _noteBox.getAll();
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<Note> getNoteById(String id) async {
    try {
      await _ensureBoxHealth();

      final query = _noteBox.query(Note_.id.equals(id)).build();
      final note = query.findFirst();
      query.close();

      if (note == null) {
        throw StorageError(
          userMessage: 'The requested note could not be found.',
          technicalMessage: 'Note not found: $id',
          errorCode: 'NOTE_NOT_FOUND',
          storageType: StorageErrorType.ioError,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Refresh',
              description: 'Refresh the notes list',
              action: () async {},
              isPrimary: true,
            ),
          ],
        );
      }

      return note;
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> createNote(Note note) async {
    try {
      await _ensureBoxHealth();

      // Check if note with same ID already exists
      final query = _noteBox.query(Note_.id.equals(note.id)).build();
      final exists = query.findFirst() != null;
      query.close();

      if (exists) {
        throw StorageError(
          userMessage: 'A note with this ID already exists.',
          technicalMessage: 'Duplicate note ID: ${note.id}',
          errorCode: 'DUPLICATE_NOTE_ID',
          storageType: StorageErrorType.ioError,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Generate New ID',
              description: 'Create the note with a new unique ID',
              action: () async {},
              isPrimary: true,
            ),
          ],
        );
      }

      // Check storage space before writing
      await _checkStorageSpace();

      // Put the note (ObjectBox will auto-assign objectBoxId)
      _noteBox.put(note);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> updateNote(Note note) async {
    try {
      await _ensureBoxHealth();

      // Check if note exists
      final query = _noteBox.query(Note_.id.equals(note.id)).build();
      final existingNote = query.findFirst();
      query.close();

      if (existingNote == null) {
        throw StorageError(
          userMessage: 'The note you\'re trying to update no longer exists.',
          technicalMessage: 'Note not found for update: ${note.id}',
          errorCode: 'NOTE_NOT_FOUND_UPDATE',
          storageType: StorageErrorType.ioError,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Create New',
              description: 'Save as a new note instead',
              action: () async {},
              isPrimary: true,
            ),
            ErrorRecoveryAction(
              label: 'Refresh',
              description: 'Refresh and try again',
              action: () async {},
            ),
          ],
        );
      }

      // Check storage space before writing
      await _checkStorageSpace();

      // Update the note (preserve objectBoxId from existing note)
      final updatedNote = note.copyWith(objectBoxId: existingNote.objectBoxId);
      _noteBox.put(updatedNote);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    try {
      await _ensureBoxHealth();

      // Find the note by UUID
      final query = _noteBox.query(Note_.id.equals(id)).build();
      final note = query.findFirst();
      query.close();

      if (note == null) {
        throw StorageError(
          userMessage: 'The note you\'re trying to delete no longer exists.',
          technicalMessage: 'Note not found for deletion: $id',
          errorCode: 'NOTE_NOT_FOUND_DELETE',
          storageType: StorageErrorType.ioError,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Refresh',
              description: 'Refresh the notes list',
              action: () async {},
              isPrimary: true,
            ),
          ],
        );
      }

      // Delete by objectBoxId
      _noteBox.remove(note.objectBoxId);
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getActiveNotes() async {
    try {
      await _ensureBoxHealth();
      final query = _noteBox.query(Note_.isArchived.equals(false)).build();
      final notes = query.find();
      query.close();
      return notes;
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getArchivedNotes() async {
    try {
      await _ensureBoxHealth();
      final query = _noteBox.query(Note_.isArchived.equals(true)).build();
      final notes = query.find();
      query.close();
      return notes;
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  @override
  Future<List<Note>> getPinnedNotes() async {
    try {
      await _ensureBoxHealth();
      final query = _noteBox
          .query(Note_.isPinned.equals(true).and(Note_.isArchived.equals(false)))
          .build();
      final notes = query.find();
      query.close();
      return notes;
    } catch (e, stackTrace) {
      if (e is AppError) rethrow;
      throw ErrorHandler.handleError(e, stackTrace);
    }
  }

  /// Checks available storage space and throws appropriate errors.
  Future<void> _checkStorageSpace() async {
    try {
      // Check if we're approaching limits
      final noteCount = _noteBox.count();

      // Check if we're approaching limits
      if (noteCount >= 1000) {
        throw StorageFullError(
          userMessage:
              'You\'ve reached the maximum of 1000 notes. Please archive or delete some notes.',
          technicalMessage: 'Note limit reached: $noteCount/1000',
          errorCode: 'NOTE_LIMIT_REACHED',
          availableBytes: 0,
          requiredBytes: 1024,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Archive Old Notes',
              description: 'Archive some notes to free up space',
              action: () async {},
              isPrimary: true,
            ),
            ErrorRecoveryAction(
              label: 'Delete Notes',
              description: 'Permanently delete some notes',
              action: () async {},
            ),
          ],
        );
      }

      if (noteCount >= 900) {
        throw StorageFullError(
          userMessage:
              'You\'re approaching the 1000 note limit. Consider archiving old notes.',
          technicalMessage: 'Note limit warning: $noteCount/1000',
          errorCode: 'NOTE_LIMIT_WARNING',
          availableBytes: (1000 - noteCount) * 1024,
          requiredBytes: 1024,
          recoveryActions: [
            ErrorRecoveryAction(
              label: 'Continue',
              description: 'Continue with current operation',
              action: () async {},
              isPrimary: true,
            ),
            ErrorRecoveryAction(
              label: 'Archive Notes',
              description: 'Archive some notes now',
              action: () async {},
            ),
          ],
        );
      }
    } catch (e) {
      if (e is AppError) rethrow;
      // Don't fail operations due to storage check issues
    }
  }
}
