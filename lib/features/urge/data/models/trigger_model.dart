import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/trigger.dart';

class TriggerModel {
  final String id;
  final String label;
  final bool isCustom;

  const TriggerModel({
    required this.id,
    required this.label,
    required this.isCustom,
  });

  factory TriggerModel.fromEntity(Trigger trigger) => TriggerModel(
        id: trigger.id,
        label: trigger.label,
        isCustom: trigger.isCustom,
      );

  Trigger toEntity() => Trigger(
        id: id,
        label: label,
        isCustom: isCustom,
      );
}

class TriggerModelAdapter extends TypeAdapter<TriggerModel> {
  @override
  final int typeId = HiveTypeIds.trigger;

  @override
  TriggerModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return TriggerModel(
      id: fields[0] as String,
      label: fields[1] as String,
      isCustom: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, TriggerModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.label)
      ..writeByte(2)
      ..write(obj.isCustom);
  }
}
