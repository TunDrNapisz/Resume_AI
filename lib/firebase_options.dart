// File generated manually and updated for both Android and Web support.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for iOS.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macOS.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Windows.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for Linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBEe3aDyx5BIIvQKpChNMtEOxyn0J9NxsQ',
    appId: '1:883311338491:android:e65a1d280535fc6d71a15e',
    messagingSenderId: '883311338491',
    projectId: 'ai-resume-screening-syst-e7924',
    storageBucket: 'ai-resume-screening-syst-e7924.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBNm-cDSiEwxh21behp9kDK-PHSiaD6Kgw',
    authDomain: 'ai-resume-screening-syst-e7924.firebaseapp.com',
    projectId: 'ai-resume-screening-syst-e7924',
    storageBucket: 'ai-resume-screening-syst-e7924.firebasestorage.app',
    messagingSenderId: '883311338491',
    appId: '1:883311338491:web:4f9c21dd16b1bbe871a15e',
    measurementId: 'G-GX1VZ43P5Z',
  );
}
