import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/tool_action.dart';

abstract class ToolboxRepository {
  Future<Either<Failure, List<ToolAction>>> getToolActions();
  Future<Either<Failure, void>> saveToolAction(ToolAction action);
  Future<Either<Failure, void>> deleteToolAction(String id);
  Stream<void> watchToolActions();
}
