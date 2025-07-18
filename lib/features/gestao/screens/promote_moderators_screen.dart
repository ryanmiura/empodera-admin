import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/admin_promotion_controller.dart';
import '../models/admin_user_model.dart';

class PromoteModeratorsScreen extends StatefulWidget {
  const PromoteModeratorsScreen({Key? key}) : super(key: key);

  @override
  State<PromoteModeratorsScreen> createState() => _PromoteModeratorsScreenState();
}

class _PromoteModeratorsScreenState extends State<PromoteModeratorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminPromotionController _controller = AdminPromotionController();

  List<AdminUserModel> _moderators = [];
  List<AdminUserModel> _promotedAdmins = [];
  bool _loading = true;

  String? _currentUid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    // Usa instância já inicializada do app secundário
    final app = Firebase.app('admin-auth');
    final uid = FirebaseAuth.instanceFor(app: app).currentUser?.uid;
    setState(() {
      _currentUid = uid;
    });
    _fetchLists();
  }

  Future<void> _fetchLists() async {
    if (_currentUid == null) return;
    setState(() {
      _loading = true;
    });
    final moderators = await _controller.fetchModerators();
    final promotedAdmins = await _controller.fetchAdminsPromotedBy(_currentUid!);
    setState(() {
      _moderators = moderators;
      _promotedAdmins = promotedAdmins;
      _loading = false;
    });
  }

  Future<void> _promote(String userId) async {
    if (_currentUid == null) return;
    await _controller.promoteToAdmin(userId, _currentUid!);
    await _fetchLists();
  }

  Future<void> _demote(String userId) async {
    await _controller.demoteToModerator(userId);
    await _fetchLists();
  }

  Widget _buildUserCard(AdminUserModel user, {required String actionLabel, required VoidCallback onAction}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(user.nome),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Telefone: ${user.telefone}'),
            Text('Status: ${user.status}'),
            if (user.createdAt != null)
              Text('Criado em: ${user.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: onAction,
          child: Text(actionLabel),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Promover Moderadores'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Moderadores'),
            Tab(text: 'Admin Promovidos'),
          ],
        ),
      ),
      drawer: const Drawer(), // Substitua por CustomDrawer se necessário
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // Moderadores
                RefreshIndicator(
                  onRefresh: _fetchLists,
                  child: ListView.builder(
                    itemCount: _moderators.length,
                    itemBuilder: (context, index) {
                      final user = _moderators[index];
                      return _buildUserCard(
                        user,
                        actionLabel: 'Promover para admin',
                        onAction: () => _promote(user.id),
                      );
                    },
                  ),
                ),
                // Admin Promovidos
                RefreshIndicator(
                  onRefresh: _fetchLists,
                  child: ListView.builder(
                    itemCount: _promotedAdmins.length,
                    itemBuilder: (context, index) {
                      final user = _promotedAdmins[index];
                      return _buildUserCard(
                        user,
                        actionLabel: 'Rebaixar para moderador',
                        onAction: () => _demote(user.id),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}