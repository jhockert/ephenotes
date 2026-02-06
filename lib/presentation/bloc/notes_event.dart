import 'package:equatable/equatable.dart';
import 'package:ephenotes/data/models/note.dart';

/// Base class for all notes-related events.
///
/// All events extend [Equatable] for value comparison in tests.
abstract class NotesEvent extends Equatable {
  const NotesEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notes from storage.
///
/// This is typically fired when the app starts or when
/// the user manually refreshes the notes list.
class LoadNotes extends NotesEvent {
  const LoadNotes();
}

/// Event to refresh notes (pull-to-refresh).
///
/// Similar to [LoadNotes] but may include different UI feedback.
class RefreshNotes extends NotesEvent {
  const RefreshNotes();
}

/// Event to create a new note.
///
/// The [note] parameter contains all the note data including
/// content, color, priority, etc.
class CreateNote extends NotesEvent {
  final Note note;

  const CreateNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to update an existing note.
///
/// The [note] parameter should contain the updated data
/// with the same ID as the original note.
class UpdateNote extends NotesEvent {
  final Note note;

  const UpdateNote(this.note);

  @override
  List<Object?> get props => [note];
}

/// Event to delete a note permanently.
///
/// The [noteId] identifies which note to delete.
class DeleteNote extends NotesEvent {
  final String noteId;

  const DeleteNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to archive a note.
///
/// Archived notes are hidden from the main list but not deleted.
/// If the note is pinned, the pin status will be removed.
class ArchiveNote extends NotesEvent {
  final String noteId;

  const ArchiveNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to unarchive a note.
///
/// Moves a note from the archive back to the active notes list.
class UnarchiveNote extends NotesEvent {
  final String noteId;

  const UnarchiveNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to pin a note to the top.
///
/// Pinned notes appear above all unpinned notes.
/// Only active (non-archived) notes can be pinned.
class PinNote extends NotesEvent {
  final String noteId;

  const PinNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to unpin a note.
///
/// The note will return to its normal position in the list.
class UnpinNote extends NotesEvent {
  final String noteId;

  const UnpinNote(this.noteId);

  @override
  List<Object?> get props => [noteId];
}

/// Event to search notes by content.
///
/// The [query] is matched against note content (case-insensitive).
/// Only searches active (non-archived) notes.
class SearchNotes extends NotesEvent {
  final String query;

  const SearchNotes(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to clear the search query.
///
/// Returns to showing all active notes.
class ClearSearch extends NotesEvent {
  const ClearSearch();
}

/// Event to toggle between viewing active and archived notes.
///
/// When [showArchived] is true, displays archived notes.
/// When false, displays active notes.
class ToggleArchiveView extends NotesEvent {
  final bool showArchived;

  const ToggleArchiveView(this.showArchived);

  @override
  List<Object?> get props => [showArchived];
}
