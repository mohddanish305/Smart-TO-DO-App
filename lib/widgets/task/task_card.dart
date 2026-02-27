// lib/widgets/task/task_card.dart
// Premium minimal task card with completion toggle and tap to edit

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/date_utils.dart';
import '../../../models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isDark;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const TaskCard({
    super.key,
    required this.task,
    required this.isDark,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final isOverdue =
        !task.isCompleted && AppDateUtils.isOverdue(task.dueDate);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? (isDark
              ? AppColors.darkBg
              : AppColors.lightBg)
              : cardColor,
          borderRadius:
          BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(
            color: isOverdue
                ? AppColors.error.withValues(alpha: 0.4)
                : border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: GestureDetector(
                onTap: onToggle,
                child: AnimatedContainer(
                  duration: AppConstants.durationFast,
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? AppColors.accent
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? AppColors.accent
                          : (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted),
                      width: 1.5,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check_rounded,
                      size: 13, color: Colors.white)
                      : null,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Content ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headingSmall(isDark).copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.isCompleted
                          ? (isDark
                          ? AppColors.darkTextMuted
                          : AppColors.lightTextMuted)
                          : null,
                    ),
                  ),

                  // Description
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      task.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium(isDark).copyWith(
                        color: task.isCompleted
                            ? (isDark
                            ? AppColors.darkTextMuted
                            : AppColors.lightTextMuted)
                            : null,
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Footer row
                  Row(
                    children: [
                      // Category dot
                      _CategoryBadge(
                          category: task.category, isDark: isDark),

                      // Due date
                      if (task.dueDate != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: isOverdue
                              ? AppColors.error
                              : (isDark
                              ? AppColors.darkTextMuted
                              : AppColors.lightTextMuted),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          AppDateUtils.formatDate(task.dueDate!),
                          style: AppTextStyles.labelSmall(isDark).copyWith(
                            color: isOverdue ? AppColors.error : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  final bool isDark;

  const _CategoryBadge({required this.category, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final idx = AppConstants.taskCategories.indexOf(category);
    final color = idx >= 0
        ? AppColors.categoryColors[idx % AppColors.categoryColors.length]
        : AppColors.accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius:
        BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        category,
        style: AppTextStyles.labelSmall(isDark).copyWith(color: color),
      ),
    );
  }
}
