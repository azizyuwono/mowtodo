import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../models/todo.dart';
import '../providers/filter_provider.dart';

class PriorityFilterBar extends ConsumerWidget {
  const PriorityFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterState = ref.watch(filterProvider);
    final filterNotifier = ref.read(filterProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.borderColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _FilterCheckbox(
            label: 'High',
            value: filterState.showHigh,
            onChanged: (_) => filterNotifier.togglePriority(Priority.high),
          ),
          const SizedBox(width: AppSpacing.xl),
          _FilterCheckbox(
            label: 'Medium',
            value: filterState.showMedium,
            onChanged: (_) => filterNotifier.togglePriority(Priority.medium),
          ),
          const SizedBox(width: AppSpacing.xl),
          _FilterCheckbox(
            label: 'Low',
            value: filterState.showLow,
            onChanged: (_) => filterNotifier.togglePriority(Priority.low),
          ),
          const SizedBox(width: AppSpacing.xl),
          _FilterCheckbox(
            label: 'Completed',
            value: filterState.showCompleted,
            onChanged: (_) => filterNotifier.toggleCompleted(),
          ),
        ],
      ),
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _FilterCheckbox({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            visualDensity: VisualDensity.compact,
            activeColor: AppColors.nearBlack,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
