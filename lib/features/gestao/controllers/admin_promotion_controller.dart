import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/admin_user_model.dart';

class AdminPromotionController {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('admin-auth'));
  final String _collection = 'admin_users';

  /// Busca todos os moderadores (role == "moderator")
  Future<List<AdminUserModel>> fetchModerators() async {
    final query = await _firestore
        .collection(_collection)
        .where('role', isEqualTo: 'moderator')
        .get();

    return query.docs
        .map((doc) => AdminUserModel.fromFirestore(doc))
        .toList();
  }

  /// Busca todos os admins promovidos pelo usuário logado
  /// (role == "admin" && promoted_by == uid)
  Future<List<AdminUserModel>> fetchAdminsPromotedBy(String uid) async {
    final query = await _firestore
        .collection(_collection)
        .where('role', isEqualTo: 'admin')
        .where('promoted_by', isEqualTo: uid)
        .get();

    return query.docs
        .map((doc) => AdminUserModel.fromFirestore(doc))
        .toList();
  }

  /// Promove moderador para admin
  /// Atualiza role para "admin" e promoted_by para uid do logado
  Future<void> promoteToAdmin(String userId, String promoterUid) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
          'role': 'admin',
          'promoted_by': promoterUid,
        });
  }

  /// Rebaixa admin promovido para moderador
  /// Atualiza role para "moderator" e promoted_by para null
  Future<void> demoteToModerator(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({
          'role': 'moderator',
          'promoted_by': null,
        });
  }
}