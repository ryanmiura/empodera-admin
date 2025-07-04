import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MainAppFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      case TargetPlatform.macOS: return macos;
      case TargetPlatform.windows: return windows;
      default: throw UnsupportedError(
        'MainAppFirebaseOptions não são suportados para esta plataforma',
      );
    }
  }

  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: dotenv.env['MAIN_APP_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['MAIN_APP_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['MAIN_APP_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['MAIN_APP_FIREBASE_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['MAIN_APP_FIREBASE_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['MAIN_APP_FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: dotenv.env['MAIN_APP_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['MAIN_APP_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['MAIN_APP_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['MAIN_APP_FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['MAIN_APP_FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: dotenv.env['MAIN_APP_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['MAIN_APP_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['MAIN_APP_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['MAIN_APP_FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['MAIN_APP_FIREBASE_STORAGE_BUCKET'] ?? '',
      iosBundleId: 'com.example.empoderaadmin',
    );
  }

  static FirebaseOptions get macos {
    return FirebaseOptions(
      apiKey: dotenv.env['MAIN_APP_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['MAIN_APP_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['MAIN_APP_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['MAIN_APP_FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['MAIN_APP_FIREBASE_STORAGE_BUCKET'] ?? '',
      iosBundleId: 'com.example.empoderaadmin',
    );
  }

  static FirebaseOptions get windows {
    return FirebaseOptions(
      apiKey: dotenv.env['MAIN_APP_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['MAIN_APP_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['MAIN_APP_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['MAIN_APP_FIREBASE_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['MAIN_APP_FIREBASE_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['MAIN_APP_FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  }
}