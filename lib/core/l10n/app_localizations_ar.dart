import 'app_localizations.dart';

/// Arabic strings — the default locale.
///
/// Same tone rules as the English: a missed day is a data point, never a
/// verdict, and a skip is described as a decision the user made rather than
/// something that happened to them.
class AppLocalizationsAr extends AppLocalizations {
  const AppLocalizationsAr();

  @override
  String get appTitle => 'سند';

  @override
  String get habitsTitle => 'العادات';
  @override
  String get settingsTooltip => 'الإعدادات';
  @override
  String get addHabit => 'أضف عادة';
  @override
  String get noHabitsTitle => 'لا توجد عادات بعد';
  @override
  String get noHabitsMessage =>
      'ابدأ بخطوة صغيرة واحدة تقدر تكررها بكرة. وتقدر تحوّل أي إجراء من صندوق '
      'أدواتك إلى عادة متابَعة.';
  @override
  String get nothingScheduledToday => 'لا يوجد شيء مجدول اليوم.';
  @override
  String doneOfDueToday(int done, int due) => 'أنجزت $done من $due اليوم';
  @override
  String doneOfDueTodaySemantics(int done, int due) =>
      'أنجزت $done من $due عادة اليوم';
  @override
  String get skipToday => 'تخطَّ اليوم';
  @override
  String get skipTodayDescription => 'يوم راحة باختيارك. سلسلتك مستمرة.';
  @override
  String get clearTodayEntry => 'امسح تسجيل اليوم';
  @override
  String get editHabit => 'تعديل العادة';
  @override
  String get openDetails => 'فتح التفاصيل';

  @override
  String get timeOfDayMorning => 'الصباح';
  @override
  String get timeOfDayAfternoon => 'الظهيرة';
  @override
  String get timeOfDayEvening => 'المساء';
  @override
  String get timeOfDayAnytime => 'أي وقت';

  @override
  String get removeHabit => 'إزالة العادة';
  @override
  String get habitCouldNotOpenTitle => 'تعذّر فتح هذه العادة';
  @override
  String get habitCouldNotOpenMessage => 'حاول مرة أخرى من قائمة العادات.';
  @override
  String get goBack => 'رجوع';
  @override
  String get removeThisHabitTitle => 'إزالة هذه العادة';
  @override
  String get removeThisHabitMessage =>
      'الأرشفة تحتفظ بالسجل وتخفي العادة من قائمتك. أما الحذف فيزيل كل يوم '
      'مسجَّل نهائيًا.';
  @override
  String get archiveHabit => 'أرشفة العادة';
  @override
  String get deletePermanently => 'حذف نهائي';
  @override
  String get healthTrendTitle => 'مؤشر الحالة · آخر ٣٠ يومًا';
  @override
  String get trendHoldingSteady => 'ثابت مقارنة بالأسبوع الماضي.';
  @override
  String trendUp(int points) => 'أعلى بـ $points نقطة عن متوسط الأسبوع الماضي.';
  @override
  String trendDown(int points) => 'أقل بـ $points نقطة عن متوسط الأسبوع الماضي.';
  @override
  String get completionCalendarTitle => 'تقويم الإنجاز';
  @override
  String get recentEntriesTitle => 'آخر التسجيلات';
  @override
  String get recentEntriesSubtitle => 'الأحدث أولًا. اضغط على أي واحد لتعديله.';
  @override
  String get notEnoughTrendData =>
      'سجّل أيامًا أكثر قليلًا وسيظهر خط المؤشر هنا.';
  @override
  String get chartRiskLabel => 'وقفة مراجعة';
  @override
  String get statVsLastWeek => 'عن الأسبوع الماضي';
  @override
  String statDaysRatio(int done, int total) => '$done/$total يوم';
  @override
  String statBest(int best) => 'الأفضل $best';
  @override
  String sinceDate(String date) => 'منذ $date';

