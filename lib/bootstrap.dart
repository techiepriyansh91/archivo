import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'firebase_options.dart';
import 'injection/injection.dart';

/// Shared startup path for every flavor entrypoint (`main_<flavor>.dart`).
/// Keeps the bootstrap logic in one place so the entrypoints stay one-liners.
Future<void> bootstrap(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO(firebase): currently every flavor points at archivo-dev because only
  // that project is generated. Once archivo-staging / archivo-prod exist, run
  // `flutterfire config -p <project> --out lib/firebase_options_<flavor>.dart`
  // and select options by `config.flavor` here.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await configureDependencies();
  runApp(ArchivoApp(config: config));
}
