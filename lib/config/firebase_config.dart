import 'package:firebase_core/firebase_core.dart';
import '../firebase_options_main_app.dart';  // Configurações do projeto principal
import '../firebase_options_admin_auth.dart';  // Configurações do projeto admin

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