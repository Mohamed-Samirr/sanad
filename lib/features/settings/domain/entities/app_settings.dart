import 'package:equatable/equatable.dart';

/// App-wide settings and preferences.
class AppSettings extends Equatable {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.lockEnabled,
    required this.reminderTimeMinutes,
    required this.smartRemindersEnabled,
    required this.firstDayOfWeek,
    required this.onboardingDone,
  });

  /// The selected locale code (e.g. 'en', 'ar'). If null, follow device locale.
  final String? locale;

  /// 'system', 'light', or 'dark'.
  final String themeMode;

  final bool lockEnabled;
  final int? reminderTimeMinutes;
  final bool smartRemindersEnabled;
  
  /// 1 (Monday) to 7 (Sunday). If null, follow locale default.
  final int? firstDayOfWeek;

  final bool onboardingDone;

  AppSettings copyWith({
    String? locale,
    bool clearLocale = false,
    String? themeMode,
    bool? lockEnabled,
    int? reminderTimeMinutes,
    bool clearReminderTime = false,
    bool? smartRemindersEnabled,
    int? firstDayOfWeek,
    bool clearFirstDayOfWeek = false,
    bool? onboardingDone,
  }) {
    return AppSettings(
      locale: clearLocale ? null : (locale ?? this.locale),
      themeMode: themeMode ?? this.themeMode,
      lockEnabled: lockEnabled ?? this.lockEnabled,
      reminderTimeMinutes: clearReminderTime 
          ? null 
          : (reminderTimeMinutes ?? this.reminderTimeMinutes),
      smartRemindersEnabled: smartRemindersEnabled ?? this.smartRemindersEnabled,
      firstDayOfWeek: clearFirstDayOfWeek 
          ? null 
          : (firstDayOfWeek ?? this.firstDayOfWeek),
      onboardingDone: onboardingDone ?? this.onboardingDone,
    );
  }

  /// The default settings for a fresh install.
  factory AppSettings.defaults() => const AppSettings(
        locale: null,
        themeMode: 'system',
        lockEnabled: false,
        reminderTimeMinutes: null,
        smartRemindersEnabled: false,
        firstDayOfWeek: null,
        onboardingDone: false,
      );

  @override
  List<Object?> get props => [
        locale,
        themeMode,
        lockEnabled,
        reminderTimeMinutes,
        smartRemindersEnabled,
        firstDayOfWeek,
        onboardingDone,
      ];
}
