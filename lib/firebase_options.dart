// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBl9Kv1k3JlfY-DzG_kEjh_sqsX6CFNG9o',
    appId: '1:519406597229:web:d5cfb13545dd4ea3be7b64',
    messagingSenderId: '519406597229',
    projectId: 'flutter-project-firebase-f21ba',
    authDomain: 'flutter-project-firebase-f21ba.firebaseapp.com',
    storageBucket: 'flutter-project-firebase-f21ba.firebasestorage.app',
    measurementId: 'G-CFYYN5W828',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAX_wJI2G0_mWp9HOmpCizNr8uW6bKcCcY',
    appId: '1:519406597229:android:823a0295f9444afebe7b64',
    messagingSenderId: '519406597229',
    projectId: 'flutter-project-firebase-f21ba',
    storageBucket: 'flutter-project-firebase-f21ba.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCN9CYDEAp3sg54zrkF1CkbzkTgpx_k3Cw',
    appId: '1:519406597229:ios:ab1635b978135b14be7b64',
    messagingSenderId: '519406597229',
    projectId: 'flutter-project-firebase-f21ba',
    storageBucket: 'flutter-project-firebase-f21ba.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterProjDq',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCN9CYDEAp3sg54zrkF1CkbzkTgpx_k3Cw',
    appId: '1:519406597229:ios:ab1635b978135b14be7b64',
    messagingSenderId: '519406597229',
    projectId: 'flutter-project-firebase-f21ba',
    storageBucket: 'flutter-project-firebase-f21ba.firebasestorage.app',
    iosBundleId: 'com.example.myFlutterProjDq',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBl9Kv1k3JlfY-DzG_kEjh_sqsX6CFNG9o',
    appId: '1:519406597229:web:2eb3fcfd8babe3ebbe7b64',
    messagingSenderId: '519406597229',
    projectId: 'flutter-project-firebase-f21ba',
    authDomain: 'flutter-project-firebase-f21ba.firebaseapp.com',
    storageBucket: 'flutter-project-firebase-f21ba.firebasestorage.app',
    measurementId: 'G-2WT2K7WV8H',
  );
}
