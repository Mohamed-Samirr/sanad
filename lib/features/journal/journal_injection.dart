import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:sanad/core/constants/hive_constants.dart';
import 'data/models/journal_model.dart';
import 'data/datasources/journal_local_data_source.dart';
import 'data/repositories/journal_repository_impl.dart';
import 'domain/repositories/journal_repository.dart';
import 'domain/usecases/delete_journal_entry.dart';
import 'domain/usecases/get_journal_entries.dart';
import 'domain/usecases/save_journal_entry.dart';
import 'presentation/cubit/journal_cubit.dart';

Future<void> initJournalFeature() async {
  final sl = GetIt.instance;

  if (!Hive.isAdapterRegistered(HiveTypeIds.journalEntry)) {
    Hive.registerAdapter(JournalModelAdapter());
  }
  
  if (!Hive.isBoxOpen(HiveBoxes.journal)) {
    await Hive.openBox<JournalModel>(HiveBoxes.journal);
  }

  // Data sources
  sl.registerLazySingleton<JournalLocalDataSource>(
      () => JournalLocalDataSourceImpl());

  // Repository
  sl.registerLazySingleton<JournalRepository>(
      () => JournalRepositoryImpl(localDataSource: sl()));

  // Use cases
  sl.registerLazySingleton(() => GetJournalEntries(sl()));
  sl.registerLazySingleton(() => SaveJournalEntry(sl()));
  sl.registerLazySingleton(() => DeleteJournalEntry(sl()));

  // Cubit (Factory so each page gets a fresh one)
  sl.registerFactory(
    () => JournalCubit(
      getJournalEntries: sl(),
      deleteJournalEntry: sl(),
      repository: sl(),
    ),
  );
}
