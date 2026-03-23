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

class _AddTodoInputState extends State<AddTodoInput>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late FocusNode _titleFocus;
  late FocusNode _descriptionFocus;
  late AnimationController _focusController;
  late Animation<double> _focusBorderOpacity;
  Priority _selectedPriority = Priority.medium;
  bool _showDescription = false;
  bool _titleFocused = false;
  bool _descriptionFocused = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _focusBorderOpacity = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _focusController, curve: Curves.easeOut));

    _titleFocus.addListener(() {
      setState(() => _titleFocused = _titleFocus.hasFocus);
      if (_titleFocused) {
        _focusController.forward();
      } else if (!_descriptionFocused) {
        _focusController.reverse();
      }
    });

    _descriptionFocus.addListener(() {
      setState(() => _descriptionFocused = _descriptionFocus.hasFocus);
      if (_descriptionFocused) {
        _focusController.forward();
      } else if (!_titleFocused) {
        _focusController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _focusController.dispose();
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
    return AnimatedBuilder(
      animation: _focusBorderOpacity,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.gray.withValues(
                  alpha: 0.5 + (_focusBorderOpacity.value * 0.5),
                ),
                width: 0.5,
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
                      focusNode: _titleFocus,
                      decoration: InputDecoration(
                        hintText: 'Add a new task...',
                        border: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        hintStyle: AppTypography.bodyMedium.copyWith(
                          color: AppColors.darkGray,
                        ),
                      ),
                      style: AppTypography.bodyLarge.copyWith(
                        height: 1.5,
                      ),
                      onSubmitted: (_) => _handleAdd(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
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
                  const SizedBox(width: AppSpacing.lg),
                  ElevatedButton(
                    onPressed: _handleAdd,
                    child: const Text('Add'),
                  ),
                ],
              ),
              if (_showDescription || _descriptionController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: TextField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    decoration: InputDecoration(
                      hintText: 'Add details...',
                      border: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTypography.bodySmall.copyWith(
                        color: AppColors.darkGray,
                      ),
                    ),
                    style: AppTypography.bodySmall.copyWith(
                      height: 1.4,
                    ),
                    maxLines: 2,
                    minLines: 1,
                    onTap: () {
                      setState(() => _showDescription = true);
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: TextButton(
                    onPressed: () {
                      setState(() => _showDescription = true);
                      _descriptionFocus.requestFocus();
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
      },
    );
  }
}
