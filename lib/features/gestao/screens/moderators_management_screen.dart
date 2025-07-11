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
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        moderator.nome.isNotEmpty ? moderator.nome : 'Nome não informado',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text('E-mail: ${moderator.email}'),
                      Text('Telefone: ${moderator.telefone.isNotEmpty ? moderator.telefone : "Não informado"}'),
                      Text('UID: ${moderator.id}'),
                      Text(
                        'Criado em: ${moderator.createdAt != null ? "${moderator.createdAt!.day.toString().padLeft(2, '0')}/${moderator.createdAt!.month.toString().padLeft(2, '0')}/${moderator.createdAt!.year}" : "Não informado"}',
                      ),
                      const SizedBox(height: 4),
                      Text('Status: ${moderator.status}'),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                await _controller.approveModerator(moderator.id);
                                _refresh();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Aprovar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () async {
                                await _controller.rejectModerator(moderator.id);
                                _refresh();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Rejeitar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
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