import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/core/utils/accessibility_helper.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/bloc/notes_event.dart';
import 'package:ephenotes/presentation/bloc/settings_cubit.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import 'package:ephenotes/presentation/screens/archive_screen.dart';
import 'package:ephenotes/presentation/screens/search_screen.dart';
import 'package:ephenotes/presentation/widgets/swipeable_note_card.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/presentation/widgets/error_display_widget.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';
import 'package:ephenotes/core/error/app_error.dart';

/// Main screen displaying the list of notes.
///
/// Features:
/// - Floating action button to create new notes
/// - ListView of note cards with priority-based sorting
/// - Search functionality
/// - Archive navigation
/// - Pin/unpin functionality
class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();

  @override
  void initState() {
    super.initState();
    _performanceMonitor.initialize();
  }

  // Age-based grouping removed per SPEC: Notes are always shown as a flat list (pinned first, then unpinned sorted by date).

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(UiStrings.appTitle),
        actions: [
          BlocBuilder<SettingsCubit, ThemeMode>(
            builder: (context, themeMode) {
              return Semantics(
                label:
                    AccessibilityHelper.getThemeToggleSemanticLabel(themeMode),
                button: true,
                child: IconButton(
                  icon: Icon(_getThemeIcon(themeMode)),
                  tooltip: _getThemeTooltip(themeMode),
                  onPressed: () {
                    context.read<SettingsCubit>().cycleThemeMode();
                  },
                ),
              );
            },
          ),
          Semantics(
            label: UiStrings.searchNotesLabel,
            hint: UiStrings.searchNotesHint,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _navigateToSearch(context),
            ),
          ),
          Semantics(
            label: UiStrings.archiveLabel,
            hint: UiStrings.archiveHint,
            button: true,
            child: IconButton(
              icon: const Icon(Icons.archive_outlined),
              onPressed: () => _navigateToArchive(context),
            ),
          ),
        ],
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
            return ErrorDisplayWidget(
              errorState: state,
              onRecoveryAction: (action) =>
                  _handleErrorRecovery(context, action, state),
              showDetails: false, // Set to true for debugging
            );
          }

          if (state is NotesLoaded) {
            // Filter active notes (non-archived)
            final activeNotes =
                state.notes.where((note) => !note.isArchived).toList();

            if (activeNotes.isEmpty) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Semantics(
                label: AccessibilityHelper.getEmptyStateSemanticLabel(),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.note_add_outlined,
                        size: 64,
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        UiStrings.noNotesYet,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        UiStrings.createFirstNote,
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
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
                            color:
                                isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.sort,
                              size: 20,
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              UiStrings.priorityOrganizer,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              UiStrings.priorityOrder,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? Colors.grey[500]
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Use priority-based sorting for active notes
            final allNotes = NoteSorting.sortByPriority(activeNotes);

            // Start performance monitoring for large lists
            if (allNotes.length > 100) {
              _performanceMonitor.startNoteListMonitoring(allNotes.length);
            }

            return _buildOptimizedList(allNotes);
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: Semantics(
        label: AccessibilityHelper.getFabSemanticLabel(),
        hint: UiStrings.createNoteHint,
        button: true,
        child: FloatingActionButton(
          onPressed: () => _createNote(context),
          tooltip: UiStrings.createNoteTooltip,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  /// Builds an optimized list using virtual scrolling for large collections.
  Widget _buildOptimizedList(List<Note> notes) {
    return VirtualNoteList(
      notes: notes,
      onNoteTap: (note) => _editNote(context, note),
      onNoteLongPress: (note) => _showNoteOptions(context, note),
      customItemBuilder: (note) => _buildNoteItem(note),
      padding: const EdgeInsets.all(8.0),
    );
  }

  // Age-based grouping and group headers have been removed per SPEC. Rendering is handled by `_buildFlatList` and `_buildNoteItem`.

  /// Builds a single note item with swipe-to-archive and long-press menu.
  ///
  /// Implements 50% swipe threshold as per US-1.3: Archive with Undo Safety.
  /// Visual feedback includes opacity changes during swipe progress.
  Widget _buildNoteItem(Note note) {
    return SwipeableNoteCard(
      note: note,
      onTap: () => _editNote(context, note),
      onArchive: (note) => _archiveNote(context, note),
    );
  }

  void _createNote(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesBloc>(),
          child: const NoteEditorScreen(),
        ),
      ),
    );
  }

  void _editNote(BuildContext context, Note note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesBloc>(),
          child: NoteEditorScreen(note: note),
        ),
      ),
    );
  }

  void _navigateToSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesBloc>(),
          child: const SearchScreen(),
        ),
      ),
    );
  }

  void _navigateToArchive(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NotesBloc>(),
          child: const ArchiveScreen(),
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    HapticFeedback.selectionClick();

    showModalBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return Semantics(
          label: UiStrings.noteOptionsMenuLabel,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!note.isPinned)
                  Semantics(
                    label: AccessibilityHelper.getPinActionSemanticLabel(
                        note.isPinned),
                    button: true,
                    child: ListTile(
                      leading: const Icon(Icons.push_pin),
                      title: const Text(UiStrings.pin),
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop();
                        _pinNote(context, note);
                      },
                    ),
                  ),
                if (note.isPinned)
                  Semantics(
                    label: AccessibilityHelper.getPinActionSemanticLabel(
                        note.isPinned),
                    button: true,
                    child: ListTile(
                      leading: const Icon(Icons.push_pin_outlined),
                      title: const Text(UiStrings.unpin),
                      onTap: () {
                        Navigator.of(bottomSheetContext).pop();
                        _unpinNote(context, note);
                      },
                    ),
                  ),
                Semantics(
                  label: AccessibilityHelper.getArchiveActionSemanticLabel(),
                  button: true,
                  child: ListTile(
                    leading: const Icon(Icons.archive),
                    title: const Text(UiStrings.archive),
                    onTap: () {
                      Navigator.of(bottomSheetContext).pop();
                      _archiveNote(context, note);
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pinNote(BuildContext context, Note note) {
    HapticFeedback.selectionClick();
    context.read<NotesBloc>().add(PinNote(note.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.notePinned),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _unpinNote(BuildContext context, Note note) {
    context.read<NotesBloc>().add(UnpinNote(note.id));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(UiStrings.noteUnpinned),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _archiveNote(BuildContext context, Note note) {
    // Archive the note
    context.read<NotesBloc>().add(ArchiveNote(note.id));

    // Show undo snackbar with 3 second duration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(UiStrings.noteArchived),
        action: SnackBarAction(
          label: UiStrings.undo,
          onPressed: () {
            // Unarchive the note
            HapticFeedback.mediumImpact();
            context.read<NotesBloc>().add(UnarchiveNote(note.id));
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => Icons.brightness_auto,
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
    };
  }

  String _getThemeTooltip(ThemeMode themeMode) {
    return switch (themeMode) {
      ThemeMode.system => UiStrings.themeSystem,
      ThemeMode.light => UiStrings.themeLight,
      ThemeMode.dark => UiStrings.themeDark,
    };
  }

  /// Handles error recovery actions.
  void _handleErrorRecovery(
      BuildContext context, ErrorRecoveryAction action, NotesError errorState) {
    switch (action.label.toLowerCase()) {
      case 'retry':
        // Retry the last operation by reloading notes
        context.read<NotesBloc>().add(const LoadNotes());
        break;
      case 'refresh':
        // Same as retry for now
        context.read<NotesBloc>().add(const LoadNotes());
        break;
      case 'recover data':
        // Show recovery dialog
        _showDataRecoveryDialog(context);
        break;
      case 'free up space':
        // Navigate to archive screen to help user free up space
        _navigateToArchive(context);
        break;
      case 'archive old notes':
        // Navigate to archive screen
        _navigateToArchive(context);
        break;
      case 'check permissions':
        // Show permission help dialog
        _showPermissionHelpDialog(context);
        break;
      case 'get help':
        // Show help dialog
        _showHelpDialog(context, errorState);
        break;
      default:
        // Execute the action's default behavior
        action.action();
        break;
    }
  }

  /// Shows a data recovery dialog.
  void _showDataRecoveryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiStrings.dataRecoveryTitle),
        content: const Text(UiStrings.dataRecoveryContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(UiStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Trigger recovery by reloading
              context.read<NotesBloc>().add(const LoadNotes());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(UiStrings.attemptingDataRecovery),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            child: const Text(UiStrings.recover),
          ),
        ],
      ),
    );
  }

  /// Shows a permission help dialog.
  void _showPermissionHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiStrings.storagePermissionTitle),
        content: const Text(UiStrings.storagePermissionContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(UiStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // In a real app, this would open system settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(UiStrings.checkPermissions),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text(UiStrings.openSettings),
          ),
        ],
      ),
    );
  }

  /// Shows a general help dialog.
  void _showHelpDialog(BuildContext context, NotesError errorState) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(UiStrings.needHelpTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(UiStrings.errorPrefix(errorState.message)),
            const SizedBox(height: 16),
            const Text(UiStrings.tryTheseSteps),
            const SizedBox(height: 8),
            const Text(UiStrings.helpRestartApp),
            const Text(UiStrings.helpCheckStorage),
            const Text(UiStrings.helpUpdateApp),
            const SizedBox(height: 16),
            const Text(UiStrings.helpAutoResolve),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(UiStrings.ok),
          ),
        ],
      ),
    );
  }
}
