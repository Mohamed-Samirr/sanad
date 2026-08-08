import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/trigger.dart';
import '../repositories/trigger_repository.dart';

class GetTriggers implements UseCase<List<Trigger>, NoParams> {
  final TriggerRepository repository;

  GetTriggers(this.repository);

  @override
  Future<Either<Failure, List<Trigger>>> call(NoParams params) async {
    return await repository.getTriggers();
  }
}
