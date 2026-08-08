import 'package:get_it/get_it.dart';

import 'presentation/cubit/insights_cubit.dart';

final sl = GetIt.instance;

void initInsightsFeature() {
  // Cubit
  sl.registerFactory(() => InsightsCubit(
        urgeRepository: sl(),
        triggerRepository: sl(),
      ));
}