  @override
  String get newHabitTitle => 'عادة جديدة';
  @override
  String get editHabitTitle => 'تعديل العادة';
  @override
  String get save => 'حفظ';
  @override
  String get saving => 'جارٍ الحفظ…';
  @override
  String get formNameSection => 'ما الذي تبنيه؟';
  @override
  String get formNameHint => 'مشي الصباح';
  @override
  String get formAppearanceSection => 'الأيقونة واللون';
  @override
  String get formColourLabel => 'اللون';
  @override
  String get formIconSemantics => 'أيقونة العادة';
  @override
  String get formColourSemantics => 'لون العادة';
  @override
  String get formScheduleSection => 'كم مرة؟';
  @override
  String get scheduleDaily => 'كل يوم';
  @override
  String get scheduleWeekdays => 'أيام محددة';
  @override
  String get scheduleTimesPerWeek => 'مرات في الأسبوع';
  @override
  String timesPerWeekExplain(int count) =>
      'أي $count أيام تناسبك. اليوم لا يُحسب عليك إلا حين يصبح بلوغ الهدف في '
      'هذا الأسبوع غير ممكن.';
  @override
  String daysPerWeekLabel(int count) => count == 1 ? 'يوم أسبوعيًا' : 'أيام أسبوعيًا';
  @override
  String get fewerDays => 'أيام أقل';
  @override
  String get moreDays => 'أيام أكثر';
  @override
  String get formTimeOfDaySection => 'في أي وقت من اليوم؟';
  @override
  String get formDetailsSection => 'تفاصيل';
  @override
  String get formTargetLabel => 'الهدف (اختياري)';
  @override
  String get formTargetHint => '٣٠ دقيقة، ٥ صفحات';
  @override
  String get formReminderLabel => 'تذكير';
  @override
  String get formReminderOff => 'مغلق';
  @override
  String get formTurnReminderOff => 'إيقاف التذكير';
  @override
  String get formStartDateLabel => 'تاريخ البداية';
  @override
  String get formStartDateLockedNote =>
      'تاريخ البداية يبقى كما هو حتى يحتفظ سجلك بشكله.';
  @override
  String get saveChanges => 'حفظ التعديلات';
  @override
  String get startTracking => 'ابدأ المتابعة';

  @override
  String get dayNotRecordedYet => 'لم يُسجَّل بعد.';
  @override
  String get dayNotScheduled => 'غير مجدول في هذا اليوم.';
  @override
  String get dayMarkedDone => 'مسجَّل كمنجَز.';
  @override
  String get dayMarkedSkipped => 'مسجَّل كيوم متخطَّى.';
  @override
  String get markDone => 'تسجيل كمنجَز';
  @override
  String get markDoneDescription => 'أنجزته في هذا اليوم.';
  @override
  String get markSkipped => 'تسجيل كمتخطَّى';
  @override
  String get markSkippedDescription => 'يوم راحة مقصود. سلسلتك تستمر.';
  @override
  String get clearThisDay => 'مسح هذا اليوم';
  @override
  String get clearThisDayDescription => 'احذف التسجيل واترك اليوم فارغًا.';
  @override
  String get noteOptional => 'ملاحظة (اختياري)';
  @override
  String get noteHint => 'ما الذي أحدث الفرق اليوم؟';
  @override
  String get noteSavedWithChoice => 'تُحفظ الملاحظة مع أي خيار تختاره.';

  @override
  String get nothingLoggedYet =>
      'لا يوجد تسجيل بعد. اضغط على أي يوم في التقويم لتسجيله، وأضف ملاحظة إن '
      'كان هناك ما يستحق التذكر.';
  @override
  String get statusDone => 'منجَز';
  @override
  String get statusSkipped => 'متخطَّى';
  @override
  String moreInCalendar(int count) => '+$count في التقويم بالأعلى.';

