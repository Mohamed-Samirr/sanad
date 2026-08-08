import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/support_contact.dart';

abstract class SupportRepository {
  Future<Either<Failure, List<SupportContact>>> getContacts();
  Future<Either<Failure, void>> saveContact(SupportContact contact);
  Future<Either<Failure, void>> deleteContact(String id);
  Stream<void> watchContacts();
}
