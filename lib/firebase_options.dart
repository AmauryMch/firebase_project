// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD6yADUmDxemRqJf2zvVi27UVCTP6JnqXk',
    appId: '1:1048030205774:web:fd52a401ff41e2f7c2f01f',
    messagingSenderId: '1048030205774',
    projectId: 'fir-project-c5c8e',
    authDomain: 'fir-project-c5c8e.firebaseapp.com',
    storageBucket: 'fir-project-c5c8e.appspot.com',
    measurementId: 'G-DVRRNBH02S',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCoDtxxMAJo32NVpq2KMGQm6W7uGhLsT9c',
    appId: '1:1048030205774:android:14587328ebda9c5ac2f01f',
    messagingSenderId: '1048030205774',
    projectId: 'fir-project-c5c8e',
    storageBucket: 'fir-project-c5c8e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvSkXRpoVTSAYRQe1w4dfsPiRHLSoLeB8',
    appId: '1:1048030205774:ios:066594a3d0383de9c2f01f',
    messagingSenderId: '1048030205774',
    projectId: 'fir-project-c5c8e',
    storageBucket: 'fir-project-c5c8e.appspot.com',
    iosBundleId: 'com.example.firebaseProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDvSkXRpoVTSAYRQe1w4dfsPiRHLSoLeB8',
    appId: '1:1048030205774:ios:d004fb62b3e1a295c2f01f',
    messagingSenderId: '1048030205774',
    projectId: 'fir-project-c5c8e',
    storageBucket: 'fir-project-c5c8e.appspot.com',
    iosBundleId: 'com.example.firebaseProject.RunnerTests',
  );
}
