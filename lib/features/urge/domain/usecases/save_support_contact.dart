import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/support_contact.dart';
import '../repositories/support_repository.dart';

class SaveSupportContact implements UseCase<void, SupportContact> {
  final SupportRepository repository;

  SaveSupportContact(this.repository);

  @override
  Future<Either<Failure, void>> call(SupportContact params) async {
    return await repository.saveContact(params);
  }
}
