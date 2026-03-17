import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android; // APK chesinappudu idi panichestundi
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAYWludiSKAvzaGhAlH9IeOeJaCh-g38eQ',
    appId: '1:461552979998:web:c70390a7929a1c3edf1e0f',
    messagingSenderId: '...',
    projectId: 'wog-app-e922b',
    authDomain: 'wog-app-e922b.firebaseapp.com',
    storageBucket: 'wog-app-e922b.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY', // APK build chesetappudu Firebase nundi vasthundi
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: '...',
    projectId: '...',
    storageBucket: '...',
  );
}
