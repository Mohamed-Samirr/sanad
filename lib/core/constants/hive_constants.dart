/// Single source of truth for box names and Hive type ids.
/// Type ids must never be reused or reordered once shipped.
class HiveBoxes {
  const HiveBoxes._();

  static const String habits = 'habits';
  static const String habitLogs = 'habit_logs';
  static const String settings = 'settings';
  static const String toolbox = 'toolbox';
  static const String journal = 'journal';
  
  // Urge & Support Boxes
  static const String behaviors = 'behaviors';
  static const String urgeEntries = 'urge_entries';
  static const String triggers = 'triggers';
  static const String supportContacts = 'support_contacts';
}

class HiveTypeIds {
  const HiveTypeIds._();

  static const int habit = 10;
  static const int habitLog = 11;
  static const int appSettings = 12;
  static const int toolAction = 13;
  
  // Urge Flow
  static const int behavior = 14;
  static const int urgeEntry = 15;
  static const int trigger = 16;
  static const int supportContact = 17;
  static const int journalEntry = 18;
}
