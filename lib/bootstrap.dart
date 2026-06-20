import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'injection/injection.dart';

Future<void> bootstrap(AppConfig config) async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  final prefs = await SharedPreferences.getInstance();
  await configureDependencies(prefs: prefs);

  runApp(ArchivoApp(config: config));
}
