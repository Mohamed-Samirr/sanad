import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/journal_entry.dart';

class JournalModel extends HiveObject {
  final String id;
  final DateTime date;
  final int mood;
  final int energy;
  final int sleepQuality;
  final int stress;
  final String? feltNote;
  final String? neededNote;
  final String? thoughtNote;
  final List<String> tags;

  JournalModel({
    required this.id,
    required this.date,
    required this.mood,
    required this.energy,
    required this.sleepQuality,
    required this.stress,
    this.feltNote,
    this.neededNote,
    this.thoughtNote,
    this.tags = const [],
  });

  factory JournalModel.fromEntity(JournalEntry entity) {
    return JournalModel(
      id: entity.id,
      date: entity.date,
      mood: entity.mood,
      energy: entity.energy,
      sleepQuality: entity.sleepQuality,
      stress: entity.stress,
      feltNote: entity.feltNote,
      neededNote: entity.neededNote,
      thoughtNote: entity.thoughtNote,
      tags: entity.tags,
    );
  }

  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      date: date,
      mood: mood,
      energy: energy,
      sleepQuality: sleepQuality,
      stress: stress,
      feltNote: feltNote,
      neededNote: neededNote,
      thoughtNote: thoughtNote,
      tags: tags,
    );
  }
}

class JournalModelAdapter extends TypeAdapter<JournalModel> {
  @override
  final int typeId = HiveTypeIds.journalEntry;

  @override
  JournalModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JournalModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      mood: fields[2] as int,
      energy: fields[3] as int,
      sleepQuality: fields[4] as int,
      stress: fields[5] as int,
      feltNote: fields[6] as String?,
      neededNote: fields[7] as String?,
      thoughtNote: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, JournalModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.mood)
      ..writeByte(3)
      ..write(obj.energy)
      ..writeByte(4)
      ..write(obj.sleepQuality)
      ..writeByte(5)
      ..write(obj.stress)
      ..writeByte(6)
      ..write(obj.feltNote)
      ..writeByte(7)
      ..write(obj.neededNote)
      ..writeByte(8)
      ..write(obj.thoughtNote)
      ..writeByte(9)
      ..write(obj.tags);
  }
}
