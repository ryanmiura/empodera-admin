import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class DenunciaScreen extends StatefulWidget {
  const DenunciaScreen({super.key});

  @override
  State<DenunciaScreen> createState() => _DenunciaScreenState();
}

class _DenunciaScreenState extends State<DenunciaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer atual
    if (index == 4) {
      // Já estamos na tela de denúncias
      return;
    }
    Navigator.pop(context); // Volta para a tela anterior
  }

  Future<void> _atualizarStatusDenuncia(String denunciaId, String novoStatus) async {
    try {
      await _firestore
          .collection('empodera')
          .doc('dados')
          .collection('report')
          .doc(denunciaId)
          .update({'status': novoStatus});
    } catch (e) {
      print('Erro ao atualizar status da denúncia: $e');
      // Você pode adicionar um feedback visual aqui se desejar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Denúncias',
      ),
      drawer: CustomDrawer(
        onNavigate: _handleNavigation,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Denúncias Pendentes',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('empodera')
                    .doc('dados')
                    .collection('report')
                    .where('status', isEqualTo: 'pendente')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro ao carregar denúncias: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Nenhuma denúncia pendente',
                        style: TextStyle(
                          color: Color(0xFF663572),
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final denuncia = snapshot.data!.docs[index];
                      final data = denuncia.data() as Map<String, dynamic>;
                      
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            'Post ID: ${data['postId']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF663572),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Motivo: ${data['motivo']}',
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Data: ${(data['timestamp'] as Timestamp?)?.toDate().toString().split('.')[0] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (data['userId'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Denunciante: ${data['userId']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF663572),
                            ),
                            onSelected: (value) => _atualizarStatusDenuncia(denuncia.id, value),
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'resolvido',
                                child: Text('Marcar como resolvido'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'arquivado',
                                child: Text('Arquivar denúncia'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
