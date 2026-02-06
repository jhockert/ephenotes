import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/data/repositories/note_repository.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/core/error/app_error.dart';
import 'package:ephenotes/core/error/error_handler.dart';

/// BLoC for managing notes state and business logic.
///
/// Handles all note operations including CRUD, search, archive,
/// and pin/unpin. Uses [NoteRepository] for data access.
class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NoteRepository _repository;

  /// List of all notes currently loaded (before search filtering).
  List<Note> _allNotes = [];

  NotesBloc({required NoteRepository repository})
      : _repository = repository,
        super(const NotesInitial()) {
    on<LoadNotes>(_onLoadNotes);
    on<RefreshNotes>(_onRefreshNotes);
    on<CreateNote>(_onCreateNote);
    on<UpdateNote>(_onUpdateNote);
    on<DeleteNote>(_onDeleteNote);
    on<ArchiveNote>(_onArchiveNote);
    on<UnarchiveNote>(_onUnarchiveNote);
    on<PinNote>(_onPinNote);
    on<UnpinNote>(_onUnpinNote);
    on<SearchNotes>(_onSearchNotes);
    on<ClearSearch>(_onClearSearch);
    on<ToggleArchiveView>(_onToggleArchiveView);
  }

  /// Loads all notes from the repository (both active and archived).
  Future<void> _onLoadNotes(
    LoadNotes event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    try {
      final notes = await _repository.getAll(); // Load ALL notes, not just active
      _allNotes = notes;
      emit(NotesLoaded(
        notes: notes,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Refreshes the notes list (same as LoadNotes but for pull-to-refresh).
  Future<void> _onRefreshNotes(
    RefreshNotes event,
    Emitter<NotesState> emit,
  ) async {
    // Refresh is the same as loading for now
    add(const LoadNotes());
  }

  /// Creates a new note.
  Future<void> _onCreateNote(
    CreateNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.create(event.note);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Updates an existing note.
  Future<void> _onUpdateNote(
    UpdateNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.update(event.note);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Deletes a note permanently.
  Future<void> _onDeleteNote(
    DeleteNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      await _repository.delete(event.noteId);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Archives a note by setting isArchived to true.
  ///
  /// If the note is pinned, the pin status will be removed.
  Future<void> _onArchiveNote(
    ArchiveNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    try {
      final note = await _repository.getById(event.noteId);
      final archivedNote = note.copyWith(
        isArchived: true,
        isPinned: false, // Remove pin when archiving
      );
      await _repository.update(archivedNote);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Unarchives a note by setting isArchived to false.
  Future<void> _onUnarchiveNote(
    UnarchiveNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    try {
      final note = await _repository.getById(event.noteId);
      final unarchivedNote = note.copyWith(isArchived: false);
      await _repository.update(unarchivedNote);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Pins a note by setting isPinned to true.
  ///
  /// If the note is archived, it will be unarchived to maintain the invariant
  /// that notes cannot be both archived and pinned.
  Future<void> _onPinNote(
    PinNote event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    try {
      final note = await _repository.getById(event.noteId);
      final pinnedNote = note.copyWith(
        isPinned: true,
        isArchived: false, // Unarchive when pinning to maintain invariant
      );
      await _repository.update(pinnedNote);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Unpins a note by setting isPinned to false.
  Future<void> _onUnpinNote(
    UnpinNote event,
    Emitter<NotesState> emit,
  ) async {
    try {
      final note = await _repository.getById(event.noteId);
      final unpinnedNote = note.copyWith(isPinned: false);
      await _repository.update(unpinnedNote);
      // Reload notes to reflect the change
      add(const LoadNotes());
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Searches notes by content (case-insensitive).
  ///
  /// Only works when in NotesLoaded state. Filters the current notes list.
  void _onSearchNotes(
    SearchNotes event,
    Emitter<NotesState> emit,
  ) {
    final currentState = state;
    if (currentState is! NotesLoaded) {
      // Can't search if notes aren't loaded
      return;
    }

    // If _allNotes is empty, use current state notes as the source
    if (_allNotes.isEmpty && currentState.notes.isNotEmpty) {
      _allNotes = currentState.notes;
    }

    final query = event.query.toLowerCase();
    final filteredNotes = query.isEmpty
        ? _allNotes
        : _allNotes.where((note) {
            return note.content.toLowerCase().contains(query);
          }).toList();

    emit(currentState.copyWith(
      notes: filteredNotes,
      searchQuery: event.query,
    ));
  }

  /// Clears the search query and shows all notes.
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<NotesState> emit,
  ) async {
    // Reload to clear search
    add(const LoadNotes());
  }

  /// Toggles between viewing active and archived notes.
  Future<void> _onToggleArchiveView(
    ToggleArchiveView event,
    Emitter<NotesState> emit,
  ) async {
    emit(const NotesLoading());

    try {
      final notes = event.showArchived
          ? await _repository.getArchived()
          : await _repository.getActive();

      _allNotes = notes;

      emit(NotesLoaded(
        notes: notes,
        showingArchived: event.showArchived,
        lastUpdated: DateTime.now(),
      ));
    } catch (e, stackTrace) {
      final appError =
          e is AppError ? e : ErrorHandler.handleError(e, stackTrace);
      emit(NotesError(
        message: appError.userMessage,
        error: appError,
        stackTrace: stackTrace,
        type: _mapErrorType(appError),
        recoveryActions: appError.recoveryActions,
      ));
    }
  }

  /// Maps [AppError] types to [NotesErrorType].
  NotesErrorType _mapErrorType(AppError error) {
    return switch (error) {
      ValidationError _ => NotesErrorType.validation,
      StorageError _ ||
      DatabaseCorruptionError _ ||
      StorageFullError _ =>
        NotesErrorType.storage,
      NetworkError _ => NotesErrorType.network,
      _ => NotesErrorType.unknown,
    };
  }
}
