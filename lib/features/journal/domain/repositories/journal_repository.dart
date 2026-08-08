import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/journal_entry.dart';

abstract class JournalRepository {
  Future<Either<Failure, List<JournalEntry>>> getEntries();
  Future<Either<Failure, void>> saveEntry(JournalEntry entry);
  Future<Either<Failure, void>> deleteEntry(String id);
  Stream<void> watchChanges();
}
