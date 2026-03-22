import 'package:flutter/material.dart';
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
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No tasks yet.',
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Add one to get started.',
            style: AppTypography.bodyMedium,
          ),
        ],
      ),
    );
  }
}
