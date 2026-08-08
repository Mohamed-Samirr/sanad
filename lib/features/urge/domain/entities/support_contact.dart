import 'package:equatable/equatable.dart';

class SupportContact extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String messageTemplate;

  const SupportContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.messageTemplate,
  });

  @override
  List<Object?> get props => [id, name, phone, messageTemplate];
}
