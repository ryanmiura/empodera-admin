import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
import 'denuncia_info.dart';

class DenunciaScreen extends StatefulWidget {
  const DenunciaScreen({super.key});

  @override
  State<DenunciaScreen> createState() => _DenunciaScreenState();
}

class _DenunciaScreenState extends State<DenunciaScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroStatus = 'todos'; // 'todos', 'pendente', 'resolvido', 'arquivado'

  void _handleNavigation(int index) {
    Navigator.pop(context);
    if (index == 4) return;
    Navigator.pop(context);
  }

  Future<void> _atualizarStatusDenuncia(String denunciaId, String novoStatus) async {
    try {
      await _firestore.collection('report').doc(denunciaId).update({'status': novoStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para $novoStatus')),
      );
    } catch (e) {
      debugPrint('Erro ao atualizar status da denúncia: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: ${e.toString()}')),
      );
    }
  }

  Future<void> _excluirPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post excluído com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao excluir post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir post: ${e.toString()}')),
      );
    }
  }

  Future<void> _ocultarPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({'oculto': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post ocultado com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao ocultar post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ocultar post: ${e.toString()}')),
      );
    }
  }

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return '--';
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }

  String _getFieldValue(Map<String, dynamic> data, String field) {
    return data[field]?.toString() ?? '--';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          DropdownButton<String>(
            value: _filtroStatus,
            items: const [
              DropdownMenuItem(value: 'todos', child: Text('Todas denúncias')),
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
    );
  }

  Widget _buildDenunciasList() {
    Query query = _firestore.collection('report').orderBy('timestamp', descending: true);

    if (_filtroStatus != 'todos') {
      query = query.where('status', isEqualTo: _filtroStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
              'Nenhuma denúncia encontrada',
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
            final postId = data['postId'];
            final status = data['status'] ?? 'pendente';
            final contentType = data['contentType'] ?? '--';
            Color statusColor = Colors.grey;

            if (status == 'pendente') statusColor = Colors.orange;
            else if (status == 'resolvido') statusColor = Colors.green;
            else if (status == 'arquivado') statusColor = Colors.blue;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DenunciaInfoScreen(
                      denunciaId: denuncia.id,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        postId != null ? 'Post ID: $postId' : 'Denúncia ID: ${denuncia.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF663572),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo de denúncia: $contentType',
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Motivo: ${_getFieldValue(data, 'motivo')}',
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Data: ${_formatarData(data['timestamp'] as Timestamp?)}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Denunciante: ${_getFieldValue(data, 'userId')}',
                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Text(
                            'Status: ',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 14,
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Color(0xFF663572),
                            ),
                            onSelected: (value) async {
                              if (value == 'excluir' && postId != null) {
                                await _excluirPost(postId);
                                await _atualizarStatusDenuncia(denuncia.id, 'resolvido');
                              } else if (value == 'ocultar' && postId != null) {
                                await _ocultarPost(postId);
                                await _atualizarStatusDenuncia(denuncia.id, 'resolvido');
                              } else {
                                await _atualizarStatusDenuncia(denuncia.id, value);
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'resolvido',
                                child: Text('Marcar como resolvido'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'arquivado',
                                child: Text('Arquivar denúncia'),
                              ),
                              if (postId != null) ...[
                                const PopupMenuItem<String>(
                                  value: 'excluir',
                                  child: Text('Excluir post'),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'ocultar',
                                  child: Text('Ocultar post'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}