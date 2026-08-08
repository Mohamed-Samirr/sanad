import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sanad'**
  String get appTitle;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @addHabit.
  ///
  /// In en, this message translates to:
  /// **'Add a habit'**
  String get addHabit;

  /// No description provided for @noHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'No habits yet'**
  String get noHabitsTitle;

  /// No description provided for @noHabitsMessage.
  ///
  /// In en, this message translates to:
  /// **'Start with one small action you can repeat tomorrow. You can promote any toolbox action into a tracked habit.'**
  String get noHabitsMessage;

  /// No description provided for @nothingScheduledToday.
  ///
  /// In en, this message translates to:
  /// **'Nothing scheduled today.'**
  String get nothingScheduledToday;

  /// No description provided for @doneOfDueToday.
  ///
  /// In en, this message translates to:
  /// **'{done} of {due} done today'**
  String doneOfDueToday(int done, int due);

  /// No description provided for @doneOfDueTodaySemantics.
  ///
  /// In en, this message translates to:
  /// **'{done} of {due} habits done today'**
  String doneOfDueTodaySemantics(int done, int due);

  /// No description provided for @skipToday.
  ///
  /// In en, this message translates to:
  /// **'Skip today'**
  String get skipToday;

  /// No description provided for @skipTodayDescription.
  ///
  /// In en, this message translates to:
  /// **'A rest day you chose. Your streak holds.'**
  String get skipTodayDescription;

  /// No description provided for @clearTodayEntry.
  ///
  /// In en, this message translates to:
  /// **'Clear today\'s entry'**
  String get clearTodayEntry;

  /// No description provided for @editHabit.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabit;

  /// No description provided for @openDetails.
  ///
  /// In en, this message translates to:
  /// **'Open details'**
  String get openDetails;

  /// No description provided for @timeOfDayMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get timeOfDayMorning;

  /// No description provided for @timeOfDayAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get timeOfDayAfternoon;

  /// No description provided for @timeOfDayEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get timeOfDayEvening;

  /// No description provided for @timeOfDayAnytime.
  ///
  /// In en, this message translates to:
  /// **'Anytime'**
  String get timeOfDayAnytime;

  /// No description provided for @removeHabit.
  ///
  /// In en, this message translates to:
  /// **'Remove habit'**
  String get removeHabit;

  /// No description provided for @habitCouldNotOpenTitle.
  ///
  /// In en, this message translates to:
  /// **'This habit could not be opened'**
  String get habitCouldNotOpenTitle;

  /// No description provided for @habitCouldNotOpenMessage.
  ///
  /// In en, this message translates to:
  /// **'Try again from the habits list.'**
  String get habitCouldNotOpenMessage;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @removeThisHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove this habit'**
  String get removeThisHabitTitle;

  /// No description provided for @removeThisHabitMessage.
  ///
  /// In en, this message translates to:
  /// **'Archiving keeps the history and hides the habit from your list. Deleting removes every logged day for good.'**
  String get removeThisHabitMessage;

  /// No description provided for @archiveHabit.
  ///
  /// In en, this message translates to:
  /// **'Archive habit'**
  String get archiveHabit;

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete permanently'**
  String get deletePermanently;

  /// No description provided for @healthTrendTitle.
  ///
  /// In en, this message translates to:
  /// **'Health trend · last 30 days'**
  String get healthTrendTitle;

  /// No description provided for @trendHoldingSteady.
  ///
  /// In en, this message translates to:
  /// **'Holding steady against last week.'**
  String get trendHoldingSteady;

  /// No description provided for @trendUp.
  ///
  /// In en, this message translates to:
  /// **'Up {points} points on last week\'s average.'**
  String trendUp(int points);

  /// No description provided for @trendDown.
  ///
  /// In en, this message translates to:
  /// **'Down {points} points on last week\'s average.'**
  String trendDown(int points);

  /// No description provided for @completionCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Completion calendar'**
  String get completionCalendarTitle;

  /// No description provided for @recentEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent entries'**
  String get recentEntriesTitle;

  /// No description provided for @recentEntriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Newest first. Tap one to change it.'**
  String get recentEntriesSubtitle;

  /// No description provided for @notEnoughTrendData.
  ///
  /// In en, this message translates to:
  /// **'Log a few more days and the trend line will show up here.'**
  String get notEnoughTrendData;

  /// No description provided for @chartRiskLabel.
  ///
  /// In en, this message translates to:
  /// **'check-in'**
  String get chartRiskLabel;

  /// No description provided for @statVsLastWeek.
  ///
  /// In en, this message translates to:
  /// **'vs last week'**
  String get statVsLastWeek;

  /// No description provided for @statDaysRatio.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} days'**
  String statDaysRatio(int done, int total);

  /// No description provided for @statBest.
  ///
  /// In en, this message translates to:
  /// **'best {best}'**
  String statBest(int best);

  /// No description provided for @sinceDate.
  ///
  /// In en, this message translates to:
  /// **'Since {date}'**
  String sinceDate(String date);

  /// No description provided for @newHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'New habit'**
  String get newHabitTitle;

  /// No description provided for @editHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get editHabitTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get saving;

  /// No description provided for @formNameSection.
  ///
  /// In en, this message translates to:
  /// **'What are you building?'**
  String get formNameSection;

  /// No description provided for @formNameHint.
  ///
  /// In en, this message translates to:
  /// **'Morning walk'**
  String get formNameHint;

  /// No description provided for @formAppearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Icon and colour'**
  String get formAppearanceSection;

  /// No description provided for @formColourLabel.
  ///
  /// In en, this message translates to:
  /// **'Colour'**
  String get formColourLabel;

  /// No description provided for @formIconSemantics.
  ///
  /// In en, this message translates to:
  /// **'Habit icon'**
  String get formIconSemantics;

  /// No description provided for @formColourSemantics.
  ///
  /// In en, this message translates to:
  /// **'Habit colour'**
  String get formColourSemantics;

  /// No description provided for @formScheduleSection.
  ///
  /// In en, this message translates to:
  /// **'How often?'**
  String get formScheduleSection;

  /// No description provided for @scheduleDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get scheduleDaily;

  /// No description provided for @scheduleWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Certain days'**
  String get scheduleWeekdays;

  /// No description provided for @scheduleTimesPerWeek.
  ///
  /// In en, this message translates to:
  /// **'Times a week'**
  String get scheduleTimesPerWeek;

  /// No description provided for @timesPerWeekExplain.
  ///
  /// In en, this message translates to:
  /// **'Any {count} days that suit you. A day only counts against you once the week can no longer reach the target.'**
  String timesPerWeekExplain(int count);

  /// No description provided for @daysPerWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{day a week} other{days a week}}'**
  String daysPerWeekLabel(int count);

  /// No description provided for @fewerDays.
  ///
  /// In en, this message translates to:
  /// **'Fewer days'**
  String get fewerDays;

  /// No description provided for @moreDays.
  ///
  /// In en, this message translates to:
  /// **'More days'**
  String get moreDays;

  /// No description provided for @formTimeOfDaySection.
  ///
  /// In en, this message translates to:
  /// **'When in the day?'**
  String get formTimeOfDaySection;

  /// No description provided for @formDetailsSection.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get formDetailsSection;

  /// No description provided for @formTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'Target (optional)'**
  String get formTargetLabel;

  /// No description provided for @formTargetHint.
  ///
  /// In en, this message translates to:
  /// **'30 minutes, 5 pages'**
  String get formTargetHint;

  /// No description provided for @formReminderLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder'**
  String get formReminderLabel;

  /// No description provided for @formReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get formReminderOff;

  /// No description provided for @formTurnReminderOff.
  ///
  /// In en, this message translates to:
  /// **'Turn reminder off'**
  String get formTurnReminderOff;

  /// No description provided for @formStartDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Start date'**
  String get formStartDateLabel;

  /// No description provided for @formStartDateLockedNote.
  ///
  /// In en, this message translates to:
  /// **'The start date stays put so your logged history keeps its shape.'**
  String get formStartDateLockedNote;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @startTracking.
  ///
  /// In en, this message translates to:
  /// **'Start tracking'**
  String get startTracking;

  /// No description provided for @dayNotRecordedYet.
  ///
  /// In en, this message translates to:
  /// **'Not recorded yet.'**
  String get dayNotRecordedYet;

  /// No description provided for @dayNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'Not scheduled on this day.'**
  String get dayNotScheduled;

  /// No description provided for @dayMarkedDone.
  ///
  /// In en, this message translates to:
  /// **'Marked done.'**
  String get dayMarkedDone;

  /// No description provided for @dayMarkedSkipped.
  ///
  /// In en, this message translates to:
  /// **'Marked as skipped.'**
  String get dayMarkedSkipped;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @markDoneDescription.
  ///
  /// In en, this message translates to:
  /// **'You did it on this day.'**
  String get markDoneDescription;

  /// No description provided for @markSkipped.
  ///
  /// In en, this message translates to:
  /// **'Mark skipped'**
  String get markSkipped;

  /// No description provided for @markSkippedDescription.
  ///
  /// In en, this message translates to:
  /// **'A deliberate rest day. Your streak keeps running.'**
  String get markSkippedDescription;

  /// No description provided for @clearThisDay.
  ///
  /// In en, this message translates to:
  /// **'Clear this day'**
  String get clearThisDay;

  /// No description provided for @clearThisDayDescription.
  ///
  /// In en, this message translates to:
  /// **'Remove the entry and leave the day blank.'**
  String get clearThisDayDescription;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'What made the difference today?'**
  String get noteHint;

  /// No description provided for @noteSavedWithChoice.
  ///
  /// In en, this message translates to:
  /// **'The note is saved with whichever option you pick.'**
  String get noteSavedWithChoice;

  /// No description provided for @nothingLoggedYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing logged yet. Tap any day on the calendar to record it, and add a note if something is worth remembering.'**
  String get nothingLoggedYet;

  /// No description provided for @statusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get statusDone;

  /// No description provided for @statusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get statusSkipped;

  /// No description provided for @moreInCalendar.
  ///
  /// In en, this message translates to:
  /// **'+{count} more in the calendar above.'**
  String moreInCalendar(int count);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// No description provided for @legendDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get legendDone;

  /// No description provided for @legendSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get legendSkipped;

  /// No description provided for @legendMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get legendMissed;

  /// No description provided for @dayCellSemantics.
  ///
  /// In en, this message translates to:
  /// **'{date}, {state}'**
  String dayCellSemantics(String date, String state);

  /// No description provided for @dayStateDone.
  ///
  /// In en, this message translates to:
  /// **'done'**
  String get dayStateDone;

  /// No description provided for @dayStateSkipped.
  ///
  /// In en, this message translates to:
  /// **'skipped'**
  String get dayStateSkipped;

  /// No description provided for @dayStateUpcoming.
  ///
  /// In en, this message translates to:
  /// **'upcoming'**
  String get dayStateUpcoming;

  /// No description provided for @dayStateNotScheduled.
  ///
  /// In en, this message translates to:
  /// **'not scheduled'**
  String get dayStateNotScheduled;

  /// No description provided for @dayStateMissed.
  ///
  /// In en, this message translates to:
  /// **'missed'**
  String get dayStateMissed;

  /// No description provided for @archivedHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archivedHabitsTitle;

  /// No description provided for @nothingArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived'**
  String get nothingArchivedTitle;

  /// No description provided for @nothingArchivedMessage.
  ///
  /// In en, this message translates to:
  /// **'Habits you archive land here with their history intact. You can bring any of them back whenever you want.'**
  String get nothingArchivedMessage;

  /// No description provided for @backToHabits.
  ///
  /// In en, this message translates to:
  /// **'Back to habits'**
  String get backToHabits;

  /// No description provided for @loggedDaysSince.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} logged day} other{{count} logged days}} · since {date}'**
  String loggedDaysSince(int count, String date);

  /// No description provided for @noLoggedDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No logged days yet'**
  String get noLoggedDaysYet;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteHabitTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deleteHabitTitle(String name);

  /// No description provided for @deleteWithHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Every one of the {count} logged day recorded for this habit is deleted with it.} other{Every one of the {count} logged days recorded for this habit is deleted with it.}} That part cannot be undone.'**
  String deleteWithHistoryMessage(int count);

  /// No description provided for @deleteNoHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'This habit has no logged days. It will be removed for good.'**
  String get deleteNoHistoryMessage;

  /// No description provided for @keepIt.
  ///
  /// In en, this message translates to:
  /// **'Keep it'**
  String get keepIt;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @permanentTitle.
  ///
  /// In en, this message translates to:
  /// **'This is permanent'**
  String get permanentTitle;

  /// No description provided for @permanentMessage.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} logged day will be erased.} other{{count} logged days will be erased.}} If you only want {name} off your list, it is already archived — you can leave it here instead.'**
  String permanentMessage(int count, String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @deleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get deleteForever;

  /// No description provided for @restoredMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} is back on your list.'**
  String restoredMessage(String name);

  /// No description provided for @deletedMessage.
  ///
  /// In en, this message translates to:
  /// **'{name} and its history were deleted.'**
  String deletedMessage(String name);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHabitsSection.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get settingsHabitsSection;

  /// No description provided for @settingsArchivedLabel.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get settingsArchivedLabel;

  /// No description provided for @settingsArchivedDescription.
  ///
  /// In en, this message translates to:
  /// **'Restore one, or delete it and its history.'**
  String get settingsArchivedDescription;

  /// No description provided for @settingsAboutSection.
  ///
  /// In en, this message translates to:
  /// **'About this app'**
  String get settingsAboutSection;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'Sanad is a self-tracking tool. It is not medical treatment and it does not replace a doctor or a therapist. If things feel severe or unsafe, talking to a professional is the right step, and reaching for it is not a failure of anything you have built here.'**
  String get disclaimer;

  /// No description provided for @onboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Sanad'**
  String get onboardingTitle;

  /// No description provided for @onboardingDefensiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Defend'**
  String get onboardingDefensiveTitle;

  /// No description provided for @onboardingDefensiveText.
  ///
  /// In en, this message translates to:
  /// **'Log an urge the moment it hits. Delay it, fight it with your tools, or reach out.'**
  String get onboardingDefensiveText;

  /// No description provided for @onboardingOffensiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get onboardingOffensiveTitle;

  /// No description provided for @onboardingOffensiveText.
  ///
  /// In en, this message translates to:
  /// **'Track the constructive habits you want to build and see your progress over time.'**
  String get onboardingOffensiveText;

  /// No description provided for @onboardingCTA.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboardingCTA;

  /// No description provided for @toolboxTitle.
  ///
  /// In en, this message translates to:
  /// **'Toolbox'**
  String get toolboxTitle;

  /// No description provided for @noToolsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your toolbox is empty'**
  String get noToolsTitle;

  /// No description provided for @noToolsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add things that help you ride out an urge, like a breathing exercise, calling a friend, or taking a walk.'**
  String get noToolsMessage;

  /// No description provided for @addTool.
  ///
  /// In en, this message translates to:
  /// **'Add tool'**
  String get addTool;

  /// No description provided for @editToolTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit tool'**
  String get editToolTitle;

  /// No description provided for @newToolTitle.
  ///
  /// In en, this message translates to:
  /// **'New tool'**
  String get newToolTitle;

  /// No description provided for @toolNameHint.
  ///
  /// In en, this message translates to:
  /// **'Tool name'**
  String get toolNameHint;

  /// No description provided for @toolDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'How do you do it?'**
  String get toolDescriptionHint;

  /// No description provided for @toolDurationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration (minutes)'**
  String get toolDurationLabel;

  /// No description provided for @toolCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get toolCategoryLabel;

  /// No description provided for @deleteTool.
  ///
  /// In en, this message translates to:
  /// **'Delete tool'**
  String get deleteTool;

  /// No description provided for @deleteToolMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this tool from your toolbox?'**
  String get deleteToolMessage;

  /// No description provided for @checkDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get checkDoneToday;

  /// No description provided for @checkMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get checkMarkDone;

  /// No description provided for @streakSemantics.
  ///
  /// In en, this message translates to:
  /// **'{days} day streak'**
  String streakSemantics(int days);

  /// No description provided for @failureNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the habit a name.'**
  String get failureNameRequired;

  /// No description provided for @failureWeekdayRequired.
  ///
  /// In en, this message translates to:
  /// **'Pick at least one day of the week.'**
  String get failureWeekdayRequired;

  /// No description provided for @failureWeeklyTargetRange.
  ///
  /// In en, this message translates to:
  /// **'Set a weekly target between 1 and 7.'**
  String get failureWeeklyTargetRange;

  /// No description provided for @failureFutureDay.
  ///
  /// In en, this message translates to:
  /// **'You cannot log a day that has not happened yet.'**
  String get failureFutureDay;

  /// No description provided for @failureCache.
  ///
  /// In en, this message translates to:
  /// **'Could not reach local storage.'**
  String get failureCache;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'This habit no longer exists.'**
  String get failureNotFound;

  /// No description provided for @failureUnexpected.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get failureUnexpected;

  /// No description provided for @reminderPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Reminders need notification permission. You can turn it on in your device settings and set this again.'**
  String get reminderPermissionDenied;

  /// No description provided for @reminderPermissionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the notification settings.'**
  String get reminderPermissionUnavailable;

  /// No description provided for @journalTitle.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get journalTitle;

  /// No description provided for @noJournalEntriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No journal entries'**
  String get noJournalEntriesTitle;

  /// No description provided for @noJournalEntriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Write your first entry to reflect on how you\'re doing.'**
  String get noJournalEntriesMessage;

  /// No description provided for @addJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addJournalEntry;

  /// No description provided for @editJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editJournalEntry;

  /// No description provided for @journalMood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get journalMood;

  /// No description provided for @journalEnergy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get journalEnergy;

  /// No description provided for @journalSleepQuality.
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get journalSleepQuality;

  /// No description provided for @journalStress.
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get journalStress;

  /// No description provided for @journalFeltNote.
  ///
  /// In en, this message translates to:
  /// **'What did you feel?'**
  String get journalFeltNote;

  /// No description provided for @journalNeededNote.
  ///
  /// In en, this message translates to:
  /// **'What did you need?'**
  String get journalNeededNote;

  /// No description provided for @journalThoughtNote.
  ///
  /// In en, this message translates to:
  /// **'What were your thoughts?'**
  String get journalThoughtNote;

  /// No description provided for @journalTags.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get journalTags;

  /// No description provided for @supportTitle.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get supportTitle;

  /// No description provided for @noSupportContactsTitle.
  ///
  /// In en, this message translates to:
  /// **'No support contacts'**
  String get noSupportContactsTitle;

  /// No description provided for @noSupportContactsMessage.
  ///
  /// In en, this message translates to:
  /// **'Add people you can rely on when things get tough.'**
  String get noSupportContactsMessage;

  /// No description provided for @addSupportContact.
  ///
  /// In en, this message translates to:
  /// **'Add contact'**
  String get addSupportContact;

  /// No description provided for @editSupportContact.
  ///
  /// In en, this message translates to:
  /// **'Edit contact'**
  String get editSupportContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get contactPhone;

  /// No description provided for @contactMessageTemplate.
  ///
  /// In en, this message translates to:
  /// **'Message template (optional)'**
  String get contactMessageTemplate;

  /// No description provided for @contactMessageHint.
  ///
  /// In en, this message translates to:
  /// **'I\'m having a hard time, can we talk?'**
  String get contactMessageHint;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete contact'**
  String get deleteContact;

  /// No description provided for @deleteContactMessage.
  ///
  /// In en, this message translates to:
  /// **'Remove this contact?'**
  String get deleteContactMessage;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
