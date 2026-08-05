import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../features/habits/domain/services/habit_reminder_scheduler.dart';

/// Platform side of habit reminders.
///
/// ## Why one-shot notifications instead of a repeating rule
///
/// A repeating notification ("every day at 08:00") is anchored to a timezone.
/// Getting the device's IANA zone name needs a third package, and without one
/// `timezone` falls back to UTC — which would quietly fire every reminder at
/// the wrong hour, and drift by another hour at each DST boundary.
///
/// So each occurrence is scheduled individually at an absolute instant derived
/// from a local wall-clock `DateTime`. Dart resolves that against the OS's own
/// zone rules, which already know about DST, so a reminder set for 08:00 stays
/// at 08:00 on both sides of a transition. The cost is that the schedule only
/// reaches [kReminderWindowDays] ahead and has to be topped up — which happens
/// on every app start and on every habit change.
class NotificationService implements HabitReminderScheduler {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'habit_reminders';
  static const String _channelName = 'Habit reminders';
  static const String _channelDescription =
      'Nudges for the habits you asked to be reminded about.';

  /// Occurrence ids are packed into the habit's id, so this bounds how many
  /// each habit may hold before its ids would run into the next habit's.
  static const int _maxOccurrencesPerHabit = 32;

  bool _initialised = false;
  bool _unavailable = false;

  /// Every platform call goes through here.
  ///
  /// Notifications sit on top of a local tracker that works without them, so a
  /// missing plugin — a test harness, a desktop build, a platform with no
  /// notification centre — must degrade to "no reminders" rather than take the
  /// app down. Callers get null and decide what that means.
  Future<T?> _guard<T>(Future<T?> Function() action) async {
    if (_unavailable) return null;
    try {
      return await action();
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    if (_initialised || _unavailable) return;

    try {
      // `tz.local` is a `late` field only assigned here. Scheduling always
      // uses `tz.UTC`, but the plugin can touch `tz.local` internally and
      // reading it unassigned throws.
      tz_data.initializeTimeZones();

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Every request flag is off. Permission is asked for later, at the
          // moment a reminder is actually set — never as a side effect of
          // launching the app.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );

      _initialised = true;
    } catch (_) {
      _unavailable = true;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  bool get _supported => !_unavailable && (Platform.isAndroid || Platform.isIOS);

  @override
  Future<bool> ensurePermission() async {
    await init();
    if (!_supported) return false;

    final granted = await _guard<bool>(() async {
      if (Platform.isAndroid) {
        return await _android?.requestNotificationsPermission();
      }
      return await _ios?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    });

    return granted ?? false;
  }

  @override
  Future<bool> hasPermission() async {
    await init();
    if (!_supported) return false;

    final enabled = await _guard<bool>(() async {
      if (Platform.isAndroid) {
        return await _android?.areNotificationsEnabled();
      }
      return (await _ios?.checkPermissions())?.isEnabled;
    });

    return enabled ?? false;
  }

  @override
  Future<void> cancelAll() async {
    await init();
    if (!_supported) return;
    await _guard(() => _plugin.cancelAll());
  }

  @override
  Future<void> syncReminders(List<HabitReminder> reminders) async {
    await init();
    if (!_supported) return;

    // A full rebuild. Cancelling first is what stops reminders for deleted,
    // archived or rescheduled habits surviving as orphans — otherwise their
    // ids stay pending until they fire.
    await _guard(() => _plugin.cancelAll());

    for (final reminder in reminders) {
      final base = _baseId(reminder.habitId);
      final occurrences =
          reminder.occurrences.take(_maxOccurrencesPerHabit).toList();

      for (var index = 0; index < occurrences.length; index++) {
        await _guard(
          () => _schedule(
            id: base * _maxOccurrencesPerHabit + index,
            at: occurrences[index],
            reminder: reminder,
          ),
        );
      }
    }
  }

  Future<void> _schedule({
    required int id,
    required DateTime at,
    required HabitReminder reminder,
  }) async {
    // `at` is local wall-clock. `toUtc()` turns it into the absolute instant
    // to fire at, applying whichever DST offset is in force on that day.
    final instant = tz.TZDateTime.from(at.toUtc(), tz.UTC);

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: instant,
      title: reminder.habitName,
      body: reminder.targetNote ?? 'A good moment for this one.',
      payload: reminder.habitId,
      // Inexact on purpose. Exact alarms need SCHEDULE_EXACT_ALARM, which the
      // Play Store gates behind a declared justification, and a habit nudge
      // does not need to-the-second delivery to do its job.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  /// Stable, positive, and small enough that
  /// `base * _maxOccurrencesPerHabit + index` still fits a 32-bit id.
  static int _baseId(String habitId) => habitId.hashCode & 0x7FFFFF;
}
