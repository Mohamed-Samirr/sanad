import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/behavior.dart';
import '../../domain/repositories/behavior_repository.dart';
import '../models/behavior_model.dart';

class BehaviorRepositoryImpl implements BehaviorRepository {
  Box<BehaviorModel> get _box => Hive.box<BehaviorModel>(HiveBoxes.behaviors);

  @override
  Future<Either<Failure, List<Behavior>>> getBehaviors() async {
    try {
      final behaviors = _box.values.map((model) => model.toEntity()).toList();
      return Right(behaviors);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveBehavior(Behavior behavior) async {
    try {
      await _box.put(behavior.id, BehaviorModel.fromEntity(behavior));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBehavior(String id) async {
    try {
      await _box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<void> watchBehaviors() {
    return _box.watch().map((_) {});
  }
}
