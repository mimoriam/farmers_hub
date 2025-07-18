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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA2GTwPCQDhmnJroOla_8OcDMh8mIDZ0Ss',
    appId: '1:992806521648:android:2258fecefcdde1b63296f5',
    messagingSenderId: '992806521648',
    projectId: 'mahsolek-8417b',
    storageBucket: 'mahsolek-8417b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVZTLOaz1w0V-98xc9HHMctid8MsxXI_Q',
    appId: '1:992806521648:ios:aefa471d5897cd893296f5',
    messagingSenderId: '992806521648',
    projectId: 'mahsolek-8417b',
    storageBucket: 'mahsolek-8417b.firebasestorage.app',
    androidClientId: '992806521648-nio3dgm4rosqmo1274jsq643ehfi99l3.apps.googleusercontent.com',
    iosClientId: '992806521648-uef5klr6udvjek42po3f7s0libv0hf0o.apps.googleusercontent.com',
    iosBundleId: 'com.farmers.hub.farmersHub',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBnIVr1Fe9HUxdRByEjaiaZWURyu3BC35U',
    appId: '1:992806521648:web:a3d0842e5f838c5f3296f5',
    messagingSenderId: '992806521648',
    projectId: 'mahsolek-8417b',
    authDomain: 'mahsolek-8417b.firebaseapp.com',
    storageBucket: 'mahsolek-8417b.firebasestorage.app',
    measurementId: 'G-BSD6VM8R6X',
  );

}