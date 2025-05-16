import 'package:firebase_core/firebase_core.dart';
import '../core/firebase/admin_auth/options.dart';
import '../core/firebase/main_app/options.dart';

class FirebaseConfig {
  static Future<void> init() async {
    // Inicializa o projeto de autenticação de administradores
    await Firebase.initializeApp(
      name: 'admin-auth',
      options: AdminAuthFirebaseOptions.currentPlatform,
    );

    // Inicializa o projeto principal do aplicativo
    await Firebase.initializeApp(
      name: 'main-app',
      options: MainAppFirebaseOptions.currentPlatform,
    );
  }

  // Helpers para obter as instâncias do Firebase
  static FirebaseApp getAdminAuth() {
    return Firebase.app('admin-auth');
  }

  static FirebaseApp getMainApp() {
    return Firebase.app('main-app');
  }
}