/// Date helpers used across the app.
/// Every date stored or compared is normalised to local midnight so DST shifts
/// and timezone changes can never create duplicate or missing days.
class AppDateUtils {
  const AppDateUtils._();

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static DateTime addDays(DateTime date, int days) =>
      DateTime(date.year, date.month, date.day + days);

  /// `yyyy-MM-dd` — the storage key for a single day.
  static String dayKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Monday-based week start. Pass [firstWeekday] = 6 for a Saturday week.
  static DateTime startOfWeek(DateTime date,
      {int firstWeekday = DateTime.monday}) {
    final normalised = startOfDay(date);
    final diff = (normalised.weekday - firstWeekday + 7) % 7;
    return addDays(normalised, -diff);
  }

  static DateTime startOfMonth(DateTime date) => DateTime(date.year, date.month);

  static int daysInMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0).day;

  static int daysBetween(DateTime from, DateTime to) =>
      startOfDay(to).difference(startOfDay(from)).inDays;

  // Date *formatting* deliberately lives in AppLocalizations, not here: month
  // and weekday names differ per locale, and keeping a second English-only
  // copy in core would guarantee the two drift.
}
