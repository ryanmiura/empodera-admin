import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PrimaryFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: dotenv.env['ADMIN_AUTH_FIREBASE_API_KEY']!,
      appId: dotenv.env['ADMIN_AUTH_FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['ADMIN_AUTH_FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: dotenv.env['ADMIN_AUTH_FIREBASE_PROJECT_ID']!,
      databaseURL: null,
      storageBucket: dotenv.env['ADMIN_AUTH_FIREBASE_STORAGE_BUCKET'],
      androidClientId: null,
      iosClientId: null,
      iosBundleId: null,
    );
  }
}