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
      appId: "1:907449237702:web:942e341a351a8edaea17c7",
      measurementId: "G-XE1P21H3BY"
  );

  static const FirebaseOptions android = FirebaseOptions( appId: '1:907449237702:android:bf871b53d01bda8aea17c7', apiKey: '', projectId: '', messagingSenderId: '');
  // static const FirebaseOptions ios = FirebaseOptions(...);
}