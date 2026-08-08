import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/app_settings_model.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/usecases/get_settings.dart';
import 'domain/usecases/update_settings.dart';
import 'domain/usecases/wipe_data.dart';
import 'domain/services/app_lock_service.dart';
import 'domain/services/data_export_service.dart';
import 'presentation/cubit/settings_cubit.dart';

final sl = GetIt.instance;

Future<void> initSettingsFeature() async {
  Hive.registerAdapter(AppSettingsAdapter());

  // Repositories
  sl.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl());

  // Use cases
  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => UpdateSettings(sl()));
  sl.registerLazySingleton(() => const WipeData());

  // Services
  sl.registerLazySingleton(() => AppLockService());
  sl.registerLazySingleton(() => DataExportService());

  // Cubits
  sl.registerFactory(() => SettingsCubit(
        appLockService: sl(),
        dataExportService: sl(),
        wipeData: sl(),
      ));
}
