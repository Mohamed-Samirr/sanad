import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/support_contact.dart';
import '../../domain/repositories/support_repository.dart';
import '../models/support_contact_model.dart';

class SupportRepositoryImpl implements SupportRepository {
  Box<SupportContactModel> get _box => Hive.box<SupportContactModel>(HiveBoxes.supportContacts);

  @override
  Future<Either<Failure, List<SupportContact>>> getContacts() async {
    try {
      final contacts = _box.values.map((model) => model.toEntity()).toList();
      return Right(contacts);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveContact(SupportContact contact) async {
    try {
      await _box.put(contact.id, SupportContactModel.fromEntity(contact));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContact(String id) async {
    try {
      await _box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<void> watchContacts() {
    return _box.watch().map((_) {});
  }
}
