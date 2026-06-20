import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options_dev.dart' as dev_options;
import 'firebase_options_prod.dart' as prod_options;
import 'firebase_options_staging.dart' as staging_options;
import 'injection/injection.dart';

/// Shared startup path for every flavor entrypoint (`main_<flavor>.dart`).
Future<void> bootstrap(AppConfig config) async {
  // Keep the native splash on screen until we explicitly remove it
  // (done in AuthGate once Firebase auth state resolves).
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final firebaseOptions = switch (config.flavor) {
    Flavor.dev => dev_options.DefaultFirebaseOptions.currentPlatform,
    Flavor.staging => staging_options.DefaultFirebaseOptions.currentPlatform,
    Flavor.prod => prod_options.DefaultFirebaseOptions.currentPlatform,
  };

  await Firebase.initializeApp(options: firebaseOptions);

  final prefs = await SharedPreferences.getInstance();
  await configureDependencies(prefs: prefs);

  runApp(ArchivoApp(config: config));
}
