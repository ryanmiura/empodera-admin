import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para realizar login com email e senha
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw 'Usuário não encontrado';
      } else if (e.code == 'wrong-password') {
        throw 'Senha incorreta';
      }
      throw 'Erro ao realizar login: ${e.message}';
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