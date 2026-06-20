// TODO: replace by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure -p archivo-staging \
//     --out lib/firebase_options_staging.dart \
//     --android-package-name com.priyanshu.archivo.staging
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Platform not configured.');
    }
  }

  // Placeholder — replace with real values from archivo-staging via flutterfire configure.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_WITH_STAGING_API_KEY',
    appId: 'REPLACE_WITH_STAGING_ANDROID_APP_ID',
    messagingSenderId: 'REPLACE_WITH_STAGING_SENDER_ID',
    projectId: 'archivo-staging',
    storageBucket: 'archivo-staging.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_STAGING_IOS_API_KEY',
    appId: 'REPLACE_WITH_STAGING_IOS_APP_ID',
    messagingSenderId: 'REPLACE_WITH_STAGING_SENDER_ID',
    projectId: 'archivo-staging',
    storageBucket: 'archivo-staging.firebasestorage.app',
    iosBundleId: 'com.priyanshu.archivo.staging',
  );
}
