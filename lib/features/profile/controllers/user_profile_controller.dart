// Controller do perfil de usuário

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../models/user_profile_model.dart';

class UserProfileController extends ChangeNotifier {
  final AuthService _authService;
  final FirebaseFirestore _firestore;

  UserProfileModel? userProfile;
  bool isLoading = false;
  String? error;

  UserProfileController(this._authService, this._firestore);

  Future<void> loadUserProfile() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final user = _authService.currentUser;
      print('[UserProfileController] UID autenticado: ${user?.uid}');
      if (user == null) throw Exception('Usuário não autenticado');
      final doc = await _firestore.collection('admin_users').doc(user.uid).get();
      print('[UserProfileController] Snapshot retornado: exists=${doc.exists}, data=${doc.data()}');
      if (!doc.exists) {
        error = 'Perfil não encontrado';
        userProfile = null;
      } else {
        userProfile = UserProfileModel.fromMap(doc.data()!, user.uid);
      }
    } catch (e) {
      print('[UserProfileController] Erro ao carregar perfil: $e');
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void updateEmail(String email) {
    userProfile?.email = email;
    notifyListeners();
  }

  void updateRole(String role) {
    userProfile?.role = role;
    notifyListeners();
  }

  void updateMfaEnabled(bool enabled) {
    userProfile?.mfaEnabled = enabled;
    notifyListeners();
  }

  String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'E-mail obrigatório';
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(email)) return 'E-mail inválido';
    return null;
  }

  String? validateRole(String? role) {
    if (role == null || role.isEmpty) return 'Role obrigatória';
    // Adicione regras de negócio específicas aqui se necessário
    return null;
  }

  Future<bool> saveProfile() async {
    if (userProfile == null) return false;
    final emailError = validateEmail(userProfile!.email);
    final roleError = validateRole(userProfile!.role);
    if (emailError != null || roleError != null) {
      error = emailError ?? roleError;
      notifyListeners();
      return false;
    }
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(userProfile!.uid).update(
        userProfile!.toEditableMap(),
      );
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}