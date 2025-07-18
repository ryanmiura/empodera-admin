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
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.deepPurple[50],
                  child: Icon(Icons.person, color: Colors.deepPurple[400], size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.teal[400], size: 18),
                const SizedBox(width: 8),
                Text(
                  user.telefone.isNotEmpty ? user.telefone : "Não informado",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified_user, color: Colors.blue[400], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Status: ${user.status}',
                  style: TextStyle(fontSize: 14, color: Colors.blue[700], fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.orange[400], size: 18),
                const SizedBox(width: 8),
                Text(
                  user.createdAt != null
                      ? "${user.createdAt!.day.toString().padLeft(2, '0')}/${user.createdAt!.month.toString().padLeft(2, '0')}/${user.createdAt!.year}"
                      : "Não informado",
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Center(
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionLabel.contains('Rebaixar')
                        ? Colors.red[600]
                        : Colors.green[600],
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    actionLabel.contains('Rebaixar')
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    size: 20,
                  ),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: onAction,
                ),
              ),
            ),
          ],
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