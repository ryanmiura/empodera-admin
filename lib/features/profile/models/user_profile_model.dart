// Modelo de perfil de usuário
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileModel {
  final String uid;
  String email;
  String role;
  String status;
  bool mfaEnabled;
  DateTime? approvedAt;
  DateTime createdAt;
  DateTime? lastLogin;

  UserProfileModel({
    required this.uid,
    required this.email,
    required this.role,
    required this.status,
    required this.mfaEnabled,
    required this.approvedAt,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return UserProfileModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? '',
      mfaEnabled: map['mfa_enabled'] ?? false,
      approvedAt: parseDate(map['approved_at']),
      createdAt: parseDate(map['created_at']) ?? DateTime.now(),
      lastLogin: parseDate(map['last_login']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'status': status,
      'mfa_enabled': mfaEnabled,
      'approved_at': approvedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  Map<String, dynamic> toEditableMap() {
    return {
      'email': email,
      'role': role,
      'mfa_enabled': mfaEnabled,
    };
  }
}