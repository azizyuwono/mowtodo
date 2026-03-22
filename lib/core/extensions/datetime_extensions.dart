extension DateTimeFormatting on DateTime {
  /// Returns true if this DateTime falls on the same calendar day as [other].
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  /// Returns true if this DateTime is strictly before today (no time component).
  bool get isOverdue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final thisDay = DateTime(year, month, day);
    return thisDay.isBefore(today);
  }

  /// Returns true if this DateTime falls on today.
  bool get isToday {
    final now = DateTime.now();
    return isSameDay(now);
  }

  /// Returns true if this DateTime falls on tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(tomorrow);
  }

  /// Short human-readable label: "Today", "Tomorrow", "Overdue", or "MMM d".
  String get shortLabel {
    if (isToday) return 'Today';
    if (isTomorrow) return 'Tomorrow';
    if (isOverdue) return 'Overdue';
    // Format as "Jan 5", "Dec 31", etc.
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[month - 1]} $day';
  }

  /// Returns midnight (00:00:00) of this date.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the last instant (23:59:59.999) of this date.
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}

extension NullableDateTimeFormatting on DateTime? {
  /// Returns [shortLabel] or null if this is null.
  String? get shortLabelOrNull => this?.shortLabel;

  /// Returns true if the date is overdue, false if null or not overdue.
  bool get isOverdueOrFalse => this?.isOverdue ?? false;
}
