import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/tool_action.dart';

class ToolActionAdapter extends TypeAdapter<ToolAction> {
  @override
  final int typeId = HiveTypeIds.toolAction;

  @override
  ToolAction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ToolAction(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      durationMin: fields[3] as int,
      iconCode: fields[4] as int,
      category: fields[5] as String,
      timesUsed: fields[6] as int,
      timesWorked: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ToolAction obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.durationMin)
      ..writeByte(4)
      ..write(obj.iconCode)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.timesUsed)
      ..writeByte(7)
      ..write(obj.timesWorked);
  }
}
