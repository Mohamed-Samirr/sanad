import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/support_repository.dart';

class DeleteSupportContact implements UseCase<void, String> {
  final SupportRepository repository;

  DeleteSupportContact(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteContact(params);
  }
}
