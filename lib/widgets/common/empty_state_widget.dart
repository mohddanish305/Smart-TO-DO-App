// lib/widgets/common/empty_state.dart
// Minimal empty state widget

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final bool isDark;
  final bool hasFilter;

  const EmptyStateWidget({
    super.key,
    required this.isDark,
    this.hasFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checklist_rounded,
                size: 36,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasFilter ? 'No matching tasks' : 'All clear!',
              style: AppTextStyles.headingMedium(isDark),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Try a different search or category.'
                  : 'Add a task with the + button\nto get started.',
              style: AppTextStyles.bodyMedium(isDark),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
