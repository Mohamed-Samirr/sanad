import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/repositories/journal_repository.dart';
import '../datasources/journal_local_data_source.dart';
import '../models/journal_model.dart';

class JournalRepositoryImpl implements JournalRepository {
  final JournalLocalDataSource localDataSource;

  JournalRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<JournalEntry>>> getEntries() async {
    try {
      final models = await localDataSource.getEntries();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveEntry(JournalEntry entry) async {
    try {
      final model = JournalModel.fromEntity(entry);
      await localDataSource.saveEntry(model);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteEntry(String id) async {
    try {
      await localDataSource.deleteEntry(id);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure());
    } catch (e) {
      return const Left(UnexpectedFailure());
    }
  }

  @override
  Stream<void> watchChanges() {
    return localDataSource.watchChanges();
  }
}
