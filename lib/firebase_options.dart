import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        // return ios;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
      apiKey: "AIzaSyAYrbPw8shBMNa1DtLVU64dkxyXMAh0Exc",
      authDomain: "vmt-firebase.firebaseapp.com",
      projectId: "vmt-firebase",
      storageBucket: "vmt-firebase.firebasestorage.app",
      messagingSenderId: "907449237702",
      appId: "1:907449237702:web:5ba656b13f362657ea17c7",
      measurementId: "G-6QWTR1BC5C"
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyA-YourAndroidApiKey",
    appId: "1:907449237702:android:c215daf2a7e6c88aea17c7",
    messagingSenderId: "YourAndroidMessagingSenderId",
    projectId: "YourAndroidProjectId",
  );
  // static const FirebaseOptions ios = FirebaseOptions(...);
}