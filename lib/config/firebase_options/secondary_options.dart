import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecondaryFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: dotenv.env['SECONDARY_FIREBASE_API_KEY']!,
      appId: dotenv.env['SECONDARY_FIREBASE_APP_ID']!,
      messagingSenderId: dotenv.env['SECONDARY_FIREBASE_SENDER_ID'] ?? '',
      projectId: dotenv.env['SECONDARY_FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['SECONDARY_FIREBASE_STORAGE_BUCKET'] ?? '',
      databaseURL: dotenv.env['SECONDARY_FIREBASE_DATABASE_URL']!,
    );
  }
}