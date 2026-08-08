import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:sanad/core/constants/hive_constants.dart';
import 'data/models/behavior_model.dart';
import 'data/models/support_contact_model.dart';
import 'data/models/trigger_model.dart';
import 'data/models/urge_entry_model.dart';

import 'data/repositories/behavior_repository_impl.dart';
import 'data/repositories/support_repository_impl.dart';
import 'data/repositories/trigger_repository_impl.dart';
import 'data/repositories/urge_repository_impl.dart';
import 'domain/repositories/behavior_repository.dart';
import 'domain/repositories/support_repository.dart';
import 'domain/repositories/trigger_repository.dart';
import 'domain/repositories/urge_repository.dart';
import 'domain/usecases/clear_active_urge.dart';
import 'domain/usecases/get_active_urge.dart';
import 'domain/usecases/get_behaviors.dart';
import 'domain/usecases/get_support_contacts.dart';
import 'domain/usecases/save_support_contact.dart';
import 'domain/usecases/delete_support_contact.dart';
import 'domain/usecases/get_triggers.dart';
import 'domain/usecases/save_urge.dart';
import 'presentation/cubit/urge_flow_cubit.dart';

Future<void> initUrgeFeature() async {
  final sl = GetIt.I;

  if (!Hive.isAdapterRegistered(HiveTypeIds.urgeEntry)) Hive.registerAdapter(UrgeEntryModelAdapter());
  if (!Hive.isAdapterRegistered(HiveTypeIds.behavior)) Hive.registerAdapter(BehaviorModelAdapter());
  if (!Hive.isAdapterRegistered(HiveTypeIds.trigger)) Hive.registerAdapter(TriggerModelAdapter());
  if (!Hive.isAdapterRegistered(HiveTypeIds.supportContact)) Hive.registerAdapter(SupportContactModelAdapter());

  if (!Hive.isBoxOpen(HiveBoxes.urgeEntries)) await Hive.openBox<UrgeEntryModel>(HiveBoxes.urgeEntries);
  if (!Hive.isBoxOpen(HiveBoxes.behaviors)) await Hive.openBox<BehaviorModel>(HiveBoxes.behaviors);
  if (!Hive.isBoxOpen(HiveBoxes.triggers)) await Hive.openBox<TriggerModel>(HiveBoxes.triggers);
  if (!Hive.isBoxOpen(HiveBoxes.supportContacts)) await Hive.openBox<SupportContactModel>(HiveBoxes.supportContacts);

  // Repositories
  sl.registerLazySingleton<BehaviorRepository>(() => BehaviorRepositoryImpl());
  sl.registerLazySingleton<UrgeRepository>(() => UrgeRepositoryImpl());
  sl.registerLazySingleton<TriggerRepository>(() => TriggerRepositoryImpl());
  sl.registerLazySingleton<SupportRepository>(() => SupportRepositoryImpl());

  // Use cases
  sl.registerLazySingleton(() => GetSupportContacts(sl()));
  sl.registerLazySingleton(() => SaveSupportContact(sl()));
  sl.registerLazySingleton(() => DeleteSupportContact(sl()));
  sl.registerLazySingleton(() => GetActiveUrge(sl()));
  sl.registerLazySingleton(() => SaveUrge(sl()));
  sl.registerLazySingleton(() => ClearActiveUrge(sl()));
  sl.registerLazySingleton(() => GetBehaviors(sl()));
  sl.registerLazySingleton(() => GetTriggers(sl()));

  // Cubits
  sl.registerFactory(
    () => UrgeFlowCubit(
      getActiveUrge: sl(),
      saveUrge: sl(),
      clearActiveUrge: sl(),
      getBehaviors: sl(),
    ),
  );
}
