// lib/core/utils/date_utils.dart
// Date formatting helpers

import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    if (d == today) return 'Today';
    if (d == tomorrow) return 'Tomorrow';
    if (d == yesterday) return 'Yesterday';
    if (date.year == now.year) return DateFormat('MMM d').format(date);
    return DateFormat('MMM d, y').format(date);
  }

  static String formatDateTime(DateTime date) {
    return '${formatDate(date)}, ${DateFormat('h:mm a').format(date)}';
  }

  static String formatTime(DateTime date) => DateFormat('h:mm a').format(date);

  static String formatChartDay(DateTime date) =>
      DateFormat('EEE').format(date).substring(0, 2);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM y').format(date);

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    return dueDate.isBefore(DateTime.now());
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static bool isToday(DateTime date) => isSameDay(date, DateTime.now());
}
