// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Sanad';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get addHabit => 'Add a habit';

  @override
  String get noHabitsTitle => 'No habits yet';

  @override
  String get noHabitsMessage => 'Start with one small action you can repeat tomorrow. You can promote any toolbox action into a tracked habit.';

  @override
  String get nothingScheduledToday => 'Nothing scheduled today.';

  @override
  String doneOfDueToday(int done, int due) {
    return '$done of $due done today';
  }

  @override
  String doneOfDueTodaySemantics(int done, int due) {
    return '$done of $due habits done today';
  }

  @override
  String get skipToday => 'Skip today';

  @override
  String get skipTodayDescription => 'A rest day you chose. Your streak holds.';

  @override
  String get clearTodayEntry => 'Clear today\'s entry';

  @override
  String get editHabit => 'Edit habit';

  @override
  String get openDetails => 'Open details';

  @override
  String get timeOfDayMorning => 'Morning';

  @override
  String get timeOfDayAfternoon => 'Afternoon';

  @override
  String get timeOfDayEvening => 'Evening';

  @override
  String get timeOfDayAnytime => 'Anytime';

  @override
  String get removeHabit => 'Remove habit';

  @override
  String get habitCouldNotOpenTitle => 'This habit could not be opened';

  @override
  String get habitCouldNotOpenMessage => 'Try again from the habits list.';

  @override
  String get goBack => 'Go back';

  @override
  String get removeThisHabitTitle => 'Remove this habit';

  @override
  String get removeThisHabitMessage => 'Archiving keeps the history and hides the habit from your list. Deleting removes every logged day for good.';

  @override
  String get archiveHabit => 'Archive habit';

  @override
  String get deletePermanently => 'Delete permanently';

  @override
  String get healthTrendTitle => 'Health trend · last 30 days';

  @override
  String get trendHoldingSteady => 'Holding steady against last week.';

  @override
  String trendUp(int points) {
    return 'Up $points points on last week\'s average.';
  }

  @override
  String trendDown(int points) {
    return 'Down $points points on last week\'s average.';
  }

  @override
  String get completionCalendarTitle => 'Completion calendar';

  @override
  String get recentEntriesTitle => 'Recent entries';

  @override
  String get recentEntriesSubtitle => 'Newest first. Tap one to change it.';

  @override
  String get notEnoughTrendData => 'Log a few more days and the trend line will show up here.';

  @override
  String get chartRiskLabel => 'check-in';

  @override
  String get statVsLastWeek => 'vs last week';

  @override
  String statDaysRatio(int done, int total) {
    return '$done/$total days';
  }

  @override
  String statBest(int best) {
    return 'best $best';
  }

  @override
  String sinceDate(String date) {
    return 'Since $date';
  }

  @override
  String get newHabitTitle => 'New habit';

  @override
  String get editHabitTitle => 'Edit habit';

  @override
  String get save => 'Save';

  @override
  String get saving => 'Saving…';

  @override
  String get formNameSection => 'What are you building?';

  @override
  String get formNameHint => 'Morning walk';

  @override
  String get formAppearanceSection => 'Icon and colour';

  @override
  String get formColourLabel => 'Colour';

  @override
  String get formIconSemantics => 'Habit icon';

  @override
  String get formColourSemantics => 'Habit colour';

  @override
  String get formScheduleSection => 'How often?';

  @override
  String get scheduleDaily => 'Every day';

  @override
  String get scheduleWeekdays => 'Certain days';

  @override
  String get scheduleTimesPerWeek => 'Times a week';

  @override
  String timesPerWeekExplain(int count) {
    return 'Any $count days that suit you. A day only counts against you once the week can no longer reach the target.';
  }

  @override
  String daysPerWeekLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days a week',
      one: 'day a week',
    );
    return '$_temp0';
  }

  @override
  String get fewerDays => 'Fewer days';

  @override
  String get moreDays => 'More days';

  @override
  String get formTimeOfDaySection => 'When in the day?';

  @override
  String get formDetailsSection => 'Details';

  @override
  String get formTargetLabel => 'Target (optional)';

  @override
  String get formTargetHint => '30 minutes, 5 pages';

  @override
  String get formReminderLabel => 'Reminder';

  @override
  String get formReminderOff => 'Off';

  @override
  String get formTurnReminderOff => 'Turn reminder off';

  @override
  String get formStartDateLabel => 'Start date';

  @override
  String get formStartDateLockedNote => 'The start date stays put so your logged history keeps its shape.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get startTracking => 'Start tracking';

  @override
  String get dayNotRecordedYet => 'Not recorded yet.';

  @override
  String get dayNotScheduled => 'Not scheduled on this day.';

  @override
  String get dayMarkedDone => 'Marked done.';

  @override
  String get dayMarkedSkipped => 'Marked as skipped.';

  @override
  String get markDone => 'Mark done';

  @override
  String get markDoneDescription => 'You did it on this day.';

  @override
  String get markSkipped => 'Mark skipped';

  @override
  String get markSkippedDescription => 'A deliberate rest day. Your streak keeps running.';

  @override
  String get clearThisDay => 'Clear this day';

  @override
  String get clearThisDayDescription => 'Remove the entry and leave the day blank.';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get noteHint => 'What made the difference today?';

  @override
  String get noteSavedWithChoice => 'The note is saved with whichever option you pick.';

  @override
  String get nothingLoggedYet => 'Nothing logged yet. Tap any day on the calendar to record it, and add a note if something is worth remembering.';

  @override
  String get statusDone => 'Done';

  @override
  String get statusSkipped => 'Skipped';

  @override
  String moreInCalendar(int count) {
    return '+$count more in the calendar above.';
  }

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String get legendDone => 'Done';

  @override
  String get legendSkipped => 'Skipped';

  @override
  String get legendMissed => 'Missed';

  @override
  String dayCellSemantics(String date, String state) {
    return '$date, $state';
  }

  @override
  String get dayStateDone => 'done';

  @override
  String get dayStateSkipped => 'skipped';

  @override
  String get dayStateUpcoming => 'upcoming';

  @override
  String get dayStateNotScheduled => 'not scheduled';

  @override
  String get dayStateMissed => 'missed';

  @override
  String get archivedHabitsTitle => 'Archived habits';

  @override
  String get nothingArchivedTitle => 'Nothing archived';

  @override
  String get nothingArchivedMessage => 'Habits you archive land here with their history intact. You can bring any of them back whenever you want.';

  @override
  String get backToHabits => 'Back to habits';

  @override
  String loggedDaysSince(int count, String date) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logged days',
      one: '$count logged day',
    );
    return '$_temp0 · since $date';
  }

  @override
  String get noLoggedDaysYet => 'No logged days yet';

  @override
  String get restore => 'Restore';

  @override
  String get delete => 'Delete';

  @override
  String deleteHabitTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deleteWithHistoryMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Every one of the $count logged days recorded for this habit is deleted with it.',
      one: 'Every one of the $count logged day recorded for this habit is deleted with it.',
    );
    return '$_temp0 That part cannot be undone.';
  }

  @override
  String get deleteNoHistoryMessage => 'This habit has no logged days. It will be removed for good.';

  @override
  String get keepIt => 'Keep it';

  @override
  String get continueLabel => 'Continue';

  @override
  String get permanentTitle => 'This is permanent';

  @override
  String permanentMessage(int count, String name) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count logged days will be erased.',
      one: '$count logged day will be erased.',
    );
    return '$_temp0 If you only want $name off your list, it is already archived — you can leave it here instead.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get deleteForever => 'Delete forever';

  @override
  String restoredMessage(String name) {
    return '$name is back on your list.';
  }

  @override
  String deletedMessage(String name) {
    return '$name and its history were deleted.';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHabitsSection => 'Habits';

  @override
  String get settingsArchivedLabel => 'Archived habits';

  @override
  String get settingsArchivedDescription => 'Restore one, or delete it and its history.';

  @override
  String get settingsAboutSection => 'About this app';

  @override
  String get disclaimer => 'Sanad is a self-tracking tool. It is not medical treatment and it does not replace a doctor or a therapist. If things feel severe or unsafe, talking to a professional is the right step, and reaching for it is not a failure of anything you have built here.';

  @override
  String get onboardingTitle => 'Welcome to Sanad';

  @override
  String get onboardingDefensiveTitle => 'Defend';

  @override
  String get onboardingDefensiveText => 'Log an urge the moment it hits. Delay it, fight it with your tools, or reach out.';

  @override
  String get onboardingOffensiveTitle => 'Build';

  @override
  String get onboardingOffensiveText => 'Track the constructive habits you want to build and see your progress over time.';

  @override
  String get onboardingCTA => 'Get Started';

  @override
  String get toolboxTitle => 'Toolbox';

  @override
  String get noToolsTitle => 'Your toolbox is empty';

  @override
  String get noToolsMessage => 'Add things that help you ride out an urge, like a breathing exercise, calling a friend, or taking a walk.';

  @override
  String get addTool => 'Add tool';

  @override
  String get editToolTitle => 'Edit tool';

  @override
  String get newToolTitle => 'New tool';

  @override
  String get toolNameHint => 'Tool name';

  @override
  String get toolDescriptionHint => 'How do you do it?';

  @override
  String get toolDurationLabel => 'Duration (minutes)';

  @override
  String get toolCategoryLabel => 'Category';

  @override
  String get deleteTool => 'Delete tool';

  @override
  String get deleteToolMessage => 'Remove this tool from your toolbox?';

  @override
  String get checkDoneToday => 'Done today';

  @override
  String get checkMarkDone => 'Mark done';

  @override
  String streakSemantics(int days) {
    return '$days day streak';
  }

  @override
  String get failureNameRequired => 'Give the habit a name.';

  @override
  String get failureWeekdayRequired => 'Pick at least one day of the week.';

  @override
  String get failureWeeklyTargetRange => 'Set a weekly target between 1 and 7.';

  @override
  String get failureFutureDay => 'You cannot log a day that has not happened yet.';

  @override
  String get failureCache => 'Could not reach local storage.';

  @override
  String get failureNotFound => 'This habit no longer exists.';

  @override
  String get failureUnexpected => 'Something went wrong.';

  @override
  String get reminderPermissionDenied => 'Reminders need notification permission. You can turn it on in your device settings and set this again.';

  @override
  String get reminderPermissionUnavailable => 'Could not reach the notification settings.';

  @override
  String get journalTitle => 'Journal';

  @override
  String get noJournalEntriesTitle => 'No journal entries';

  @override
  String get noJournalEntriesMessage => 'Write your first entry to reflect on how you\'re doing.';

  @override
  String get addJournalEntry => 'Add entry';

  @override
  String get editJournalEntry => 'Edit entry';

  @override
  String get journalMood => 'Mood';

  @override
  String get journalEnergy => 'Energy';

  @override
  String get journalSleepQuality => 'Sleep Quality';

  @override
  String get journalStress => 'Stress';

  @override
  String get journalFeltNote => 'What did you feel?';

  @override
  String get journalNeededNote => 'What did you need?';

  @override
  String get journalThoughtNote => 'What were your thoughts?';

  @override
  String get journalTags => 'Tags (comma separated)';

  @override
  String get supportTitle => 'Support';

  @override
  String get noSupportContactsTitle => 'No support contacts';

  @override
  String get noSupportContactsMessage => 'Add people you can rely on when things get tough.';

  @override
  String get addSupportContact => 'Add contact';

  @override
  String get editSupportContact => 'Edit contact';

  @override
  String get contactName => 'Name';

  @override
  String get contactPhone => 'Phone number';

  @override
  String get contactMessageTemplate => 'Message template (optional)';

  @override
  String get contactMessageHint => 'I\'m having a hard time, can we talk?';

  @override
  String get deleteContact => 'Delete contact';

  @override
  String get deleteContactMessage => 'Remove this contact?';
}
