import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/urge_repository.dart';

class ClearActiveUrge implements UseCase<void, NoParams> {
  final UrgeRepository repository;

  ClearActiveUrge(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.clearActiveUrge();
  }
}
