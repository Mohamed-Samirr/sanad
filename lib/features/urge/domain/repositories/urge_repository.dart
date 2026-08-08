import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/urge_entry.dart';

abstract class UrgeRepository {
  Future<Either<Failure, UrgeEntry?>> getActiveUrge();
  Future<Either<Failure, void>> saveUrge(UrgeEntry entry);
  Future<Either<Failure, void>> clearActiveUrge();
  Future<Either<Failure, List<UrgeEntry>>> getUrgeHistory();
  Stream<UrgeEntry?> watchActiveUrge();
  Stream<void> watchUrges();
}
