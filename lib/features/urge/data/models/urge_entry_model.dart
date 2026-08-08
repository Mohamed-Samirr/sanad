import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/urge_entry.dart';

class UrgeEntryModel {
  final String id;
  final String behaviorId;
  final DateTime timestamp;
  final int intensity;
  final List<String> triggers;
  final List<String> feelings;
  final String? note;
  final int chosenStrategyIndex;
  final String? toolActionId;
  final int? delayDurationSec;
  final int? outcomeIndex;
  final DateTime? outcomeAt;
  final String? reflectionNote;

  const UrgeEntryModel({
    required this.id,
    required this.behaviorId,
    required this.timestamp,
    required this.intensity,
    required this.triggers,
    required this.feelings,
    this.note,
    required this.chosenStrategyIndex,
    this.toolActionId,
    this.delayDurationSec,
    this.outcomeIndex,
    this.outcomeAt,
    this.reflectionNote,
  });

  factory UrgeEntryModel.fromEntity(UrgeEntry entry) => UrgeEntryModel(
        id: entry.id,
        behaviorId: entry.behaviorId,
        timestamp: entry.timestamp,
        intensity: entry.intensity,
        triggers: entry.triggers,
        feelings: entry.feelings,
        note: entry.note,
        chosenStrategyIndex: entry.chosenStrategy.index,
        toolActionId: entry.toolActionId,
        delayDurationSec: entry.delayDurationSec,
        outcomeIndex: entry.outcome?.index,
        outcomeAt: entry.outcomeAt,
        reflectionNote: entry.reflectionNote,
      );

  UrgeEntry toEntity() => UrgeEntry(
        id: id,
        behaviorId: behaviorId,
        timestamp: timestamp,
        intensity: intensity,
        triggers: triggers,
        feelings: feelings,
        note: note,
        chosenStrategy: UrgeStrategy.values[chosenStrategyIndex],
        toolActionId: toolActionId,
        delayDurationSec: delayDurationSec,
        outcome: outcomeIndex != null ? UrgeOutcome.values[outcomeIndex!] : null,
        outcomeAt: outcomeAt,
        reflectionNote: reflectionNote,
      );
}

class UrgeEntryModelAdapter extends TypeAdapter<UrgeEntryModel> {
  @override
  final int typeId = HiveTypeIds.urgeEntry;

  @override
  UrgeEntryModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return UrgeEntryModel(
      id: fields[0] as String,
      behaviorId: fields[1] as String,
      timestamp: fields[2] as DateTime,
      intensity: fields[3] as int,
      triggers: (fields[4] as List).cast<String>(),
      feelings: (fields[5] as List).cast<String>(),
      note: fields[6] as String?,
      chosenStrategyIndex: fields[7] as int,
      toolActionId: fields[8] as String?,
      delayDurationSec: fields[9] as int?,
      outcomeIndex: fields[10] as int?,
      outcomeAt: fields[11] as DateTime?,
      reflectionNote: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UrgeEntryModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.behaviorId)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.intensity)
      ..writeByte(4)
      ..write(obj.triggers)
      ..writeByte(5)
      ..write(obj.feelings)
      ..writeByte(6)
      ..write(obj.note)
      ..writeByte(7)
      ..write(obj.chosenStrategyIndex)
      ..writeByte(8)
      ..write(obj.toolActionId)
      ..writeByte(9)
      ..write(obj.delayDurationSec)
      ..writeByte(10)
      ..write(obj.outcomeIndex)
      ..writeByte(11)
      ..write(obj.outcomeAt)
      ..writeByte(12)
      ..write(obj.reflectionNote);
  }
}
