import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options_dev.dart' as dev_options;
import 'firebase_options_prod.dart' as prod_options;
import 'firebase_options_staging.dart' as staging_options;
import 'injection/injection.dart';

/// Shared startup path for every flavor entrypoint (`main_<flavor>.dart`).
/// Each flavor initializes Firebase against its own project — dev/staging/prod
/// are completely isolated environments (auth, Firestore, Storage).
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseOptions = switch (config.flavor) {
    Flavor.dev => dev_options.DefaultFirebaseOptions.currentPlatform,
    Flavor.staging => staging_options.DefaultFirebaseOptions.currentPlatform,
    Flavor.prod => prod_options.DefaultFirebaseOptions.currentPlatform,
  };

  await Firebase.initializeApp(options: firebaseOptions);
  await configureDependencies();
  runApp(ArchivoApp(config: config));
}
