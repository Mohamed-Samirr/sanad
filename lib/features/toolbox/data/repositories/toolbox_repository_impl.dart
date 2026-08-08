import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/tool_action.dart';
import '../../domain/repositories/toolbox_repository.dart';

class ToolboxRepositoryImpl implements ToolboxRepository {
  Future<Box<ToolAction>> _getBox() async {
    if (Hive.isBoxOpen(HiveBoxes.toolbox)) {
      return Hive.box<ToolAction>(HiveBoxes.toolbox);
    }
    return await Hive.openBox<ToolAction>(HiveBoxes.toolbox);
  }

  @override
  Future<Either<Failure, List<ToolAction>>> getToolActions() async {
    try {
      final box = await _getBox();
      return Right(box.values.toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveToolAction(ToolAction action) async {
    try {
      final box = await _getBox();
      await box.put(action.id, action);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteToolAction(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<void> watchToolActions() async* {
    final box = await _getBox();
    yield null; // emit initial value
    yield* box.watch().map((_) {});
  }
}
