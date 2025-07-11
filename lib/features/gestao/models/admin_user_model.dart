import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  final String id;
  final String email;
  final String status;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.status,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      id: doc.id,
      email: data['email'] ?? '',
      status: data['status'] ?? '',
    );
  }
}