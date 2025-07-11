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
              return ListTile(
                title: Text(moderator.email),
                subtitle: Text('Status: ${moderator.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        await _controller.approveModerator(moderator.id);
                        _refresh();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await _controller.rejectModerator(moderator.id);
                        _refresh();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}