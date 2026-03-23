import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/todo.dart';

class TodoTile extends StatefulWidget {
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

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late AnimationController _hoverController;
  late Animation<double> _hoverOpacity;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverOpacity = Tween<double>(begin: 0, end: 0.04)
        .animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  Color _getPriorityColor() {
    switch (widget.todo.priority) {
      case Priority.high:
        return AppColors.charcoal;
      case Priority.medium:
        return AppColors.gray;
      case Priority.low:
        return AppColors.mediumGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovering = true);
        _hoverController.forward();
      },
      onExit: (_) {
        setState(() => _isHovering = false);
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverOpacity,
        builder: (context, child) {
          return Container(
            color: Color.lerp(
              Colors.transparent,
              AppColors.softGray,
              _hoverOpacity.value,
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.lightGray,
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Checkbox with animation
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: widget.todo.isCompleted,
                      onChanged: (_) => widget.onToggle(),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Title and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todo.title,
                          style: AppTypography.bodyLarge.copyWith(
                            color: widget.todo.isCompleted
                                ? AppColors.mediumGray
                                : AppColors.textPrimary,
                            decoration: widget.todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            height: 1.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.todo.description != null &&
                            widget.todo.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              widget.todo.description!,
                              style: AppTypography.bodySmall.copyWith(
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Priority indicator
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getPriorityColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),

                  // Delete button - animated reveal
                  AnimatedOpacity(
                    opacity: _isHovering ? 1 : 0.3,
                    duration: const Duration(milliseconds: 200),
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onDelete,
                      iconSize: 18,
                      color: AppColors.textSecondary,
                      splashRadius: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
