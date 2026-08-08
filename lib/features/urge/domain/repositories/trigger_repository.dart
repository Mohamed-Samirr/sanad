import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/trigger.dart';

abstract class TriggerRepository {
  Future<Either<Failure, List<Trigger>>> getTriggers();
  Future<Either<Failure, void>> saveTrigger(Trigger trigger);
  Future<Either<Failure, void>> deleteTrigger(String id);
  Stream<void> watchTriggers();
}
