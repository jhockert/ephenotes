import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/presentation/widgets/swipeable_note_card.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';

/// Screen displaying archived notes.
///
/// Features:
/// - List of archived notes with virtual scrolling
/// - Restore notes back to active list
/// - Permanently delete notes with confirmation
/// - Bulk selection for restore/delete
/// - Performance optimization for large archives
class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _performanceMonitor.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UiStrings.archiveScreenTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return Semantics(
              label: AccessibilityHelper.getLoadingSemanticLabel(),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (state is NotesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    UiStrings.errorPrefix(state.message),
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            );
          }

          if (state is NotesLoaded) {
            // Filter archived notes
            final archivedNotes =
                state.notes.where((note) => note.isArchived).toList();

            if (archivedNotes.isEmpty) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UiStrings.noArchivedNotes,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      UiStrings.swipeToArchive,
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UiStrings.restoreNoteInfo,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            UiStrings.priorityOrder,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Monitor performance for large archives
            if (archivedNotes.length > 100) {
              _performanceMonitor.startNoteListMonitoring(archivedNotes.length);
            }

            return VirtualNoteList(
              notes: archivedNotes,
              onNoteTap: (note) {},
              onNoteLongPress: (note) => _showNoteOptions(context, note),
              customItemBuilder: (note) => SwipeableNoteCard(
                note: note,
                onTap: () {},
                onArchive: (note) => _restoreNote(context, note),
                isRestore: true,
                showMetadata: false,
              ),
              padding: const EdgeInsets.all(8.0),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.unarchive),
                title: const Text(UiStrings.restore),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _restoreNote(context, note);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  UiStrings.deletePermanently,
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(bottomSheetContext).pop();
                  _confirmDelete(context, note);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _restoreNote(BuildContext context, Note note) {
    context.read<NotesBloc>().add(UnarchiveNote(note.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.noteRestored),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Note note) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(UiStrings.deleteNoteTitle),
          content: const Text(UiStrings.deleteNoteContent),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(UiStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteNote(context, note);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(UiStrings.delete),
            ),
          ],
        );
      },
    );
  }

  void _deleteNote(BuildContext context, Note note) {
    context.read<NotesBloc>().add(DeleteNote(note.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.noteDeletedPermanently),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
