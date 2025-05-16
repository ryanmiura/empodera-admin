import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_config.dart';
import '../features/auth/models/admin_user.dart';

class AuthService {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  AuthService() {
    final adminApp = FirebaseConfig.getAdminAuth();
    _auth = FirebaseAuth.instanceFor(app: adminApp);
    _firestore = FirebaseFirestore.instanceFor(app: adminApp);
  }

  // Método para realizar login com email e senha
  Future<AdminUser?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw 'Erro ao realizar login';
      }

      // Busca informações adicionais do usuário no Firestore
      final userDoc = await _firestore
          .collection('admin_users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw 'Usuário não encontrado na base de administradores';
      }

      final userData = userDoc.data()!;
      userData['uid'] = credential.user!.uid;  // Adiciona o UID aos dados

      // Verifica o status do usuário
      final status = userData['status'] as String;
      if (status != 'approved') {
        throw 'Usuário não aprovado. Status: $status';
      }

      // Atualiza o último login
      await userDoc.reference.update({
        'last_login': FieldValue.serverTimestamp(),
      });

      return AdminUser.fromMap(userData);

    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'Usuário não encontrado';
        case 'wrong-password':
          throw 'Senha incorreta';
        case 'user-disabled':
          throw 'Usuário desativado';
        case 'invalid-credential':
          throw 'Credenciais inválidas';
        default:
          throw 'Erro ao realizar login: ${e.message}';
      }
    } catch (e) {
      throw 'Erro ao realizar login: $e';
    }
  }

  // Método para obter o usuário atual
  User? get currentUser => _auth.currentUser;

  // Método para verificar se há um usuário logado
  bool get isSignedIn => currentUser != null;

  // Método para realizar logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}