  @override
  String get previousMonth => 'الشهر السابق';
  @override
  String get nextMonth => 'الشهر التالي';
  @override
  String get legendDone => 'منجَز';
  @override
  String get legendSkipped => 'متخطَّى';
  @override
  String get legendMissed => 'فائت';
  @override
  String dayCellSemantics(String date, String state) => '$date، $state';
  @override
  String get dayStateDone => 'منجَز';
  @override
  String get dayStateSkipped => 'متخطَّى';
  @override
  String get dayStateUpcoming => 'قادم';
  @override
  String get dayStateNotScheduled => 'غير مجدول';
  @override
  String get dayStateMissed => 'فائت';

  @override
  String get archivedHabitsTitle => 'العادات المؤرشفة';
  @override
  String get nothingArchivedTitle => 'لا يوجد شيء مؤرشف';
  @override
  String get nothingArchivedMessage =>
      'العادات التي تؤرشفها تصل هنا بسجلها كاملًا. تقدر ترجّع أي واحدة منها '
      'في أي وقت.';
  @override
  String get backToHabits => 'العودة إلى العادات';
  @override
  String loggedDaysSince(int count, String date) =>
      '$count يوم مسجَّل · منذ $date';
  @override
  String get noLoggedDaysYet => 'لا توجد أيام مسجَّلة بعد';
  @override
  String get restore => 'استرجاع';
  @override
  String get delete => 'حذف';
  @override
  String deleteHabitTitle(String name) => 'حذف $name؟';
  @override
  String deleteWithHistoryMessage(int count) =>
      'كل الأيام المسجَّلة لهذه العادة وعددها $count ستُحذف معها. هذا الجزء لا '
      'يمكن التراجع عنه.';
  @override
  String get deleteNoHistoryMessage =>
      'هذه العادة ليس لها أيام مسجَّلة. ستُزال نهائيًا.';
  @override
  String get keepIt => 'الاحتفاظ بها';
  @override
  String get continueLabel => 'متابعة';
  @override
  String get permanentTitle => 'هذا الإجراء نهائي';
  @override
  String permanentMessage(int count, String name) =>
      'سيُمحى $count يوم مسجَّل. إن كنت تريد فقط إبعاد $name عن قائمتك، فهي '
      'مؤرشفة بالفعل — تقدر تسيبها هنا.';
  @override
  String get cancel => 'إلغاء';
  @override
  String get deleteForever => 'حذف نهائي';
  @override
  String restoredMessage(String name) => '$name رجعت إلى قائمتك.';
  @override
  String deletedMessage(String name) => 'تم حذف $name وسجلها.';

  @override
  String get settingsTitle => 'الإعدادات';
  @override
  String get settingsHabitsSection => 'العادات';
  @override
  String get settingsArchivedLabel => 'العادات المؤرشفة';
  @override
  String get settingsArchivedDescription =>
      'استرجع واحدة، أو احذفها هي وسجلها.';
  @override
  String get settingsAboutSection => 'عن التطبيق';

  @override
  String get disclaimer =>
      'سند أداة للمتابعة الذاتية. هو ليس علاجًا طبيًا ولا يغني عن طبيب أو معالج. إن كان الأمر شديدًا أو غير آمن، فالحديث مع مختص هو الخطوة الصحيحة، واللجوء إليه ليس فشلًا في أي شيء بنيته هنا.';

  @override
  String get onboardingTitle => 'مرحباً بك في سند';

  @override
  String get onboardingDefensiveTitle => 'دافع';

  @override
  String get onboardingDefensiveText => 'سجل الرغبة بمجرد شعورك بها. أجلها، قاومها بأدواتك، أو اطلب الدعم.';

  @override
  String get onboardingOffensiveTitle => 'ابنِ';

  @override
  String get onboardingOffensiveText => 'تتبع العادات الإيجابية التي تود بناءها وشاهد تقدمك بمرور الوقت.';

  @override
  String get onboardingCTA => 'ابدأ الآن';

  @override
  String get toolboxTitle => 'صندوق الأدوات';

  @override
  String get noToolsTitle => 'صندوقك فارغ';

  @override
  String get noToolsMessage => 'أضف ما يساعدك على مقاومة الرغبة، كتمرين تنفس، أو الاتصال بصديق، أو المشي.';

