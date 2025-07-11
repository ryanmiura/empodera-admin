import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../models/admin_user_model.dart';

class AdminModeratorsController {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instanceFor(app: Firebase.app('admin-auth'));
  final String _collection = 'admin_users';

  /// Busca todos os usuários com status "pending"
  Future<List<AdminUserModel>> fetchPendingModerators() async {
    final query = await _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .get();

    return query.docs
        .map((doc) => AdminUserModel.fromFirestore(doc))
        .toList();
  }

  /// Aprova um usuário (status "approved")
  Future<void> approveModerator(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({'status': 'approved'});
  }

  /// Rejeita um usuário (status "rejected")
  Future<void> rejectModerator(String userId) async {
    await _firestore
        .collection(_collection)
        .doc(userId)
        .update({'status': 'rejected'});
  }
}