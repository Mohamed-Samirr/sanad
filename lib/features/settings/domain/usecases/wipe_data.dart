import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';

class WipeData implements UseCase<void, NoParams> {
  const WipeData();

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    try {
      final boxes = [
        HiveBoxes.habits,
        HiveBoxes.habitLogs,
        HiveBoxes.settings,
        HiveBoxes.toolbox,
        HiveBoxes.journal,
        HiveBoxes.behaviors,
        HiveBoxes.urgeEntries,
        HiveBoxes.triggers,
        HiveBoxes.supportContacts,
      ];

      for (final boxName in boxes) {
        if (Hive.isBoxOpen(boxName)) {
          final box = Hive.box(boxName);
          await box.clear();
        } else {
          // If it wasn't open, open it, clear it, close it
          final box = await Hive.openBox(boxName);
          await box.clear();
          await box.close();
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
