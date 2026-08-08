import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String id;
  final DateTime date;
  
  // Scales 1-5
  final int mood;
  final int energy;
  final int sleepQuality;
  final int stress;
  
  final String? feltNote;
  final String? neededNote;
  final String? thoughtNote;
  final List<String> tags;

  const JournalEntry({
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

  @override
  List<Object?> get props => [
        id,
        date,
        mood,
        energy,
        sleepQuality,
        stress,
        feltNote,
        neededNote,
        thoughtNote,
        tags,
      ];
}
