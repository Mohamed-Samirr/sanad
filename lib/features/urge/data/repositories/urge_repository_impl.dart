import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../domain/entities/urge_entry.dart';
import '../../domain/repositories/urge_repository.dart';
import '../models/urge_entry_model.dart';

class UrgeRepositoryImpl implements UrgeRepository {
  Box<UrgeEntryModel> get _box => Hive.box<UrgeEntryModel>(HiveBoxes.urgeEntries);

  @override
  Future<Either<Failure, UrgeEntry?>> getActiveUrge() async {
    try {
      final entries = _box.values.toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      for (final entry in entries) {
        if (entry.outcomeIndex == null || UrgeOutcome.values[entry.outcomeIndex!] == UrgeOutcome.ongoing) {
          return Right(entry.toEntity());
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveUrge(UrgeEntry entry) async {
    try {
      await _box.put(entry.id, UrgeEntryModel.fromEntity(entry));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearActiveUrge() async {
    try {
      final activeUrgeResult = await getActiveUrge();
      return activeUrgeResult.fold(
        (failure) => Left(failure),
        (activeUrge) async {
          if (activeUrge != null) {
            await _box.delete(activeUrge.id);
          }
          return const Right(null);
        },
      );
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UrgeEntry>>> getUrgeHistory() async {
    try {
      final entries = _box.values.map((model) => model.toEntity()).toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(entries);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<UrgeEntry?> watchActiveUrge() {
    return _box.watch().map((_) {
      final entries = _box.values.toList();
      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      for (final entry in entries) {
        if (entry.outcomeIndex == null || UrgeOutcome.values[entry.outcomeIndex!] == UrgeOutcome.ongoing) {
          return entry.toEntity();
        }
      }
      return null;
    });
  }

  @override
  Stream<void> watchUrges() {
    return _box.watch().map((_) {});
  }
}
