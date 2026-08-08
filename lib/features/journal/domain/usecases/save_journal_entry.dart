import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/journal_entry.dart';
import '../repositories/journal_repository.dart';

class SaveJournalEntry implements UseCase<void, JournalEntry> {
  final JournalRepository repository;

  SaveJournalEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(JournalEntry params) async {
    return await repository.saveEntry(params);
  }
}
