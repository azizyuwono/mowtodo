import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 72,
            color: AppColors.mediumGray,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'No tasks yet.',
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.charcoal,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Create your first task to stay focused.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.darkGray,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
