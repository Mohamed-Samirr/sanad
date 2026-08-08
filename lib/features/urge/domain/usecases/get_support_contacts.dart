import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/support_contact.dart';
import '../repositories/support_repository.dart';

class GetSupportContacts implements UseCase<List<SupportContact>, NoParams> {
  final SupportRepository repository;

  GetSupportContacts(this.repository);

  @override
  Future<Either<Failure, List<SupportContact>>> call(NoParams params) async {
    return await repository.getContacts();
  }
}
