import 'package:equatable/equatable.dart';

class Behavior extends Equatable {
  final String id;
  final String name;
  final int iconCode;
  final String colorHex;
  final String whyStatement;
  final DateTime startDate;
  final DateTime createdAt;
  final bool isArchived;

  const Behavior({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.whyStatement,
    required this.startDate,
    required this.createdAt,
    this.isArchived = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        iconCode,
        colorHex,
        whyStatement,
        startDate,
        createdAt,
        isArchived,
      ];
}
