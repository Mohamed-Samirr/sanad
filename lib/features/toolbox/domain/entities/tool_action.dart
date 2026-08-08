import 'package:equatable/equatable.dart';

class ToolAction extends Equatable {
  const ToolAction({
    required this.id,
    required this.title,
    required this.description,
    required this.durationMin,
    required this.iconCode,
    required this.category,
    required this.timesUsed,
    required this.timesWorked,
  });

  final String id;
  final String title;
  final String description;
  final int durationMin;
  final int iconCode;
  
  /// e.g. 'physical', 'mental', 'social'
  final String category;
  
  final int timesUsed;
  final int timesWorked;

  ToolAction copyWith({
    String? title,
    String? description,
    int? durationMin,
    int? iconCode,
    String? category,
    int? timesUsed,
    int? timesWorked,
  }) {
    return ToolAction(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationMin: durationMin ?? this.durationMin,
      iconCode: iconCode ?? this.iconCode,
      category: category ?? this.category,
      timesUsed: timesUsed ?? this.timesUsed,
      timesWorked: timesWorked ?? this.timesWorked,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        durationMin,
        iconCode,
        category,
        timesUsed,
        timesWorked,
      ];
}
