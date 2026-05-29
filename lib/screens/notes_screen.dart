import 'package:fc_app3_dailypad/models/note_model.dart';
import 'package:fc_app3_dailypad/providers/notes_provider.dart';
import 'package:fc_app3_dailypad/screens/add_edit_note_screen.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/utils/debouncer.dart';
import 'package:fc_app3_dailypad/widgets/category_chip.dart';
import 'package:fc_app3_dailypad/widgets/empty_state.dart';
import 'package:fc_app3_dailypad/widgets/note_card.dart';
import 'package:fc_app3_dailypad/widgets/search_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  bool _isGridView = false;

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      if (mounted) {
        context.read<NotesProvider>().setSearchQuery(value);
      }
    });
  }

  void _openAddNote() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddEditNoteScreen()),
    );
  }

  void _openEditNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: _isGridView ? 'List view' : 'Grid view',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'notes_fab',
        onPressed: _openAddNote,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SearchTextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: () =>
                  context.read<NotesProvider>().setSearchQuery(''),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Selector<NotesProvider, NoteCategory?>(
            selector: (_, p) => p.categoryFilter,
            builder: (context, selectedCategory, _) {
              return SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: [
                    CategoryChip(
                      showAll: true,
                      isSelected: selectedCategory == null,
                      onTap: () =>
                          context.read<NotesProvider>().setCategoryFilter(null),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ...NoteCategory.values.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: CategoryChip(
                          category: category,
                          isSelected: selectedCategory == category,
                          onTap: () {
                            context.read<NotesProvider>().setCategoryFilter(
                                  selectedCategory == category
                                      ? null
                                      : category,
                                );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: Selector<NotesProvider, _NotesListData>(
              selector: (_, p) => _NotesListData(
                notes: p.filteredNotes,
                searchQuery: p.searchQuery,
                categoryFilter: p.categoryFilter,
              ),
              shouldRebuild: (prev, next) => prev != next,
              builder: (context, data, _) {
                if (data.notes.isEmpty) {
                  return EmptyState(
                    icon: Icons.note_outlined,
                    title: 'No notes yet',
                    subtitle: data.searchQuery.isNotEmpty ||
                            data.categoryFilter != null
                        ? 'Try adjusting your search or filters'
                        : 'Tap + to create your first note',
                    actionLabel: data.searchQuery.isEmpty &&
                            data.categoryFilter == null
                        ? 'Create Note'
                        : null,
                    onAction: data.searchQuery.isEmpty &&
                            data.categoryFilter == null
                        ? _openAddNote
                        : null,
                  );
                }

                if (_isGridView) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: data.notes.length,
                    itemBuilder: (context, index) {
                      final note = data.notes[index];
                      return NoteCard(
                        key: ValueKey(note.id),
                        note: note,
                        onTap: () => _openEditNote(note),
                      );
                    },
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: data.notes.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    final note = data.notes[index];
                    return NoteCard(
                      key: ValueKey(note.id),
                      note: note,
                      onTap: () => _openEditNote(note),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class _NotesListData {
  const _NotesListData({
    required this.notes,
    required this.searchQuery,
    required this.categoryFilter,
  });

  final List<Note> notes;
  final String searchQuery;
  final NoteCategory? categoryFilter;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _NotesListData &&
        other.searchQuery == searchQuery &&
        other.categoryFilter == categoryFilter &&
        _listEquals(other.notes, notes);
  }

  @override
  int get hashCode => Object.hash(
        searchQuery,
        categoryFilter,
        Object.hashAll(notes.map((n) => n.id)),
      );

  static bool _listEquals(List<Note> a, List<Note> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].updatedAt != b[i].updatedAt) {
        return false;
      }
    }
    return true;
  }
}
