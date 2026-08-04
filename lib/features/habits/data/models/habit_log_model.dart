import 'package:hive/hive.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../domain_exports.dart';

class HabitLogModel {
  final String habitId;
  final DateTime date;
  final int statusIndex;
  final String? note;
  final DateTime loggedAt;

  const HabitLogModel({
    required this.habitId,
    required this.date,
    required this.statusIndex,
    required this.loggedAt,
    this.note,
  });

  factory HabitLogModel.fromEntity(HabitLog log) => HabitLogModel(
        habitId: log.habitId,
        date: log.date,
        statusIndex: log.status.index,
        note: log.note,
        loggedAt: log.loggedAt,
      );

  HabitLog toEntity() => HabitLog(
        habitId: habitId,
        date: date,
        status: HabitLogStatus.values[statusIndex],
        note: note,
        loggedAt: loggedAt,
      );
}

class HabitLogModelAdapter extends TypeAdapter<HabitLogModel> {
  @override
  final int typeId = HiveTypeIds.habitLog;

  @override
  HabitLogModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return HabitLogModel(
      habitId: fields[0] as String,
      date: fields[1] as DateTime,
      statusIndex: fields[2] as int,
      note: fields[3] as String?,
      loggedAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, HabitLogModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.habitId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.statusIndex)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.loggedAt);
  }
}
