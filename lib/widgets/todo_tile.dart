import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/todo.dart';

class TodoTile extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  Color _getPriorityColor() {
    switch (todo.priority) {
      case Priority.high:
        return AppColors.error;
      case Priority.medium:
        return AppColors.accent;
      case Priority.low:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.gray,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (_) => onToggle(),
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Title and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      todo.title,
                      style: AppTypography.bodyLarge.copyWith(
                        color: todo.isCompleted ? AppColors.darkGray : AppColors.charcoal,
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (todo.description != null && todo.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: Text(
                          todo.description!,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Priority indicator
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getPriorityColor(),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Delete button
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: onDelete,
                iconSize: 18,
                color: AppColors.darkGray,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
