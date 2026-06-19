import 'package:get_it/get_it.dart';

import '../core/database/app_database.dart';

/// Service locator. Slice 0 registers dependencies manually; we migrate to
/// `injectable` codegen once the graph grows (see docs/PLAN.md §1).
final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerLazySingleton<AppDatabase>(AppDatabase.new);
}
