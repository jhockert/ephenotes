import 'package:equatable/equatable.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/error/app_error.dart';

/// Base class for all notes-related states.
///
/// All states extend [Equatable] for value comparison in BLoC.
abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any notes are loaded.
///
/// This is the state when the BLoC is first created.
class NotesInitial extends NotesState {
  const NotesInitial();
}

/// State when notes are being loaded from storage.
///
/// UI should show a loading indicator.
class NotesLoading extends NotesState {
  const NotesLoading();
}

/// State when notes have been successfully loaded.
///
/// Contains the list of notes to display and optional search query.
class NotesLoaded extends NotesState {
  /// All notes currently being displayed.
  final List<Note> notes;

  /// Current search query, if any.
  final String? searchQuery;

  /// Whether currently viewing archived notes.
  final bool showingArchived;

  /// Timestamp of last update (for pull-to-refresh).
  final DateTime lastUpdated;

  const NotesLoaded({
    required this.notes,
    this.searchQuery,
    this.showingArchived = false,
    required this.lastUpdated,
  });

  /// Factory constructor for convenience with optional lastUpdated.
  factory NotesLoaded.create({
    required List<Note> notes,
    String? searchQuery,
    bool showingArchived = false,
    DateTime? lastUpdated,
  }) {
    return NotesLoaded(
      notes: notes,
      searchQuery: searchQuery,
      showingArchived: showingArchived,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// Creates a copy with updated fields.
  NotesLoaded copyWith({
    List<Note>? notes,
    String? searchQuery,
    bool? showingArchived,
    DateTime? lastUpdated,
    bool clearSearch = false,
  }) {
    return NotesLoaded(
      notes: notes ?? this.notes,
      searchQuery: clearSearch ? null : (searchQuery ?? this.searchQuery),
      showingArchived: showingArchived ?? this.showingArchived,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [notes, searchQuery, showingArchived, lastUpdated];
}

/// State when an error occurs.
///
/// Contains the error message to display to the user and recovery actions.
class NotesError extends NotesState {
  /// User-friendly error message.
  final String message;

  /// Original error for debugging (optional).
  final Object? error;

  /// Stack trace for debugging (optional).
  final StackTrace? stackTrace;

  /// Type of error that occurred.
  final NotesErrorType type;

  /// Available recovery actions for the user.
  final List<ErrorRecoveryAction> recoveryActions;

  const NotesError({
    required this.message,
    this.error,
    this.stackTrace,
    this.type = NotesErrorType.unknown,
    this.recoveryActions = const [],
  });

  /// Whether this error has recovery actions available.
  bool get hasRecoveryActions => recoveryActions.isNotEmpty;

  /// Gets the primary recovery action, if any.
  ErrorRecoveryAction? get primaryRecoveryAction {
    try {
      return recoveryActions.firstWhere((action) => action.isPrimary);
    } catch (e) {
      return recoveryActions.isNotEmpty ? recoveryActions.first : null;
    }
  }

  @override
  List<Object?> get props =>
      [message, error, stackTrace, type, recoveryActions];
}

/// Types of errors that can occur.
enum NotesErrorType {
  /// Error related to storage/database.
  storage,

  /// Error related to user input validation.
  validation,

  /// Error related to network connectivity.
  network,

  /// Unknown or unexpected error.
  unknown,
}
