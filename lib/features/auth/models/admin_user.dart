import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUser {
  final String uid;
  final String email;
  final String? name;
  final String role;
  final String status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;
  final bool mfaEnabled;
  final DateTime? lastLogin;

  AdminUser({
    required this.uid,
    required this.email,
    this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
    required this.mfaEnabled,
    this.lastLogin,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map) {
    return AdminUser(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['profile_data']?['name'] as String?,
      role: map['role'] as String,
      status: map['status'] as String,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      approvedAt: map['approved_at'] != null 
          ? (map['approved_at'] as Timestamp).toDate()
          : null,
      approvedBy: map['approved_by'] as String?,
      mfaEnabled: map['mfa_enabled'] as bool,
      lastLogin: map['last_login'] != null 
          ? (map['last_login'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'profile_data': {
        'name': name,
      },
      'role': role,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'approved_at': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approved_by': approvedBy,
      'mfa_enabled': mfaEnabled,
      'last_login': lastLogin != null ? Timestamp.fromDate(lastLogin!) : null,
    };
  }
}