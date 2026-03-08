import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAea9_7wqR_pdBPcZTje9XkpprOuY13SSY',
    appId: '1:857441261111:web:56e839482b90f311a751b2',
    messagingSenderId: '857441261111',
    projectId: 'kc-services-places',
    authDomain: 'kc-services-places.firebaseapp.com',
    storageBucket: 'kc-services-places.firebasestorage.app',
    measurementId: 'G-WF216Q05YL',
  );

  // TODO: Replace with your Firebase project configuration

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAmF4EhuZ72jzUMSi99AuPgoBD2w2ys2-0',
    appId: '1:857441261111:android:c04c8ca405367628a751b2',
    messagingSenderId: '857441261111',
    projectId: 'kc-services-places',
    storageBucket: 'kc-services-places.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBjWqKQlJpifaLsfmjqgZ4Tycb6qd-bUFk',
    appId: '1:857441261111:ios:414dba3e940ed7cfa751b2',
    messagingSenderId: '857441261111',
    projectId: 'kc-services-places',
    storageBucket: 'kc-services-places.firebasestorage.app',
    iosBundleId: 'com.example.kcServicesPlaces',
  );

}