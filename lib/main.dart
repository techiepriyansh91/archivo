import 'bootstrap.dart';
import 'core/config/app_config.dart';

// Default entrypoint for a bare `flutter run` — uses the dev flavor. Prefer the
// explicit per-flavor entrypoints (main_dev / main_staging / main_prod) with the
// matching `--flavor`. Release builds always go through main_prod.dart.
Future<void> main() => bootstrap(AppConfig.dev);
