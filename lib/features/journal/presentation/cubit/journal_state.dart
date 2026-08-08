import 'package:equatable/equatable.dart';
import '../../domain/entities/journal_entry.dart';

enum JournalStatus { initial, loading, success, failure }

class JournalState extends Equatable {
  final JournalStatus status;
  final List<JournalEntry> entries;
  final String? errorMessage;

  const JournalState({
    this.status = JournalStatus.initial,
    this.entries = const [],
    this.errorMessage,
  });

  JournalState copyWith({
    JournalStatus? status,
    List<JournalEntry>? entries,
    String? errorMessage,
  }) {
    return JournalState(
      status: status ?? this.status,
      entries: entries ?? this.entries,
      errorMessage: errorMessage, // Intentional clear if null
    );
  }

  @override
  List<Object?> get props => [status, entries, errorMessage];
}
