import 'package:equatable/equatable.dart';

enum UrgeStrategy { delay, fight, reachOut, none }
enum UrgeOutcome { passed, ongoing, actedOn }

class UrgeEntry extends Equatable {
  final String id;
  final String behaviorId;
  final DateTime timestamp;
  final int intensity; // 1-10
  final List<String> triggers;
  final List<String> feelings;
  final String? note;
  
  final UrgeStrategy chosenStrategy;
  final String? toolActionId;
  final int? delayDurationSec;
  
  final UrgeOutcome? outcome;
  final DateTime? outcomeAt;
  final String? reflectionNote;

  const UrgeEntry({
    required this.id,
    required this.behaviorId,
    required this.timestamp,
    required this.intensity,
    required this.triggers,
    required this.feelings,
    this.note,
    this.chosenStrategy = UrgeStrategy.none,
    this.toolActionId,
    this.delayDurationSec,
    this.outcome,
    this.outcomeAt,
    this.reflectionNote,
  });

  UrgeEntry copyWith({
    String? id,
    String? behaviorId,
    DateTime? timestamp,
    int? intensity,
    List<String>? triggers,
    List<String>? feelings,
    String? note,
    UrgeStrategy? chosenStrategy,
    String? toolActionId,
    int? delayDurationSec,
    UrgeOutcome? outcome,
    DateTime? outcomeAt,
    String? reflectionNote,
  }) {
    return UrgeEntry(
      id: id ?? this.id,
      behaviorId: behaviorId ?? this.behaviorId,
      timestamp: timestamp ?? this.timestamp,
      intensity: intensity ?? this.intensity,
      triggers: triggers ?? this.triggers,
      feelings: feelings ?? this.feelings,
      note: note ?? this.note,
      chosenStrategy: chosenStrategy ?? this.chosenStrategy,
      toolActionId: toolActionId ?? this.toolActionId,
      delayDurationSec: delayDurationSec ?? this.delayDurationSec,
      outcome: outcome ?? this.outcome,
      outcomeAt: outcomeAt ?? this.outcomeAt,
      reflectionNote: reflectionNote ?? this.reflectionNote,
    );
  }

  @override
  List<Object?> get props => [
        id,
        behaviorId,
        timestamp,
        intensity,
        triggers,
        feelings,
        note,
        chosenStrategy,
        toolActionId,
        delayDurationSec,
        outcome,
        outcomeAt,
        reflectionNote,
      ];
}
