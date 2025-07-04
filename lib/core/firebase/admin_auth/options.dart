import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AdminAuthFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android: return android;
      case TargetPlatform.iOS: return ios;
      case TargetPlatform.macOS: return macos;
      case TargetPlatform.windows: return windows;
      default: throw UnsupportedError('Plataforma não suportada');
    }
  }

  static FirebaseOptions get web {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['ADMIN_AUTH_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['ADMIN_AUTH_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['ADMIN_AUTH_FIREBASE_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['ADMIN_AUTH_FIREBASE_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['ADMIN_AUTH_FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_FIREBASE_API_KEY'] ?? '',
      appId: dotenv.env['ADMIN_AUTH_FIREBASE_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['ADMIN_AUTH_FIREBASE_MESSAGING_SENDER_ID'] ?? '',
      projectId: dotenv.env['ADMIN_AUTH_FIREBASE_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['ADMIN_AUTH_FIREBASE_STORAGE_BUCKET'] ?? '',
    );
  }

// Atualize similarmente para ios, macos e windows

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_API_KEY'] ?? '',
      appId: dotenv.env['ADMIN_AUTH_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['ADMIN_AUTH_SENDER_ID'] ?? '',
      projectId: dotenv.env['ADMIN_AUTH_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['ADMIN_AUTH_STORAGE_BUCKET'] ?? '',
      iosBundleId: 'com.example.empoderaadmin',
    );
  }

  static FirebaseOptions get macos {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_API_KEY'] ?? '',
      appId: dotenv.env['ADMIN_AUTH_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['ADMIN_AUTH_SENDER_ID'] ?? '',
      projectId: dotenv.env['ADMIN_AUTH_PROJECT_ID'] ?? '',
      storageBucket: dotenv.env['ADMIN_AUTH_STORAGE_BUCKET'] ?? '',
      iosBundleId: 'com.example.empoderaadmin',
    );
  }

  static FirebaseOptions get windows {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_API_KEY'] ?? '',
      appId: dotenv.env['ADMIN_AUTH_APP_ID'] ?? '',
      messagingSenderId: dotenv.env['ADMIN_AUTH_SENDER_ID'] ?? '',
      projectId: dotenv.env['ADMIN_AUTH_PROJECT_ID'] ?? '',
      authDomain: dotenv.env['ADMIN_AUTH_AUTH_DOMAIN'] ?? '',
      storageBucket: dotenv.env['ADMIN_AUTH_STORAGE_BUCKET'] ?? '',
    );
  }
}