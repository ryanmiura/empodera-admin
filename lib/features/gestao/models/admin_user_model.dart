import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserModel {
  final String id;
  final String email;
  final String status;
  final String nome;
  final String telefone;
  final DateTime? createdAt;

  AdminUserModel({
    required this.id,
    required this.email,
    required this.status,
    required this.nome,
    required this.telefone,
    this.createdAt,
  });

  factory AdminUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUserModel(
      id: doc.id,
      email: data['email'] ?? '',
      status: data['status'] ?? '',
      nome: data['nome'] ?? '',
      telefone: data['telefone'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.tryParse(data['created_at'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'status': status,
      'nome': nome,
      'telefone': telefone,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}