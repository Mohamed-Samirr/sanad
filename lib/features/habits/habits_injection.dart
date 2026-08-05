import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/hive_constants.dart';
import '../../core/services/notification_service.dart';
import '../../core/usecase/usecase.dart';
import 'data/datasources/habit_local_data_source.dart';
import 'data/models/habit_log_model.dart';
import 'data/models/habit_model.dart';
import 'data/repositories/habit_repository_impl.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/services/habit_reminder_scheduler.dart';
import 'domain/services/health_score_calculator.dart';
import 'domain/usecases/clear_habit_log.dart';
import 'domain/usecases/delete_habit.dart';
import 'domain/usecases/get_archived_habits.dart';
import 'domain/usecases/get_habit_detail.dart';
import 'domain/usecases/get_habit_summaries.dart';
import 'domain/usecases/request_reminder_permission.dart';
import 'domain/usecases/restore_habit.dart';
import 'domain/usecases/save_habit.dart';
import 'domain/usecases/sync_habit_reminders.dart';
import 'domain/usecases/set_habit_log.dart';
import 'domain/usecases/toggle_habit_log.dart';
import 'domain_exports.dart';
import 'presentation/cubit/archived_habits_cubit.dart';
import 'presentation/cubit/habit_detail_cubit.dart';
import 'presentation/cubit/habit_form_cubit.dart';
import 'presentation/cubit/habits_cubit.dart';

final sl = GetIt.instance;

/// Keeps the reminder schedule in step with the habits. Held at module level
/// so a re-init (a test's `setUp`, mostly) replaces it instead of stacking up
/// listeners on a box that has since been closed.
StreamSubscription<void>? _reminderSyncSub;

/// Call once from `main()` after `Hive.initFlutter()`.
Future<void> initHabitsFeature() async {
  await _reminderSyncSub?.cancel();
  _reminderSyncSub = null;

  if (!Hive.isAdapterRegistered(HiveTypeIds.habit)) {
    Hive.registerAdapter(HabitModelAdapter());
  }
  if (!Hive.isAdapterRegistered(HiveTypeIds.habitLog)) {
    Hive.registerAdapter(HabitLogModelAdapter());
  }

  final habitBox = await Hive.openBox<HabitModel>(HiveBoxes.habits);
  final logBox = await Hive.openBox<HabitLogModel>(HiveBoxes.habitLogs);

  sl.registerLazySingleton<HabitLocalDataSource>(
    () => HabitLocalDataSourceImpl(habitBox: habitBox, logBox: logBox),
  );
  sl.registerLazySingleton<HabitRepository>(
    () => HabitRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<HealthScoreCalculator>(
    () => const HealthScoreCalculator(),
  );
  sl.registerLazySingleton<HabitReminderScheduler>(
    () => NotificationService(),
  );

  sl.registerLazySingleton(() => GetHabitSummaries(sl(), sl()));
  sl.registerLazySingleton(() => GetHabitDetail(sl(), sl()));
  sl.registerLazySingleton(() => ToggleHabitLog(sl()));
  sl.registerLazySingleton(() => SetHabitLog(sl()));
  sl.registerLazySingleton(() => ClearHabitLog(sl()));
  sl.registerLazySingleton(() => SaveHabit(sl()));
  sl.registerLazySingleton(() => DeleteHabit(sl()));
  sl.registerLazySingleton(() => ArchiveHabit(sl()));
  sl.registerLazySingleton(() => RestoreHabit(sl()));
  sl.registerLazySingleton(() => GetArchivedHabits(sl()));
  sl.registerLazySingleton(() => SyncHabitReminders(sl(), sl()));
  sl.registerLazySingleton(() => RequestReminderPermission(sl()));

  sl.registerFactory(
    () => HabitsCubit(
      getHabitSummaries: sl(),
      toggleHabitLog: sl(),
      setHabitLog: sl(),
      clearHabitLog: sl(),
      repository: sl(),
    ),
  );

  // Reminders follow the habits rather than being rescheduled by hand at each
  // call site. Create, edit, delete, archive and restore all land here as one
  // change event, which is the only way the schedule and the habits cannot
  // drift apart.
  _reminderSyncSub = sl<HabitRepository>().watchChanges().listen((_) {
    sl<SyncHabitReminders>()(const NoParams());
  });

  // Top up the window on every launch: reminders are only written
  // [kReminderWindowDays] ahead, and a device that changed timezone while the
  // app was closed needs its schedule rebuilt against the new local clock.
  //
  // Deliberately not awaited. This talks to platform channels and writes one
  // alarm per occurrence, none of which the first frame depends on — blocking
  // startup on it would trade a visible cold start for invisible work.
  unawaited(sl<SyncHabitReminders>()(const NoParams()));
}

/// Built per route rather than registered as a factory so it is disposed
/// with the screen and its watchChanges subscription goes with it.
ArchivedHabitsCubit buildArchivedHabitsCubit() => ArchivedHabitsCubit(
      getArchivedHabits: sl(),
      restoreHabit: sl(),
      deleteHabit: sl(),
      repository: sl(),
    );

/// Releases the feature-level subscription installed by [initHabitsFeature].
///
/// The app never needs this — it lives as long as the process. Tests do:
/// closing a Hive box while this listener is still attached leaves the box
/// watcher firing into a torn-down world, which is what made teardown crawl.
Future<void> disposeHabitsFeature() async {
  await _reminderSyncSub?.cancel();
  _reminderSyncSub = null;
}

/// The form cubit is seeded with the habit being edited, so it is built per
/// route. A null [initial] means the form is creating.
HabitFormCubit buildHabitFormCubit(Habit? initial) => HabitFormCubit(
      saveHabit: sl(),
      requestReminderPermission: sl(),
      initial: initial,
    );

/// The detail cubit needs a habit id, so it is built per route.
HabitDetailCubit buildHabitDetailCubit(String habitId) => HabitDetailCubit(
      habitId: habitId,
      getHabitDetail: sl(),
      setHabitLog: sl(),
      clearHabitLog: sl(),
      deleteHabit: sl(),
      archiveHabit: sl(),
      repository: sl(),
    );
