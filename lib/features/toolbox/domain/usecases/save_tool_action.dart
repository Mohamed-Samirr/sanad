import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/tool_action.dart';
import '../repositories/toolbox_repository.dart';

class SaveToolAction implements UseCase<void, ToolAction> {
  SaveToolAction(this.repository);
  final ToolboxRepository repository;

  @override
  Future<Either<Failure, void>> call(ToolAction params) async {
    if (params.title.trim().isEmpty) {
      return const Left(ValidationFailure('Title is required', code: FailureCode.nameRequired));
    }
    return await repository.saveToolAction(params);
  }
}
