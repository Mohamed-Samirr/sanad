import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/hive_constants.dart';
import 'data/datasources/habit_local_data_source.dart';
import 'data/models/habit_log_model.dart';
import 'data/models/habit_model.dart';
import 'data/repositories/habit_repository_impl.dart';
import 'domain/repositories/habit_repository.dart';
import 'domain/services/health_score_calculator.dart';
import 'domain/usecases/delete_habit.dart';
import 'domain/usecases/get_habit_detail.dart';
import 'domain/usecases/get_habit_summaries.dart';
import 'domain/usecases/save_habit.dart';
import 'domain/usecases/toggle_habit_log.dart';
import 'presentation/cubit/habit_detail_cubit.dart';
import 'presentation/cubit/habits_cubit.dart';

final sl = GetIt.instance;

/// Call once from `main()` after `Hive.initFlutter()`.
Future<void> initHabitsFeature() async {
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

  sl.registerLazySingleton(() => GetHabitSummaries(sl(), sl()));
  sl.registerLazySingleton(() => GetHabitDetail(sl(), sl()));
  sl.registerLazySingleton(() => ToggleHabitLog(sl()));
  sl.registerLazySingleton(() => SaveHabit(sl()));
  sl.registerLazySingleton(() => DeleteHabit(sl()));
  sl.registerLazySingleton(() => ArchiveHabit(sl()));

  sl.registerFactory(
    () => HabitsCubit(
      getHabitSummaries: sl(),
      toggleHabitLog: sl(),
      repository: sl(),
    ),
  );
}

/// The detail cubit needs a habit id, so it is built per route.
HabitDetailCubit buildHabitDetailCubit(String habitId) => HabitDetailCubit(
      habitId: habitId,
      getHabitDetail: sl(),
      toggleHabitLog: sl(),
      deleteHabit: sl(),
      archiveHabit: sl(),
      repository: sl(),
    );
