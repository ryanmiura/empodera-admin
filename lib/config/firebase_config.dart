import 'package:firebase_core/firebase_core.dart';
import '../core/firebase/admin_auth/options.dart';
import '../core/firebase/main_app/options.dart';

class FirebaseConfig {
  /// Inicialização centralizada no main.dart.
  /// Este método foi descontinuado para evitar inicialização duplicada.
  static Future<void> init() async {
    throw Exception(
      'A inicialização do Firebase deve ser feita exclusivamente pelo main.dart para garantir ordem e sincronização.'
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