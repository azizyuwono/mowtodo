import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/todo.dart';

class AddTodoInput extends StatefulWidget {
  final Function(String, {String? description, Priority priority}) onAdd;

  const AddTodoInput({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddTodoInput> createState() => _AddTodoInputState();
}

class _AddTodoInputState extends State<AddTodoInput> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Priority _selectedPriority = Priority.medium;
  bool _showDescription = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    widget.onAdd(
      title,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      priority: _selectedPriority,
    );

    _titleController.clear();
    _descriptionController.clear();
    _selectedPriority = Priority.medium;
    _showDescription = false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    hintText: 'Add a new task...',
                    border: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    hintStyle: AppTypography.bodyMedium.copyWith(
                      color: AppColors.darkGray,
                    ),
                  ),
                  style: AppTypography.bodyLarge,
                  onSubmitted: (_) => _handleAdd(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              DropdownButton<Priority>(
                value: _selectedPriority,
                underline: const SizedBox(),
                items: Priority.values
                    .map((p) => DropdownMenuItem(
                          value: p,
                          child: Text(
                            p.name.toUpperCase(),
                            style: AppTypography.labelSmall,
                          ),
                        ))
                    .toList(),
                onChanged: (p) {
                  if (p != null) {
                    setState(() => _selectedPriority = p);
                  }
                },
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: _handleAdd,
                child: const Text('Add'),
              ),
            ],
          ),
          if (_showDescription || _descriptionController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Add details...',
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  hintStyle: AppTypography.bodySmall,
                ),
                style: AppTypography.bodySmall,
                maxLines: 2,
                minLines: 1,
                onTap: () {
                  setState(() => _showDescription = true);
                },
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: TextButton(
                onPressed: () {
                  setState(() => _showDescription = true);
                },
                child: Text(
                  'Add details',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
