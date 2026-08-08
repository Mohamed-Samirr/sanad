import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/behavior.dart';

abstract class BehaviorRepository {
  Future<Either<Failure, List<Behavior>>> getBehaviors();
  Future<Either<Failure, void>> saveBehavior(Behavior behavior);
  Future<Either<Failure, void>> deleteBehavior(String id);
  Stream<void> watchBehaviors();
}
