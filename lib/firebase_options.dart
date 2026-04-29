// lib/firebase_options.dart
// Generated Firebase options for moviesbz-1

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyByWV89V-BxtwgXgZMNJGiR4CNU2IAluEo',
    authDomain: 'moviesbz-1.firebaseapp.com',
    projectId: 'moviesbz-1',
    storageBucket: 'moviesbz-1.firebasestorage.app',
    messagingSenderId: '474404528227',
    appId: '1:474404528227:web:12a5ce691dcd8fe39ad856',
    measurementId: 'G-F8CGNZ7SV2',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyByWV89V-BxtwgXgZMNJGiR4CNU2IAluEo',
    projectId: 'moviesbz-1',
    storageBucket: 'moviesbz-1.firebasestorage.app',
    messagingSenderId: '474404528227',
    appId: '1:474404528227:web:12a5ce691dcd8fe39ad856',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyByWV89V-BxtwgXgZMNJGiR4CNU2IAluEo',
    projectId: 'moviesbz-1',
    storageBucket: 'moviesbz-1.firebasestorage.app',
    messagingSenderId: '474404528227',
    appId: '1:474404528227:web:12a5ce691dcd8fe39ad856',
  );
}
