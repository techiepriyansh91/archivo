import 'bootstrap.dart';
import 'core/config/app_config.dart';

// Run with: flutter run --flavor staging -t lib/main_staging.dart
Future<void> main() => bootstrap(AppConfig.staging);
