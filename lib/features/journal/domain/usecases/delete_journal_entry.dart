import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/journal_repository.dart';

class DeleteJournalEntry implements UseCase<void, String> {
  final JournalRepository repository;

  DeleteJournalEntry(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteEntry(params);
  }
}
