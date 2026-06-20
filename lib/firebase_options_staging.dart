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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcC9x7vj35NIWB2j8L6rD5PfNjoU4_hko',
    appId: '1:920760796043:android:3e73a39d3f2617ef65a58e',
    messagingSenderId: '920760796043',
    projectId: 'archivo-staging',
    storageBucket: 'archivo-staging.firebasestorage.app',
  );

  // TODO: add iOS app to archivo-staging in Firebase Console, then update this.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcC9x7vj35NIWB2j8L6rD5PfNjoU4_hko',
    appId: 'REPLACE_WITH_STAGING_IOS_APP_ID',
    messagingSenderId: '920760796043',
    projectId: 'archivo-staging',
    storageBucket: 'archivo-staging.firebasestorage.app',
    iosBundleId: 'com.priyanshu.archivo.staging',
  );
}
