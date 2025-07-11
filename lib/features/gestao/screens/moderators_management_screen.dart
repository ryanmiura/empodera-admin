import 'package:flutter/material.dart';
import '../controllers/admin_moderators_controller.dart';
import '../models/admin_user_model.dart';

class ModeratorsManagementScreen extends StatefulWidget {
  const ModeratorsManagementScreen({Key? key}) : super(key: key);

  @override
  State<ModeratorsManagementScreen> createState() => _ModeratorsManagementScreenState();
}

class _ModeratorsManagementScreenState extends State<ModeratorsManagementScreen> {
  final AdminModeratorsController _controller = AdminModeratorsController();
  late Future<List<AdminUserModel>> _pendingModerators;

  @override
  void initState() {
    super.initState();
    _pendingModerators = _controller.fetchPendingModerators();
  }

  void _refresh() {
    setState(() {
      _pendingModerators = _controller.fetchPendingModerators();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Moderadores'),
      ),
      body: FutureBuilder<List<AdminUserModel>>(
        future: _pendingModerators,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final moderators = snapshot.data ?? [];
          if (moderators.isEmpty) {
            return const Center(child: Text('Nenhum moderador pendente.'));
          }
          return ListView.builder(
            itemCount: moderators.length,
            itemBuilder: (context, index) {
              final moderator = moderators[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.person, color: Colors.grey[400], size: 32),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  moderator.nome.isNotEmpty ? moderator.nome : 'Nome não informado',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'UID: ${moderator.id}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(Icons.email_outlined, color: Colors.grey[400], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              moderator.email,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.grey[400], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              moderator.telefone.isNotEmpty ? moderator.telefone : "Não informado",
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            moderator.createdAt != null
                                ? "${moderator.createdAt!.day.toString().padLeft(2, '0')}/${moderator.createdAt!.month.toString().padLeft(2, '0')}/${moderator.createdAt!.year}"
                                : "Não informado",
                            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.verified_user, color: Colors.grey[400], size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Status: ${moderator.status}',
                            style: TextStyle(fontSize: 14, color: Colors.blue[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.check_circle_outline, size: 20),
                              label: const Text(
                                'Aprovar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () async {
                                await _controller.approveModerator(moderator.id);
                                _refresh();
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red[600],
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.cancel_outlined, size: 20),
                              label: const Text(
                                'Rejeitar',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              onPressed: () async {
                                await _controller.rejectModerator(moderator.id);
                                _refresh();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}