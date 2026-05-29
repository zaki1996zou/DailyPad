import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/models/task_model.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/utils/date_helpers.dart';
import 'package:fc_app3_dailypad/widgets/priority_badge.dart';
import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleComplete,
    this.showCheckbox = true,
  });

  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggleComplete;
  final bool showCheckbox;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: _buildCard(context));
  }

  Widget _buildCard(BuildContext context) {
    final isCompleted = task.isCompleted;
    final dueLabel = DateHelpers.formatDueDate(task.dueDate);
    final isOverdue = !isCompleted && DateHelpers.isBeforeToday(task.dueDate);

    return Material(
      color: AppTheme.cardColor(context),
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showCheckbox)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: GestureDetector(
                    onTap: onToggleComplete,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.completed
                            : Colors.transparent,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.completed
                              : AppColors.primary,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: isCompleted
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title.isEmpty ? 'Untitled task' : task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted
                                ? AppColors.completed
                                : null,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        task.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.secondaryTextColor(context),
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        PriorityBadge(priority: task.priority),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 12,
                          color: isOverdue
                              ? AppColors.error
                              : AppTheme.secondaryTextColor(context),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dueLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: isOverdue
                                ? AppColors.error
                                : AppTheme.secondaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
