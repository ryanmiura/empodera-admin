// Tela de perfil de usuário

import 'package:flutter/material.dart';
import '../../../config/firebase_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/auth_service.dart';
import '../controllers/user_profile_controller.dart';
import '../models/user_profile_model.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _UserProfileView(
      controller: UserProfileController(
        AuthService(),
        FirebaseFirestore.instanceFor(app: FirebaseConfig.getAdminAuth()),
      )..loadUserProfile(),
    );
  }
}

class _UserProfileView extends StatefulWidget {
  final UserProfileController controller;
  const _UserProfileView({required this.controller, Key? key}) : super(key: key);

  @override
  State<_UserProfileView> createState() => _UserProfileViewState();
}

class _UserProfileViewState extends State<_UserProfileView> {
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final profile = controller.userProfile;

    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.error != null) {
      return Center(child: Text('Erro: ${controller.error}'));
    }
    if (profile == null) {
      return const Center(child: Text('Perfil não encontrado.'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Usuário')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Text(
                          profile.email.isNotEmpty ? profile.email[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 32,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        profile.email,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        profile.role,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Divider(),
                      ListTile(
                        leading: Icon(Icons.verified_user, color: Theme.of(context).primaryColor),
                        title: const Text('Status'),
                        subtitle: Text(profile.status),
                      ),
                      ListTile(
                        leading: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                        title: const Text('MFA habilitado'),
                        subtitle: Text(profile.mfaEnabled ? 'Sim' : 'Não'),
                      ),
                      ListTile(
                        leading: Icon(Icons.event_available, color: Theme.of(context).primaryColor),
                        title: const Text('Aprovado em'),
                        subtitle: Text(profile.approvedAt?.toString() ?? '-'),
                      ),
                      ListTile(
                        leading: Icon(Icons.event, color: Theme.of(context).primaryColor),
                        title: const Text('Criado em'),
                        subtitle: Text(profile.createdAt.toString()),
                      ),
                      ListTile(
                        leading: Icon(Icons.login, color: Theme.of(context).primaryColor),
                        title: const Text('Último login'),
                        subtitle: Text(profile.lastLogin?.toString() ?? '-'),
                      ),
                      ListTile(
                        leading: Icon(Icons.fingerprint, color: Theme.of(context).primaryColor),
                        title: const Text('UID'),
                        subtitle: Text(profile.uid),
                      ),
                    ],
                  ),
                ),
              ),
              if (controller.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    controller.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}