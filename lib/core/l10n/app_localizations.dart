import 'package:flutter/material.dart';

import '../errors/failures.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

/// Hand-written rather than generated.
///
/// The project runs with zero codegen, so there is no `gen_l10n` step here.
/// The `.arb` files under `lib/l10n/` stay the translator-facing source of
/// truth, and `test/l10n_parity_test.dart` fails the build if they and these
/// classes ever drift apart — which is the one real risk of writing both by
/// hand.
abstract class AppLocalizations {
  const AppLocalizations();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  // ------------------------------------------------------------- app shell
  String get appTitle;

  // ------------------------------------------------------- habits list
  String get habitsTitle;
  String get settingsTooltip;
  String get addHabit;
  String get noHabitsTitle;
  String get noHabitsMessage;
  String get nothingScheduledToday;
  String doneOfDueToday(int done, int due);
  String doneOfDueTodaySemantics(int done, int due);
  String get skipToday;
  String get skipTodayDescription;
  String get clearTodayEntry;
  String get editHabit;
  String get openDetails;

  // ------------------------------------------------------------ time of day
  String get timeOfDayMorning;
  String get timeOfDayAfternoon;
  String get timeOfDayEvening;
  String get timeOfDayAnytime;

  // --------------------------------------------------------- habit detail
  String get removeHabit;
  String get habitCouldNotOpenTitle;
  String get habitCouldNotOpenMessage;
  String get goBack;
  String get removeThisHabitTitle;
  String get removeThisHabitMessage;
  String get archiveHabit;
  String get deletePermanently;
  String get healthTrendTitle;
  String get trendHoldingSteady;
  String trendUp(int points);
  String trendDown(int points);
  String get completionCalendarTitle;
  String get recentEntriesTitle;
  String get recentEntriesSubtitle;
  String get notEnoughTrendData;
  String get chartRiskLabel;
  String get statVsLastWeek;
  String statDaysRatio(int done, int total);
  String statBest(int best);
  String sinceDate(String date);

  // ----------------------------------------------------------- habit form
  String get newHabitTitle;
  String get editHabitTitle;
  String get save;
  String get saving;
  String get formNameSection;
  String get formNameHint;
  String get formAppearanceSection;
  String get formColourLabel;
  String get formIconSemantics;
  String get formColourSemantics;
  String get formScheduleSection;
  String get scheduleDaily;
  String get scheduleWeekdays;
  String get scheduleTimesPerWeek;
  String timesPerWeekExplain(int count);
  String daysPerWeekLabel(int count);
  String get fewerDays;
  String get moreDays;
  String get formTimeOfDaySection;
  String get formDetailsSection;
  String get formTargetLabel;
  String get formTargetHint;
  String get formReminderLabel;
  String get formReminderOff;
  String get formTurnReminderOff;
  String get formStartDateLabel;
  String get formStartDateLockedNote;
  String get saveChanges;
  String get startTracking;

  // -------------------------------------------------------------- day sheet
  String get dayNotRecordedYet;
  String get dayNotScheduled;
  String get dayMarkedDone;
  String get dayMarkedSkipped;
  String get markDone;
  String get markDoneDescription;
  String get markSkipped;
  String get markSkippedDescription;
  String get clearThisDay;
  String get clearThisDayDescription;
  String get noteOptional;
  String get noteHint;
  String get noteSavedWithChoice;

  // ---------------------------------------------------------------- history
  String get nothingLoggedYet;
  String get statusDone;
  String get statusSkipped;
  String moreInCalendar(int count);

  // --------------------------------------------------------------- calendar
  String get previousMonth;
  String get nextMonth;
  String get legendDone;
  String get legendSkipped;
  String get legendMissed;
  String dayCellSemantics(String date, String state);
  String get dayStateDone;
  String get dayStateSkipped;
  String get dayStateUpcoming;
  String get dayStateNotScheduled;
  String get dayStateMissed;

  // --------------------------------------------------------------- archived
  String get archivedHabitsTitle;
  String get nothingArchivedTitle;
  String get nothingArchivedMessage;
  String get backToHabits;
  String loggedDaysSince(int count, String date);
  String get noLoggedDaysYet;
  String get restore;
  String get delete;
  String deleteHabitTitle(String name);
  String deleteWithHistoryMessage(int count);
  String get deleteNoHistoryMessage;
  String get keepIt;
  String get continueLabel;
  String get permanentTitle;
  String permanentMessage(int count, String name);
  String get cancel;
  String get deleteForever;
  String restoredMessage(String name);
  String deletedMessage(String name);

