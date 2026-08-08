import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/tool_action.dart';
import '../repositories/toolbox_repository.dart';

class GetToolboxActions implements UseCase<List<ToolAction>, NoParams> {
  GetToolboxActions(this.repository);
  final ToolboxRepository repository;

  @override
  Future<Either<Failure, List<ToolAction>>> call(NoParams params) async {
    return await repository.getToolActions();
  }
}
