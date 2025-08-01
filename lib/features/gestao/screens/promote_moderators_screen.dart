import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
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
  String? _userRole;
  bool _isProfileLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchCurrentUserAndRole();
  }

  Future<void> _fetchCurrentUserAndRole() async {
    // Usa instância já inicializada do app secundário
    final app = Firebase.app('admin-auth');
    final auth = FirebaseAuth.instanceFor(app: app);
    final uid = auth.currentUser?.uid;
    setState(() {
      _currentUid = uid;
      _isProfileLoading = true;
    });
    // Busca role do usuário logado na coleção admin_users
    if (uid != null) {
      final doc = await FirebaseFirestore.instanceFor(app: app)
          .collection('admin_users')
          .doc(uid)
          .get();
      final data = doc.data();
      setState(() {
        _userRole = data != null ? data['role'] as String? : null;
        _isProfileLoading = false;
      });
    } else {
      setState(() {
        _userRole = null;
        _isProfileLoading = false;
      });
    }
    _fetchLists();
  }

  // Método removido pois não é mais utilizado

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
      appBar: CustomAppBar(
        title: 'Promover Moderadores',
        currentIndex: 8,
      ),
      drawer: CustomDrawer(
        onNavigate: (index) {
          if (index != 8) {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(_getRouteForIndex(index));
          }
        },
      ),
      body: _isProfileLoading
          ? const Center(child: CircularProgressIndicator())
          : _userRole != "admin"
              ? Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Apenas administradores podem promover ou rebaixar moderadores.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        Material(
                          color: Colors.white,
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Theme.of(context).primaryColor,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Theme.of(context).primaryColor,
                            tabs: const [
                              Tab(text: 'Moderadores'),
                              Tab(text: 'Admin Promovidos'),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
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
                        ),
                      ],
                    ),
    );
  }

  String _getRouteForIndex(int index) {
    switch (index) {
      case 0:
        return '/dashboard';
      case 1:
        return '/forum';
      case 2:
        return '/doacoes';
      case 3:
        return '/comentarios';
      case 4:
        return '/denuncias';
      case 5:
        return '/usuarios';
      case 6:
        return '/settings';
      case 7:
        return '/moderators_management';
      case 8:
        return '/promote_moderators';
      default:
        return '/dashboard';
    }
  }
}