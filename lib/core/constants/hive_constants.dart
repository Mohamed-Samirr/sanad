/// Single source of truth for box names and Hive type ids.
/// Type ids must never be reused or reordered once shipped.
class HiveBoxes {
  const HiveBoxes._();

  static const String habits = 'habits';
  static const String habitLogs = 'habit_logs';
}

class HiveTypeIds {
  const HiveTypeIds._();

  static const int habit = 10;
  static const int habitLog = 11;
}
