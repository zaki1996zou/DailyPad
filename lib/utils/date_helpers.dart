import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static bool isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isToday(DateTime? date) {
    if (date == null) return false;
    return isSameDay(date, DateTime.now());
  }

  static bool isBeforeToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }

  static bool isAfterToday(DateTime? date) {
    if (date == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isAfter(today);
  }

  /// Due today or past due (active tasks bucket).
  static bool isTodayOrOverdue(DateTime? date) {
    if (date == null) return false;
    return isToday(date) || isBeforeToday(date);
  }

  static String formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    if (isToday(date)) return 'Today';
    if (isSameDay(date, tomorrow)) return 'Tomorrow';
    if (isBeforeToday(date)) return 'Overdue';
    return DateFormat('MMM d, yyyy').format(date);
  }

  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
