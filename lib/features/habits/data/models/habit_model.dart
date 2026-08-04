import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../domain_exports.dart';

/// Storage representation of [Habit].
/// The adapter is hand-written on purpose: no build_runner step is needed and
/// the binary layout stays explicit, which matters for future migrations.
class HabitModel {
  final String id;
  final String name;
  final int iconCodePoint;
  final String colorHex;
  final int timeOfDayIndex;
  final int scheduleTypeIndex;
  final List<int> scheduledWeekdays;
  final int? timesPerWeek;
  final String? targetNote;
  final int? reminderMinutes;
  final DateTime startDate;
  final bool isArchived;
  final String? linkedToolActionId;

  const HabitModel({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorHex,
    required this.timeOfDayIndex,
    required this.scheduleTypeIndex,
    required this.scheduledWeekdays,
    required this.startDate,
    required this.isArchived,
    this.timesPerWeek,
    this.targetNote,
    this.reminderMinutes,
    this.linkedToolActionId,
  });

  factory HabitModel.fromEntity(Habit habit) => HabitModel(
        id: habit.id,
        name: habit.name,
        iconCodePoint: habit.iconCodePoint,
        colorHex: habit.colorHex,
        timeOfDayIndex: habit.timeOfDay.index,
        scheduleTypeIndex: habit.scheduleType.index,
        scheduledWeekdays: habit.scheduledWeekdays,
        timesPerWeek: habit.timesPerWeek,
        targetNote: habit.targetNote,
        reminderMinutes: habit.reminderMinutes,
        startDate: habit.startDate,
        isArchived: habit.isArchived,
        linkedToolActionId: habit.linkedToolActionId,
      );

  Habit toEntity() => Habit(
        id: id,
        name: name,
        iconCodePoint: iconCodePoint,
        colorHex: colorHex,
        timeOfDay: HabitTimeOfDay.values[timeOfDayIndex],
        scheduleType: HabitScheduleType.values[scheduleTypeIndex],
        scheduledWeekdays: List<int>.from(scheduledWeekdays),
        timesPerWeek: timesPerWeek,
        targetNote: targetNote,
        reminderMinutes: reminderMinutes,
        startDate: startDate,
        isArchived: isArchived,
        linkedToolActionId: linkedToolActionId,
      );
}

class HabitModelAdapter extends TypeAdapter<HabitModel> {
  @override
  final int typeId = HiveTypeIds.habit;

  @override
  HabitModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return HabitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCodePoint: fields[2] as int,
      colorHex: fields[3] as String,
      timeOfDayIndex: fields[4] as int,
      scheduleTypeIndex: fields[5] as int,
      scheduledWeekdays: (fields[6] as List).cast<int>(),
      timesPerWeek: fields[7] as int?,
      targetNote: fields[8] as String?,
      reminderMinutes: fields[9] as int?,
      startDate: fields[10] as DateTime,
      isArchived: fields[11] as bool,
      linkedToolActionId: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HabitModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCodePoint)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.timeOfDayIndex)
      ..writeByte(5)
      ..write(obj.scheduleTypeIndex)
      ..writeByte(6)
      ..write(obj.scheduledWeekdays)
      ..writeByte(7)
      ..write(obj.timesPerWeek)
      ..writeByte(8)
      ..write(obj.targetNote)
      ..writeByte(9)
      ..write(obj.reminderMinutes)
      ..writeByte(10)
      ..write(obj.startDate)
      ..writeByte(11)
      ..write(obj.isArchived)
      ..writeByte(12)
      ..write(obj.linkedToolActionId);
  }
}
