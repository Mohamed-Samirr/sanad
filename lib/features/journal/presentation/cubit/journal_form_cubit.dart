import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/usecases/save_journal_entry.dart';

enum JournalFormStatus { initial, saving, success, failure }

class JournalFormState extends Equatable {
  final JournalFormStatus status;
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
  final String? errorMessage;

  const JournalFormState({
    this.status = JournalFormStatus.initial,
    required this.id,
    required this.date,
    this.mood = 3,
    this.energy = 3,
    this.sleepQuality = 3,
    this.stress = 3,
    this.feltNote,
    this.neededNote,
    this.thoughtNote,
    this.tags = const [],
    this.errorMessage,
  });

  JournalFormState copyWith({
    JournalFormStatus? status,
    DateTime? date,
    int? mood,
    int? energy,
    int? sleepQuality,
    int? stress,
    String? feltNote,
    String? neededNote,
    String? thoughtNote,
    List<String>? tags,
    String? errorMessage,
  }) {
    return JournalFormState(
      status: status ?? this.status,
      id: id,
      date: date ?? this.date,
      mood: mood ?? this.mood,
      energy: energy ?? this.energy,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stress: stress ?? this.stress,
      feltNote: feltNote ?? this.feltNote,
      neededNote: neededNote ?? this.neededNote,
      thoughtNote: thoughtNote ?? this.thoughtNote,
      tags: tags ?? this.tags,
      errorMessage: errorMessage, // intentional clear
    );
  }

  @override
  List<Object?> get props => [
        status,
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
        errorMessage,
      ];
}

class JournalFormCubit extends Cubit<JournalFormState> {
  final SaveJournalEntry saveJournalEntry;

  JournalFormCubit({
    required this.saveJournalEntry,
    JournalEntry? initialEntry,
  }) : super(initialEntry != null
            ? JournalFormState(
                id: initialEntry.id,
                date: initialEntry.date,
                mood: initialEntry.mood,
                energy: initialEntry.energy,
                sleepQuality: initialEntry.sleepQuality,
                stress: initialEntry.stress,
                feltNote: initialEntry.feltNote,
                neededNote: initialEntry.neededNote,
                thoughtNote: initialEntry.thoughtNote,
                tags: initialEntry.tags,
              )
            : JournalFormState(
                id: const Uuid().v4(),
                date: DateTime.now(),
              ));

  void updateDate(DateTime date) => emit(state.copyWith(date: date));
  void updateMood(int mood) => emit(state.copyWith(mood: mood));
  void updateEnergy(int energy) => emit(state.copyWith(energy: energy));
  void updateSleepQuality(int sleepQuality) => emit(state.copyWith(sleepQuality: sleepQuality));
  void updateStress(int stress) => emit(state.copyWith(stress: stress));
  void updateFeltNote(String note) => emit(state.copyWith(feltNote: note));
  void updateNeededNote(String note) => emit(state.copyWith(neededNote: note));
  void updateThoughtNote(String note) => emit(state.copyWith(thoughtNote: note));
  
  void addTag(String tag) {
    if (!state.tags.contains(tag) && tag.trim().isNotEmpty) {
      emit(state.copyWith(tags: [...state.tags, tag.trim()]));
    }
  }

  void removeTag(String tag) {
    final updated = List<String>.from(state.tags)..remove(tag);
    emit(state.copyWith(tags: updated));
  }

  Future<void> save() async {
    emit(state.copyWith(status: JournalFormStatus.saving));
    
    final entry = JournalEntry(
      id: state.id,
      date: state.date,
      mood: state.mood,
      energy: state.energy,
      sleepQuality: state.sleepQuality,
      stress: state.stress,
      feltNote: state.feltNote,
      neededNote: state.neededNote,
      thoughtNote: state.thoughtNote,
      tags: state.tags,
    );

    final result = await saveJournalEntry(entry);
    result.fold(
      (failure) => emit(state.copyWith(
        status: JournalFormStatus.failure,
        errorMessage: 'Failed to save entry',
      )),
      (_) => emit(state.copyWith(status: JournalFormStatus.success)),
    );
  }
}
