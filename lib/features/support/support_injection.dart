import 'package:get_it/get_it.dart';
import 'presentation/cubit/support_cubit.dart';

Future<void> initSupportFeature() async {
  final sl = GetIt.instance;

  // Cubit (Factory so each page gets a fresh one)
  sl.registerFactory(
    () => SupportCubit(
      getSupportContacts: sl(),
      deleteSupportContact: sl(),
      repository: sl(),
    ),
  );
}
