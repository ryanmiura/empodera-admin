import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../features/auth/models/admin_user.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService()
      : _auth = FirebaseAuth.instanceFor(app: Firebase.app('admin-auth')),
        _firestore = FirebaseFirestore.instanceFor(app: Firebase.app('admin-auth'));

  Future<AdminUser?> signInWithEmailAndPassword(
      String email,
      String password,
      ) async {
    try {
      // Verifica se as credenciais são válidas antes de prosseguir
      if (email.isEmpty || password.isEmpty) {
        throw 'Email e senha são obrigatórios';
      }

      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (credential.user == null) {
        throw 'Autenticação falhou - usuário não retornado';
      }

      final userDoc = await _firestore
          .collection('admin_users')
          .doc(credential.user!.uid)
          .get();

      if (!userDoc.exists) {
        throw 'Usuário não encontrado na base de administradores';
      }

      final userData = userDoc.data()!;
      userData['uid'] = credential.user!.uid;

      final status = userData['status'] as String?;
      if (status != 'approved') {
        throw 'Usuário não aprovado. Status: ${status ?? 'não definido'}';
      }

      // Atualiza último login sem esperar conclusão
      userDoc.reference.update({
        'last_login': FieldValue.serverTimestamp(),
      });

      return AdminUser.fromMap(userData);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erro ao realizar login: ${e.toString()}';
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Usuário não encontrado';
      case 'wrong-password': return 'Senha incorreta';
      case 'user-disabled': return 'Usuário desativado';
      case 'invalid-email': return 'Email inválido';
      case 'invalid-credential': return 'Credenciais inválidas';
      case 'too-many-requests': return 'Muitas tentativas. Tente mais tarde';
      default: return 'Erro na autenticação: ${e.message ?? e.code}';
    }
  }

  User? get currentUser => _auth.currentUser;

  bool get isSignedIn {
    try {
      return _auth.currentUser != null;
    } catch (e) {
      // Removido debugPrint
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      // Removido debugPrint
      rethrow;
    }
  }
}