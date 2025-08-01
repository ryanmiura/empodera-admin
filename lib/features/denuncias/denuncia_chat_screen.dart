import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_drawer.dart';
import '../gestao/screens/denuncia_info.dart';

class DenunciaChatScreen extends StatefulWidget {
  const DenunciaChatScreen({super.key});

  @override
  State<DenunciaChatScreen> createState() => _DenunciaChatScreenState();
}

class _DenunciaChatScreenState extends State<DenunciaChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroStatus = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Denúncias de Chats'),
      drawer: CustomDrawer(onNavigate: (index) {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _filtroStatus,
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todas')), 
                DropdownMenuItem(value: 'pendente', child: Text('Pendentes')),
                DropdownMenuItem(value: 'resolvido', child: Text('Resolvidas')),
                DropdownMenuItem(value: 'arquivado', child: Text('Arquivadas')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildDenunciasList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDenunciasList() {
    Query query = _firestore.collection('report')
      .where('contentType', isEqualTo: 'chat')
      .orderBy('timestamp', descending: true);

    if (_filtroStatus != 'todos') {
      query = query.where('status', isEqualTo: _filtroStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar denúncias: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma denúncia encontrada'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final denuncia = snapshot.data!.docs[index];
            return ListTile(
              title: Text('Motivo: ${denuncia['motivo'] ?? '--'}'),
              subtitle: Text('Status: ${denuncia['status'] ?? '--'}'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DenunciaInfoScreen(denunciaId: denuncia.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
