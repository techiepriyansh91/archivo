import 'package:flutter/material.dart';

import 'app.dart';
import 'injection/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const ArchivoApp());
}