  // --------------------------------------------------------------- settings
  String get settingsTitle;
  String get settingsHabitsSection;
  String get settingsArchivedLabel;
  String get settingsArchivedDescription;
  String get settingsAboutSection;
  String get disclaimer;

  // ------------------------------------------------------------- onboarding
  String get onboardingTitle;
  String get onboardingDefensiveTitle;
  String get onboardingDefensiveText;
  String get onboardingOffensiveTitle;
  String get onboardingOffensiveText;
  String get onboardingCTA;

  // ------------------------------------------------------------- toolbox
  String get toolboxTitle;
  String get noToolsTitle;
  String get noToolsMessage;
  String get addTool;
  String get editToolTitle;
  String get newToolTitle;
  String get toolNameHint;
  String get toolDescriptionHint;
  String get toolDurationLabel;
  String get toolCategoryLabel;
  String get deleteTool;
  String get deleteToolMessage;

  // ------------------------------------------------------------- semantics
  String get checkDoneToday;
  String get checkMarkDone;
  String streakSemantics(int days);

  // -------------------------------------------------------------- failures
  String get failureNameRequired;
  String get failureWeekdayRequired;
  String get failureWeeklyTargetRange;
  String get failureFutureDay;
  String get failureCache;
  String get failureNotFound;
  String get failureUnexpected;
  String get reminderPermissionDenied;
  String get reminderPermissionUnavailable;

  // ------------------------------------------------------------- journal
  String get journalTitle;
  String get noJournalEntriesTitle;
  String get noJournalEntriesMessage;
  String get addJournalEntry;
  String get editJournalEntry;
  String get journalMood;
  String get journalEnergy;
  String get journalSleepQuality;
  String get journalStress;
  String get journalFeltNote;
  String get journalNeededNote;
  String get journalThoughtNote;
  String get journalTags;

  // ------------------------------------------------------------- support
  String get supportTitle;
  String get noSupportContactsTitle;
  String get noSupportContactsMessage;
  String get addSupportContact;
  String get editSupportContact;
  String get contactName;
  String get contactPhone;
  String get contactMessageTemplate;
  String get contactMessageHint;
  String get deleteContact;
  String get deleteContactMessage;

  /// Turns a [Failure] into a sentence in this locale.
  ///
  /// Falls back to the failure's own developer-facing message when it carries
  /// no code — better an untranslated sentence than a blank alert.
  String forFailure(Failure failure) {
    switch (failure.code) {
      case FailureCode.nameRequired:
        return failureNameRequired;
      case FailureCode.weekdayRequired:
        return failureWeekdayRequired;
      case FailureCode.weeklyTargetRange:
        return failureWeeklyTargetRange;
      case FailureCode.futureDay:
        return failureFutureDay;
      case FailureCode.cache:
        return failureCache;
      case FailureCode.notFound:
        return failureNotFound;
      case FailureCode.reminderPermissionUnavailable:
        return reminderPermissionUnavailable;
      case FailureCode.reminderPermissionDenied:
        return reminderPermissionDenied;
      case FailureCode.unexpected:
        return failureUnexpected;
      default:
        return failure.message;
    }
  }

  // ------------------------------------------------------------------ dates
  /// January … December, in order.
  List<String> get monthNames;

  /// Monday … Sunday, in order — matching `DateTime.weekday` 1–7.
  List<String> get weekdayNamesShort;

  /// The first day of the week for this locale. Arabic weeks start Saturday.
  int get firstWeekday;

  String shortDate(DateTime date) =>
      '${date.day} ${monthNames[date.month - 1]} ${date.year}';

  String monthTitle(DateTime date) =>
      '${monthNames[date.month - 1]} ${date.year}';

  /// `3/7` style label for the trend chart axis.
  String compactDate(DateTime date) => '${date.day}/${date.month}';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any(
        (supported) => supported.languageCode == locale.languageCode,
      );

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      locale.languageCode == 'en'
          ? const AppLocalizationsEn()
          : const AppLocalizationsAr();

  // Nothing is loaded asynchronously, so a reload is never needed.
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
