import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/models/task_model.dart';
import 'package:fc_app3_dailypad/providers/tasks_provider.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/widgets/custom_button.dart';
import 'package:fc_app3_dailypad/widgets/custom_text_field.dart';
import 'package:fc_app3_dailypad/widgets/priority_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddEditTaskScreen extends StatefulWidget {
  const AddEditTaskScreen({super.key, this.task});

  final Task? task;

  bool get isEditing => task != null;

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  DateTime? _dueDate;
  late TaskPriority _priority;
  late bool _isCompleted;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController =
        TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    _priority = task?.priority ?? TaskPriority.medium;
    _isCompleted = task?.isCompleted ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<TasksProvider>();
    final description = _descriptionController.text.trim();

    try {
      if (widget.isEditing) {
        final task = widget.task!;
        task.title = title;
        task.description = description;
        task.dueDate = _dueDate;
        task.priority = _priority;
        task.isCompleted = _isCompleted;
        await provider.updateTask(task);
      } else {
        await provider.addTask(
          title: title,
          description: description,
          dueDate: _dueDate,
          priority: _priority,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save task: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this task? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.task != null && mounted) {
      await context.read<TasksProvider>().deleteTask(widget.task!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueDateLabel = _dueDate != null
        ? DateFormat('MMM d, yyyy').format(_dueDate!)
        : 'No due date set';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          if (widget.isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Title',
              hint: 'Task title',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Add details (optional)',
              maxLines: 4,
              minLines: 2,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Due Date',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: AppTheme.cardColor(context),
              borderRadius: BorderRadius.circular(AppRadius.button),
              child: InkWell(
                onTap: _pickDueDate,
                borderRadius: BorderRadius.circular(AppRadius.button),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: AppColors.primary),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          dueDateLabel,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      if (_dueDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _dueDate = null),
                        ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: TaskPriority.values.map((priority) {
                final isSelected = _priority == priority;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: priority != TaskPriority.high ? AppSpacing.sm : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = priority),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? priority.color.withValues(alpha: 0.2)
                              : AppTheme.cardColor(context),
                          borderRadius:
                              BorderRadius.circular(AppRadius.button),
                          border: Border.all(
                            color: isSelected
                                ? priority.color
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            PriorityBadge(priority: priority),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: SwitchListTile(
                  title: const Text('Completed'),
                  subtitle: Text(
                    'Mark this task as done',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryTextColor(context),
                    ),
                  ),
                  value: _isCompleted,
                  activeThumbColor: AppColors.success,
                  onChanged: (v) => setState(() => _isCompleted = v),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              label: _isSaving ? 'Saving...' : 'Save Task',
              onPressed: _isSaving ? () {} : _save,
              icon: Icons.check,
              width: double.infinity,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                label: 'Delete Task',
                onPressed: _delete,
                isOutlined: true,
                isDestructive: true,
                width: double.infinity,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
