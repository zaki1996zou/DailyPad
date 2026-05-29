import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/models/note_model.dart';
import 'package:fc_app3_dailypad/models/task_model.dart';
import 'package:fc_app3_dailypad/providers/notes_provider.dart';
import 'package:fc_app3_dailypad/providers/tasks_provider.dart';
import 'package:fc_app3_dailypad/screens/add_edit_note_screen.dart';
import 'package:fc_app3_dailypad/screens/add_edit_task_screen.dart';
import 'package:fc_app3_dailypad/screens/main_shell.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/utils/date_helpers.dart';
import 'package:fc_app3_dailypad/utils/debouncer.dart';
import 'package:fc_app3_dailypad/widgets/empty_state.dart';
import 'package:fc_app3_dailypad/widgets/note_card.dart';
import 'package:fc_app3_dailypad/widgets/search_text_field.dart';
import 'package:fc_app3_dailypad/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _searchDebouncer = Debouncer();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  void _openAddNote() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddEditNoteScreen()),
    );
  }

  void _openAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _openEditNote(Note note) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditNoteScreen(note: note),
      ),
    );
  }

  void _openEditTask(Task task) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AddEditTaskScreen(task: task),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;

    return SafeArea(
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateHelpers.greeting(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.secondaryTextColor(context),
                        ),
                  ),
                  Text(
                    AppStrings.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SearchTextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    onClear: () => setState(() => _searchQuery = ''),
                  ),
                  if (!isSearching) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.note_add_outlined,
                            label: 'New Note',
                            color: AppColors.primary,
                            onTap: _openAddNote,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_task,
                            label: 'New Task',
                            color: AppColors.secondary,
                            onTap: _openAddTask,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (isSearching)
            Selector<NotesProvider, List<Note>>(
              selector: (_, p) => p.searchNotes(_searchQuery),
              builder: (context, searchResults, _) {
                if (searchResults.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      icon: Icons.search_off,
                      title: 'No results found',
                      subtitle: 'Try a different search term',
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = searchResults[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: NoteCard(
                          key: ValueKey(note.id),
                          note: note,
                          onTap: () => _openEditNote(note),
                        ),
                      );
                    },
                    childCount: searchResults.length,
                  ),
                );
              },
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Notes',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .findAncestorStateOfType<MainShellState>()
                            ?.switchToTab(1);
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            Selector<NotesProvider, List<Note>>(
              selector: (_, p) => p.recentNotes,
              builder: (context, recentNotes, _) {
                if (recentNotes.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 140,
                      child: EmptyState(
                        icon: Icons.note_outlined,
                        title: 'No notes yet',
                        subtitle: 'Create your first note',
                        compact: true,
                      ),
                    ),
                  );
                }
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: 130,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      itemCount: recentNotes.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        final note = recentNotes[index];
                        return NoteCard(
                          key: ValueKey(note.id),
                          note: note,
                          compact: true,
                          onTap: () => _openEditNote(note),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .findAncestorStateOfType<MainShellState>()
                            ?.switchToTab(2);
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            Selector<TasksProvider, List<Task>>(
              selector: (_, p) => p.todayTasksForHome,
              builder: (context, todayTasks, _) {
                if (todayTasks.isEmpty) {
                  return SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: EmptyState(
                        icon: Icons.task_outlined,
                        title: 'No tasks for today',
                        subtitle: 'Add a task due today or overdue',
                        compact: true,
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = todayTasks[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: TaskCard(
                          key: ValueKey(task.id),
                          task: task,
                          onTap: () => _openEditTask(task),
                          onToggleComplete: () => context
                              .read<TasksProvider>()
                              .toggleCompleted(task.id),
                        ),
                      );
                    },
                    childCount: todayTasks.length,
                  ),
                );
              },
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
          ],
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
