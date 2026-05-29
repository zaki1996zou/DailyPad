import 'package:fc_app3_dailypad/models/note_model.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    this.category,
    this.isSelected = false,
    this.onTap,
    this.showAll = false,
  }) : assert(showAll || category != null);

  final NoteCategory? category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final label = showAll ? 'All' : category!.label;
    final color = showAll ? AppColors.primary : category!.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : color.withValues(alpha: 0.9),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
