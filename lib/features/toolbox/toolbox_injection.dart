import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'data/models/tool_action_model.dart';
import 'data/repositories/toolbox_repository_impl.dart';
import 'domain/repositories/toolbox_repository.dart';
import 'domain/usecases/delete_tool_action.dart';
import 'domain/usecases/get_toolbox_actions.dart';
import 'domain/usecases/save_tool_action.dart';

final sl = GetIt.instance;

Future<void> initToolboxFeature() async {
  Hive.registerAdapter(ToolActionAdapter());

  // Repositories
  sl.registerLazySingleton<ToolboxRepository>(() => ToolboxRepositoryImpl());

  // Use cases
  sl.registerLazySingleton(() => GetToolboxActions(sl()));
  sl.registerLazySingleton(() => SaveToolAction(sl()));
  sl.registerLazySingleton(() => DeleteToolAction(sl()));
}
