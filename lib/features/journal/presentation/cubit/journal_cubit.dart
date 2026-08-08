import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/usecases/delete_journal_entry.dart';
import '../../domain/usecases/get_journal_entries.dart';
import 'journal_state.dart';

class JournalCubit extends Cubit<JournalState> {
  final GetJournalEntries getJournalEntries;
  final DeleteJournalEntry deleteJournalEntry;
  final JournalRepository repository;
  
  StreamSubscription? _subscription;

  JournalCubit({
    required this.getJournalEntries,
    required this.deleteJournalEntry,
    required this.repository,
  }) : super(const JournalState()) {
    _subscription = repository.watchChanges().listen((_) {
      loadEntries();
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadEntries() async {
    emit(state.copyWith(status: JournalStatus.loading));
    final result = await getJournalEntries(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Failed to load journal entries.',
      )),
      (entries) => emit(state.copyWith(
        status: JournalStatus.success,
        entries: entries,
      )),
    );
  }

  Future<void> deleteEntry(String id) async {
    final result = await deleteJournalEntry(id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: JournalStatus.failure,
        errorMessage: 'Failed to delete entry.',
      )),
      (_) {
        // We do not manually reload here because watchChanges() will trigger a reload.
      },
    );
  }
}
