import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/urge_entry.dart';
import '../repositories/urge_repository.dart';

class GetActiveUrge implements UseCase<UrgeEntry?, NoParams> {
  final UrgeRepository repository;

  GetActiveUrge(this.repository);

  @override
  Future<Either<Failure, UrgeEntry?>> call(NoParams params) async {
    return await repository.getActiveUrge();
  }
}
