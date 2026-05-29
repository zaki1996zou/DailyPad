import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/models/task_model.dart';
import 'package:fc_app3_dailypad/providers/tasks_provider.dart';
import 'package:fc_app3_dailypad/screens/add_edit_task_screen.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/widgets/empty_state.dart';
import 'package:fc_app3_dailypad/widgets/task_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _openAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AddEditTaskScreen()),
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
    final provider = context.watch<TasksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppTheme.secondaryTextColor(context),
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'Today (${provider.todayTasks.length})'),
            Tab(text: 'Upcoming (${provider.upcomingTasks.length})'),
            Tab(text: 'Done (${provider.completedTasks.length})'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'tasks_fab',
        onPressed: _openAddTask,
        child: const Icon(Icons.add),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TaskList(
            tasks: provider.todayTasks,
            emptyIcon: Icons.today_outlined,
            emptyTitle: 'No tasks for today',
            emptySubtitle: 'Add a task with today as the due date',
            onAdd: _openAddTask,
            onEdit: _openEditTask,
            onToggle: provider.toggleCompleted,
          ),
          _TaskList(
            tasks: provider.upcomingTasks,
            emptyIcon: Icons.upcoming_outlined,
            emptyTitle: 'No upcoming tasks',
            emptySubtitle: 'Tasks with future due dates appear here',
            onAdd: _openAddTask,
            onEdit: _openEditTask,
            onToggle: provider.toggleCompleted,
          ),
          _TaskList(
            tasks: provider.completedTasks,
            emptyIcon: Icons.check_circle_outline,
            emptyTitle: 'No completed tasks',
            emptySubtitle: 'Completed tasks will appear here',
            onAdd: _openAddTask,
            onEdit: _openEditTask,
            onToggle: provider.toggleCompleted,
          ),
        ],
      ),
    );
  }
}

class _TaskList extends StatelessWidget {
  const _TaskList({
    required this.tasks,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
  });

  final List<Task> tasks;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;
  final VoidCallback onAdd;
  final void Function(Task task) onEdit;
  final Future<void> Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
        actionLabel: 'Add Task',
        onAction: onAdd,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: tasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () => onEdit(task),
          onToggleComplete: () => onToggle(task.id),
        );
      },
    );
  }
}