  @override
  String get addTool => 'إضافة أداة';

  @override
  String get editToolTitle => 'تعديل الأداة';

  @override
  String get newToolTitle => 'أداة جديدة';

  @override
  String get toolNameHint => 'اسم الأداة';

  @override
  String get toolDescriptionHint => 'كيف تنفذها؟';

  @override
  String get toolDurationLabel => 'المدة (بالدقائق)';

  @override
  String get toolCategoryLabel => 'التصنيف';

  @override
  String get deleteTool => 'حذف الأداة';

  @override
  String get deleteToolMessage => 'إزالة هذه الأداة من الصندوق؟';

  @override
  String get checkDoneToday => 'منجَز اليوم';
  @override
  String get checkMarkDone => 'تسجيل كمنجَز';
  @override
  String streakSemantics(int days) => 'سلسلة $days يوم';

  @override
  String get failureNameRequired => 'اكتب اسمًا للعادة.';
  @override
  String get failureWeekdayRequired => 'اختر يومًا واحدًا على الأقل في الأسبوع.';
  @override
  String get failureWeeklyTargetRange => 'حدد هدفًا أسبوعيًا بين ١ و ٧.';
  @override
  String get failureFutureDay => 'لا يمكن تسجيل يوم لم يأتِ بعد.';
  @override
  String get failureCache => 'تعذّر الوصول إلى التخزين المحلي.';
  @override
  String get failureNotFound => 'هذه العادة لم تعد موجودة.';
  @override
  String get failureUnexpected => 'حدث خطأ ما.';
  @override
  String get reminderPermissionDenied =>
      'التذكيرات تحتاج إذن الإشعارات. تقدر تفعّله من إعدادات جهازك وتضبطه '
      'مرة أخرى.';
  @override
  String get reminderPermissionUnavailable => 'تعذر الوصول إلى إعدادات الإشعارات.';

  @override
  String get journalTitle => 'اليوميات';
  @override
  String get noJournalEntriesTitle => 'لا توجد يوميات';
  @override
  String get noJournalEntriesMessage => 'اكتب أول تدوينة لك لتتأمل في مشاعرك وحالتك.';
  @override
  String get addJournalEntry => 'إضافة تدوينة';
  @override
  String get editJournalEntry => 'تعديل التدوينة';
  @override
  String get journalMood => 'المزاج';
  @override
  String get journalEnergy => 'الطاقة';
  @override
  String get journalSleepQuality => 'جودة النوم';
  @override
  String get journalStress => 'التوتر';
  @override
  String get journalFeltNote => 'بماذا شعرت؟';
  @override
  String get journalNeededNote => 'ماذا احتجت؟';
  @override
  String get journalThoughtNote => 'بماذا فكرت؟';
  @override
  String get journalTags => 'العلامات (مفصولة بفاصلة)';

  @override
  String get supportTitle => 'الدعم';
  @override
  String get noSupportContactsTitle => 'لا توجد جهات اتصال';
  @override
  String get noSupportContactsMessage => 'أضف أشخاصاً يمكنك الاعتماد عليهم في الأوقات الصعبة.';
  @override
  String get addSupportContact => 'إضافة جهة اتصال';
  @override
  String get editSupportContact => 'تعديل جهة الاتصال';
  @override
  String get contactName => 'الاسم';
  @override
  String get contactPhone => 'رقم الهاتف';
  @override
  String get contactMessageTemplate => 'قالب الرسالة (اختياري)';
  @override
  String get contactMessageHint => 'أنا أمر بوقت صعب، هل يمكننا التحدث؟';
  @override
  String get deleteContact => 'حذف جهة الاتصال';
  @override
  String get deleteContactMessage => 'هل تريد إزالة جهة الاتصال هذه؟';

  @override
  List<String> get monthNames => const [
        'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
        'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
      ];

  @override
  List<String> get weekdayNamesShort => const [
        'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد',
      ];

  /// Arabic weeks start on Saturday.
  @override
  int get firstWeekday => DateTime.saturday;
}
