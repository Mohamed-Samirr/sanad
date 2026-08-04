import 'dart:async';

import 'package:hive/hive.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/date_utils.dart';
import '../models/habit_log_model.dart';
import '../models/habit_model.dart';

abstract class HabitLocalDataSource {
  List<HabitModel> getHabits();
  HabitModel getHabitById(String id);
  Future<void> putHabit(HabitModel habit);
  Future<void> deleteHabit(String id);

  List<HabitLogModel> getLogsForHabit(String habitId);
  List<HabitLogModel> getAllLogs();
  Future<void> putLog(HabitLogModel log);
  Future<void> deleteLog(String habitId, DateTime date);

  Stream<void> watchChanges();
}

class HabitLocalDataSourceImpl implements HabitLocalDataSource {
  final Box<HabitModel> habitBox;
  final Box<HabitLogModel> logBox;

  HabitLocalDataSourceImpl({required this.habitBox, required this.logBox});

  static String logKey(String habitId, DateTime date) =>
      '${habitId}_${AppDateUtils.dayKey(date)}';

  @override
  List<HabitModel> getHabits() {
    try {
      return habitBox.values.toList();
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  HabitModel getHabitById(String id) {
    final habit = habitBox.get(id);
    if (habit == null) throw NotFoundException();
    return habit;
  }

  @override
  Future<void> putHabit(HabitModel habit) async {
    try {
      await habitBox.put(habit.id, habit);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteHabit(String id) async {
    try {
      final logKeys = logBox.keys.where(
        (key) => key is String && key.startsWith('${id}_'),
      );
      await logBox.deleteAll(logKeys.toList());
      await habitBox.delete(id);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  List<HabitLogModel> getLogsForHabit(String habitId) {
    try {
      return logBox.values.where((log) => log.habitId == habitId).toList();
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  List<HabitLogModel> getAllLogs() {
    try {
      return logBox.values.toList();
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> putLog(HabitLogModel log) async {
    try {
      await logBox.put(logKey(log.habitId, log.date), log);
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteLog(String habitId, DateTime date) async {
    try {
      await logBox.delete(logKey(habitId, date));
    } catch (_) {
      throw CacheException();
    }
  }

  @override
  Stream<void> watchChanges() {
    final controller = StreamController<void>.broadcast();
    final habitSub = habitBox.watch().listen((_) => controller.add(null));
    final logSub = logBox.watch().listen((_) => controller.add(null));
    controller.onCancel = () {
      habitSub.cancel();
      logSub.cancel();
    };
    return controller.stream;
  }
}
