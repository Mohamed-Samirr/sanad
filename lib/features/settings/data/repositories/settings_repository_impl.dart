import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/hive_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';

  Future<Box<AppSettings>> _getBox() async {
    if (Hive.isBoxOpen(HiveBoxes.settings)) {
      return Hive.box<AppSettings>(HiveBoxes.settings);
    }
    return await Hive.openBox<AppSettings>(HiveBoxes.settings);
  }

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final box = await _getBox();
      final settings = box.get(_settingsKey) ?? AppSettings.defaults();
      return Right(settings);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateSettings(AppSettings settings) async {
    try {
      final box = await _getBox();
      await box.put(_settingsKey, settings);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<AppSettings> watchSettings() async* {
    final box = await _getBox();
    yield box.get(_settingsKey) ?? AppSettings.defaults();
    yield* box
        .watch(key: _settingsKey)
        .map((event) => event.value as AppSettings? ?? AppSettings.defaults());
  }
}
