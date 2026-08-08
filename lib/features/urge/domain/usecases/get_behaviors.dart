import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/behavior.dart';
import '../repositories/behavior_repository.dart';

class GetBehaviors implements UseCase<List<Behavior>, NoParams> {
  final BehaviorRepository repository;

  GetBehaviors(this.repository);

  @override
  Future<Either<Failure, List<Behavior>>> call(NoParams params) async {
    return await repository.getBehaviors();
  }
}
