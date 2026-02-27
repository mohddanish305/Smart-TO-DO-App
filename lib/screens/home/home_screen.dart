// lib/screens/home/home_screen.dart
// Main task dashboard: search, categories, task list, progress

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/task_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/common/empty_state_widget.dart';
import '../../widgets/common/error_snackbar.dart';
import '../../widgets/task/task_card.dart';
import '../task/add_edit_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeScreenBody();
  }
}

class _HomeScreenBody extends StatefulWidget {
  const _HomeScreenBody();

  @override
  State<_HomeScreenBody> createState() => _HomeScreenBodyState();
}

class _HomeScreenBodyState extends State<_HomeScreenBody> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: Consumer2<AuthProvider, TaskProvider>(
        builder: (context, auth, tasks, _) {
          // Show task errors via snackbar
          if (tasks.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showErrorSnackbar(context, tasks.errorMessage!);
              tasks.clearError();
            });
          }

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, auth, tasks, isDark),
              _buildSearchBar(context, tasks, isDark),
              _buildCategoryChips(context, tasks, isDark),
              _buildProgressSection(context, tasks, isDark),
              _buildTaskList(context, tasks, isDark),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTask(context),
        tooltip: 'Add task',
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context,
      AuthProvider auth,
      TaskProvider tasks,
      bool isDark,
      ) {
    final greeting = _greeting();
    final name = auth.user?.name.split(' ').first ?? 'there';

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: AppConstants.spacingM,
          right: AppConstants.spacingM,
          bottom: 8,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$greeting,', style: AppTextStyles.bodyMedium(isDark)),
                  const SizedBox(height: 2),
                  Text(name, style: AppTextStyles.headingLarge(isDark)),
                ],
              ),
            ),
            // Avatar
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    auth.user?.initials ?? '?',
                    style: AppTextStyles.labelMedium(false).copyWith(
                      color: AppColors.accentDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(
      BuildContext context,
      TaskProvider tasks,
      bool isDark,
      ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: TextField(
          controller: _searchCtrl,
          onChanged: tasks.setSearch,
          style: AppTextStyles.bodyLarge(isDark),
          decoration: InputDecoration(
            hintText: 'Search tasks…',
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _searchCtrl.clear();
                tasks.setSearch('');
              },
            )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(
      BuildContext context,
      TaskProvider tasks,
      bool isDark,
      ) {
    const categories = ['All', ...AppConstants.taskCategories];

    return SliverToBoxAdapter(
      child: SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingM, vertical: 8),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = categories[i];
            final selected = tasks.selectedCategory == cat;
            return _CategoryChip(
              label: cat,
              selected: selected,
              isDark: isDark,
              onTap: () => tasks.setCategory(cat),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressSection(
      BuildContext context,
      TaskProvider tasks,
      bool isDark,
      ) {
    if (tasks.allTasks.isEmpty) return const SliverToBoxAdapter(child: SizedBox());

    final done = tasks.completedTasks.length;
    final total = tasks.allTasks.length;
    final progress = tasks.todayProgress;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius:
            BorderRadius.circular(AppConstants.radiusLarge),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's progress",
                      style: AppTextStyles.labelMedium(isDark)),
                  Text('$done / $total tasks',
                      style: AppTextStyles.labelSmall(isDark)),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor:
                  isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(
      BuildContext context,
      TaskProvider tasks,
      bool isDark,
      ) {
    if (tasks.isLoading) {
      return const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    final filtered = tasks.filteredTasks;

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateWidget(
          isDark: isDark,
          hasFilter: tasks.searchQuery.isNotEmpty ||
              tasks.selectedCategory != 'All',
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, i) {
            final task = filtered[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Slidable(
                key: ValueKey(task.id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.28,
                  children: [
                    SlidableAction(
                      onPressed: (_) => _deleteTask(context, task, tasks),
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      icon: Icons.delete_outline_rounded,
                      label: 'Delete',
                      borderRadius:
                      BorderRadius.circular(AppConstants.radiusMedium),
                    ),
                  ],
                ),
                child: TaskCard(
                  task: task,
                  isDark: isDark,
                  onToggle: () => tasks.toggleComplete(task.id),
                  onTap: () => _openEditTask(context, task),
                ),
              ),
            );
          },
          childCount: filtered.length,
        ),
      ),
    );
  }

  // ── Navigation ────────────────────────────────────────────────

  void _openAddTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
    );
  }

  void _openEditTask(BuildContext context, TaskModel task) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => AddEditTaskScreen(existingTask: task)),
    );
  }

  Future<void> _deleteTask(
      BuildContext context,
      TaskModel task,
      TaskProvider provider,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text(
          'This cannot be undone.',
          style: AppTextStyles.bodyMedium(
              Theme.of(context).brightness == Brightness.dark),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
            TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await provider.deleteTask(task.id);
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

// ── Category Chip ─────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.durationFast,
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius:
          BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: selected
                ? AppColors.accent
                : (isDark
                ? AppColors.darkBorder
                : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium(isDark).copyWith(
            color: selected
                ? Colors.white
                : (isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
            fontWeight:
            selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
