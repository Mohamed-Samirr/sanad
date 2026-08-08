import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/app_settings.dart';

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = HiveTypeIds.appSettings;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      locale: fields[0] as String?,
      themeMode: fields[1] as String? ?? 'system',
      lockEnabled: fields[2] as bool? ?? false,
      reminderTimeMinutes: fields[3] as int?,
      smartRemindersEnabled: fields[4] as bool? ?? false,
      firstDayOfWeek: fields[5] as int?,
      onboardingDone: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.locale)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.lockEnabled)
      ..writeByte(3)
      ..write(obj.reminderTimeMinutes)
      ..writeByte(4)
      ..write(obj.smartRemindersEnabled)
      ..writeByte(5)
      ..write(obj.firstDayOfWeek)
      ..writeByte(6)
      ..write(obj.onboardingDone);
  }
}
