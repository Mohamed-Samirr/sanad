import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/behavior.dart';

class BehaviorModel {
  final String id;
  final String name;
  final int iconCode;
  final String colorHex;
  final String whyStatement;
  final DateTime startDate;
  final DateTime createdAt;
  final bool isArchived;

  const BehaviorModel({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.whyStatement,
    required this.startDate,
    required this.createdAt,
    required this.isArchived,
  });

  factory BehaviorModel.fromEntity(Behavior behavior) => BehaviorModel(
        id: behavior.id,
        name: behavior.name,
        iconCode: behavior.iconCode,
        colorHex: behavior.colorHex,
        whyStatement: behavior.whyStatement,
        startDate: behavior.startDate,
        createdAt: behavior.createdAt,
        isArchived: behavior.isArchived,
      );

  Behavior toEntity() => Behavior(
        id: id,
        name: name,
        iconCode: iconCode,
        colorHex: colorHex,
        whyStatement: whyStatement,
        startDate: startDate,
        createdAt: createdAt,
        isArchived: isArchived,
      );
}

class BehaviorModelAdapter extends TypeAdapter<BehaviorModel> {
  @override
  final int typeId = HiveTypeIds.behavior;

  @override
  BehaviorModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return BehaviorModel(
      id: fields[0] as String,
      name: fields[1] as String,
      iconCode: fields[2] as int,
      colorHex: fields[3] as String,
      whyStatement: fields[4] as String,
      startDate: fields[5] as DateTime,
      createdAt: fields[6] as DateTime,
      isArchived: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BehaviorModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorHex)
      ..writeByte(4)
      ..write(obj.whyStatement)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.isArchived);
  }
}
