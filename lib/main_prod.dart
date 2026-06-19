import 'bootstrap.dart';
import 'core/config/app_config.dart';

// Run with: flutter run --flavor prod -t lib/main_prod.dart
Future<void> main() => bootstrap(AppConfig.prod);
