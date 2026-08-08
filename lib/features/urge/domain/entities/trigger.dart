import 'package:equatable/equatable.dart';

class Trigger extends Equatable {
  final String id;
  final String label;
  final bool isCustom;

  const Trigger({
    required this.id,
    required this.label,
    this.isCustom = false,
  });

  @override
  List<Object?> get props => [id, label, isCustom];
}
