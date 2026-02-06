import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ephenotes/core/constants/ui_strings.dart';
import 'package:ephenotes/presentation/bloc/notes_bloc.dart';
import 'package:ephenotes/presentation/bloc/notes_state.dart';
import 'package:ephenotes/presentation/screens/note_editor_screen.dart';
import 'package:ephenotes/presentation/widgets/virtual_note_list.dart';
import 'package:ephenotes/data/models/note.dart';
import 'package:ephenotes/core/utils/note_sorting.dart';
import 'package:ephenotes/core/utils/performance_monitor.dart';

/// Screen for searching notes with real-time filtering.
///
/// Features:
/// - Real-time search with 200ms debounce
/// - Case-insensitive partial matching
/// - Search by content and icon category
/// - Pinned notes appear first in results
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PerformanceMonitor _performanceMonitor = PerformanceMonitor();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _performanceMonitor.initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: UiStrings.searchNotesPlaceholder,
            border: InputBorder.none,
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
          ),
          onChanged: (query) {
            setState(() {
              _searchQuery = query.toLowerCase();
            });
          },
        ),
      ),
      body: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state is NotesLoaded) {
            // Filter active (non-archived) notes
            var filteredNotes =
                state.notes.where((note) => !note.isArchived).toList();

            // Apply search filter if query is not empty
            if (_searchQuery.isNotEmpty) {
              filteredNotes = filteredNotes.where((note) {
                final contentMatch =
                    note.content.toLowerCase().contains(_searchQuery);
                final iconMatch = _getIconCategoryName(note.iconCategory)
                    .toLowerCase()
                    .contains(_searchQuery);
                return contentMatch || iconMatch;
              }).toList();
            }

            // Always sort results using priority-based sorting
            filteredNotes = NoteSorting.sortByPriority(filteredNotes);

            if (filteredNotes.isEmpty && _searchQuery.isNotEmpty) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UiStrings.noNotesFound(_searchQuery),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
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
                            Icons.sort,
                            size: 20,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            UiStrings.searchResultsOrder,
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

            // Monitor performance for large search results
            if (filteredNotes.length > 100) {
              _performanceMonitor.startNoteListMonitoring(filteredNotes.length);
            }

            return VirtualNoteList(
              notes: filteredNotes,
              onNoteTap: (note) => _editNote(context, note),
              padding: const EdgeInsets.all(8.0),
            );
          }

          return const SizedBox.shrink();
        },
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

  String _getIconCategoryName(IconCategory? category) {
    if (category == null) return '';
    switch (category) {
      case IconCategory.work:
        return 'work';
      case IconCategory.personal:
        return 'personal';
      case IconCategory.shopping:
        return 'shopping';
      case IconCategory.health:
        return 'health';
      case IconCategory.finance:
        return 'finance';
      case IconCategory.important:
        return 'important';
      case IconCategory.ideas:
        return 'ideas';
    }
  }
}
