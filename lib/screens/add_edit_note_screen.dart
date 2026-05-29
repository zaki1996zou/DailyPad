import 'package:fc_app3_dailypad/app/theme.dart';
import 'package:fc_app3_dailypad/models/note_model.dart';
import 'package:fc_app3_dailypad/providers/notes_provider.dart';
import 'package:fc_app3_dailypad/utils/constants.dart';
import 'package:fc_app3_dailypad/widgets/category_chip.dart';
import 'package:fc_app3_dailypad/widgets/custom_button.dart';
import 'package:fc_app3_dailypad/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddEditNoteScreen extends StatefulWidget {
  const AddEditNoteScreen({super.key, this.note});

  final Note? note;

  bool get isEditing => note != null;

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late NoteCategory _category;
  late bool _isFavorite;
  late bool _isPinned;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _category = note?.category ?? NoteCategory.personal;
    _isFavorite = note?.isFavorite ?? false;
    _isPinned = note?.isPinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a note title')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final provider = context.read<NotesProvider>();
    final content = _contentController.text.trim();

    try {
      if (widget.isEditing) {
        final note = widget.note!;
        note.title = title;
        note.content = content;
        note.category = _category;
        note.isFavorite = _isFavorite;
        note.isPinned = _isPinned;
        await provider.updateNote(note);
      } else {
        await provider.addNote(
          title: title,
          content: content,
          category: _category,
          isFavorite: _isFavorite,
          isPinned: _isPinned,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
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
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This cannot be undone.',
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

    if (confirmed == true && widget.note != null && mounted) {
      await context.read<NotesProvider>().deleteNote(widget.note!.id);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Note' : 'New Note'),
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
              hint: 'Note title',
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              controller: _contentController,
              label: 'Content',
              hint: 'Write your note...',
              maxLines: 8,
              minLines: 4,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Category',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: NoteCategory.values.map((category) {
                return CategoryChip(
                  category: category,
                  isSelected: _category == category,
                  onTap: () => setState(() => _category = category),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ToggleTile(
              icon: Icons.star_outline,
              activeIcon: Icons.star,
              title: 'Favorite',
              subtitle: 'Mark as favorite for quick access',
              value: _isFavorite,
              activeColor: AppColors.warning,
              onChanged: (v) => setState(() => _isFavorite = v),
            ),
            _ToggleTile(
              icon: Icons.push_pin_outlined,
              activeIcon: Icons.push_pin,
              title: 'Pin Note',
              subtitle: 'Keep this note at the top',
              value: _isPinned,
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() => _isPinned = v),
            ),
            const SizedBox(height: AppSpacing.xl),
            CustomButton(
              label: _isSaving ? 'Saving...' : 'Save Note',
              onPressed: _isSaving ? () {} : _save,
              icon: Icons.check,
              width: double.infinity,
            ),
            if (widget.isEditing) ...[
              const SizedBox(height: AppSpacing.md),
              CustomButton(
                label: 'Delete Note',
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

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.activeIcon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final IconData icon;
  final IconData activeIcon;
  final String title;
  final String subtitle;
  final bool value;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppTheme.cardColor(context),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: SwitchListTile(
        secondary: Icon(
          value ? activeIcon : icon,
          color: value ? activeColor : AppTheme.secondaryTextColor(context),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondaryTextColor(context),
          ),
        ),
        value: value,
        activeTrackColor: activeColor.withValues(alpha: 0.45),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return activeColor;
          return null;
        }),
        onChanged: onChanged,
      ),
    );
  }
}
