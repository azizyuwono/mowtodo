import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class TodoStats extends StatelessWidget {
  final int total;
  final int active;
  final int completed;

  const TodoStats({
    super.key,
    required this.total,
    required this.active,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        border: Border(
          bottom: BorderSide(
            color: AppColors.gray,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatItem(label: 'Total', value: total),
          _StatItem(label: 'Active', value: active, color: AppColors.accent),
          _StatItem(label: 'Done', value: completed, color: AppColors.success),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final Color? color;

  const _StatItem({
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$value',
          style: AppTypography.displayMedium.copyWith(
            color: color ?? AppColors.charcoal,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall,
        ),
      ],
    );
  }
}
