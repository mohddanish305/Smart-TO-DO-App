// lib/screens/analytics/analytics_screen.dart
// Analytics dashboard — Monday-based weekly chart, theme-aware colors

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../providers/task_provider.dart';
import '../../widgets/analytics/stat_tile.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: Consumer<TaskProvider>(
        builder: (context, tasks, _) {
          return CustomScrollView(
            slivers: [
              _buildAppBar(context, isDark),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Today ─────────────────────────────────
                    _sectionLabel('Today', isDark),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: 'Completed',
                            value: '${tasks.todayCompleted}',
                            icon: Icons.check_circle_outline_rounded,
                            color: AppColors.success,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatTile(
                            label: 'Pending',
                            value: '${tasks.todayPending}',
                            icon: Icons.hourglass_empty_rounded,
                            color: AppColors.warning,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppConstants.spacingL),

                    // ── Weekly Chart (Mon–Sun) ─────────────────
                    _sectionLabel('This Week (Mon–Sun)', isDark),
                    const SizedBox(height: 10),
                    _WeeklyChart(tasks: tasks, isDark: isDark),

                    const SizedBox(height: AppConstants.spacingL),

                    // ── Monthly ───────────────────────────────
                    _sectionLabel(
                        AppDateUtils.formatMonthYear(DateTime.now()), isDark),
                    const SizedBox(height: 10),
                    _MonthlyCard(tasks: tasks, isDark: isDark),

                    const SizedBox(height: AppConstants.spacingL),

                    // ── Yearly ────────────────────────────────
                    _sectionLabel('Year ${DateTime.now().year}', isDark),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            label: 'Completed',
                            value: '${tasks.yearlyCompleted}',
                            icon: Icons.emoji_events_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatTile(
                            label: 'Total tasks',
                            value: '${tasks.yearlyTotal}',
                            icon: Icons.list_alt_rounded,
                            color: AppColors.info,
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 20,
          left: AppConstants.spacingM,
          right: AppConstants.spacingM,
          bottom: 16,
        ),
        child: Text('Analytics', style: AppTextStyles.headingLarge(isDark)),
      ),
    );
  }

  Widget _sectionLabel(String text, bool isDark) {
    return Text(text, style: AppTextStyles.labelMedium(isDark));
  }
}

// ── Weekly Bar Chart (Mon→Sun) ────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  final TaskProvider tasks;
  final bool isDark;

  const _WeeklyChart({required this.tasks, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final data = tasks.weeklyData;       // [Mon, Tue, Wed, Thu, Fri, Sat, Sun]
    final weekDays = tasks.weekDays;     // actual DateTime for each day
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon … 6=Sun

    final maxVal = data.fold(0, (m, v) => v > m ? v : m);
    final maxY = (maxVal < 4 ? 5 : maxVal + 2).toDouble();

    final cardColor = Theme.of(context).cardTheme.color ??
        (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: border),
      ),
      child: data.every((v) => v == 0)
          ? Center(
              child: Text(
                'No completions this week',
                style: AppTextStyles.bodySmall(isDark),
              ),
            )
          : BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor:
                        isDark ? AppColors.darkCard : AppColors.lightSurface,
                    tooltipBorder: BorderSide(color: border, width: 1),
                    getTooltipItem: (group, _, rod, __) {
                      return BarTooltipItem(
                        '${rod.toY.toInt()}',
                        AppTextStyles.labelMedium(isDark),
                      );
                    },
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: border,
                    strokeWidth: 0.8,
                    dashArray: [4, 4],
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (val, _) {
                        final idx = val.toInt();
                        if (idx < 0 || idx > 6) return const SizedBox.shrink();
                        final isToday = idx == todayIndex;
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            AppDateUtils.formatChartDay(weekDays[idx]),
                            style: AppTextStyles.labelSmall(isDark).copyWith(
                              color: isToday ? primary : null,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(7, (i) {
                  final isToday = i == todayIndex;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].toDouble(),
                        width: 18,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(5)),
                        color: isToday
                            ? primary
                            : primary.withValues(alpha: 0.30),
                      ),
                    ],
                  );
                }),
              ),
            ),
    );
  }
}

// ── Monthly Card ──────────────────────────────────────────────────

class _MonthlyCard extends StatelessWidget {
  final TaskProvider tasks;
  final bool isDark;

  const _MonthlyCard({required this.tasks, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final rate = tasks.monthlyRate;
    final completed = tasks.monthlyCompleted;
    final total = tasks.monthlyTotal;
    final cardColor = Theme.of(context).cardTheme.color ??
        (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$completed', style: AppTextStyles.displayMedium(isDark)),
                  Text('of $total tasks completed',
                      style: AppTextStyles.bodyMedium(isDark)),
                ],
              ),
              _CirclePercent(rate: rate, isDark: isDark, primary: primary),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 6,
              backgroundColor: border,
              color: primary,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(rate * 100).toStringAsFixed(0)}% completion rate',
              style: AppTextStyles.bodySmall(isDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _CirclePercent extends StatelessWidget {
  final double rate;
  final bool isDark;
  final Color primary;

  const _CirclePercent({
    required this.rate,
    required this.isDark,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: rate,
            strokeWidth: 5,
            backgroundColor: border,
            color: primary,
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(rate * 100).toInt()}%',
            style: AppTextStyles.labelMedium(isDark)
                .copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
