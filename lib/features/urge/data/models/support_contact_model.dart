import 'package:hive/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/support_contact.dart';

class SupportContactModel {
  final String id;
  final String name;
  final String phone;
  final String messageTemplate;

  const SupportContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.messageTemplate,
  });

  factory SupportContactModel.fromEntity(SupportContact contact) =>
      SupportContactModel(
        id: contact.id,
        name: contact.name,
        phone: contact.phone,
        messageTemplate: contact.messageTemplate,
      );

  SupportContact toEntity() => SupportContact(
        id: id,
        name: name,
        phone: phone,
        messageTemplate: messageTemplate,
      );
}

class SupportContactModelAdapter extends TypeAdapter<SupportContactModel> {
  @override
  final int typeId = HiveTypeIds.supportContact;

  @override
  SupportContactModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < fieldCount; i++) reader.readByte(): reader.read(),
    };
    return SupportContactModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      messageTemplate: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SupportContactModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.messageTemplate);
  }
}
