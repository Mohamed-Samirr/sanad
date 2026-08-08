import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/urge_entry.dart';
import '../repositories/urge_repository.dart';

class SaveUrge implements UseCase<void, UrgeEntry> {
  final UrgeRepository repository;

  SaveUrge(this.repository);

  @override
  Future<Either<Failure, void>> call(UrgeEntry params) async {
    return await repository.saveUrge(params);
  }
}
