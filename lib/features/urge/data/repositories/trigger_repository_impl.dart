import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/trigger.dart';
import '../../domain/repositories/trigger_repository.dart';
import '../models/trigger_model.dart';

class TriggerRepositoryImpl implements TriggerRepository {
  Box<TriggerModel> get _box => Hive.box<TriggerModel>(HiveBoxes.triggers);

  @override
  Future<Either<Failure, List<Trigger>>> getTriggers() async {
    try {
      final triggers = _box.values.map((model) => model.toEntity()).toList();
      return Right(triggers);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveTrigger(Trigger trigger) async {
    try {
      await _box.put(trigger.id, TriggerModel.fromEntity(trigger));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrigger(String id) async {
    try {
      await _box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<void> watchTriggers() {
    return _box.watch().map((_) {});
  }
}
