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
    apiKey: 'AIzaSyANKNS2VBmWVLIr8knzDe4zldU84bE_xkQ',
    appId: '1:867450785730:android:02ae9eead48af25bba105b',
    messagingSenderId: '867450785730',
    projectId: 'archivo-prod',
    storageBucket: 'archivo-prod.firebasestorage.app',
  );

  // TODO: add iOS app to archivo-prod in Firebase Console, then update this.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyANKNS2VBmWVLIr8knzDe4zldU84bE_xkQ',
    appId: 'REPLACE_WITH_PROD_IOS_APP_ID',
    messagingSenderId: '867450785730',
    projectId: 'archivo-prod',
    storageBucket: 'archivo-prod.firebasestorage.app',
    iosBundleId: 'com.priyanshu.archivo',
  );
}
