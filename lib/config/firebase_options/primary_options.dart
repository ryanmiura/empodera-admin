import 'package:firebase_core/firebase_core.dart';

class PrimaryFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: 'AIzaSyD3ZRyFFcFk8VUwS1Md9GbH0nqLx7cTBNA',
      appId: '1:155732009811:android:1a7b437e093e26ea3d77a6',
      messagingSenderId: '155732009811', // Usando project_number como senderId
      projectId: 'empodera-admin',
      databaseURL: 'https://empodera-admin.firebaseio.com', // URL presumida
      storageBucket: 'empodera-admin.firebasestorage.app',
      androidClientId: '', // Não disponível no arquivo fornecido
      iosClientId: '', // Não disponível no arquivo fornecido
      iosBundleId: 'com.example.empoderaadmin',
    );
  }
}