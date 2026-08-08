import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/toolbox_repository.dart';

class DeleteToolAction implements UseCase<void, String> {
  DeleteToolAction(this.repository);
  final ToolboxRepository repository;

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteToolAction(params);
  }
}
