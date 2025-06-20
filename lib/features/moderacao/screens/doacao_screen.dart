import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class DoacaoScreen extends StatefulWidget {
  const DoacaoScreen({super.key});

  @override
  State<DoacaoScreen> createState() => _DoacaoScreenState();
}

class _DoacaoScreenState extends State<DoacaoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroCategoria = 'todas'; // 'todas' ou categorias específicas

  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 2) return; // Já estamos na tela de doações
    Navigator.pop(context); // Volta para a tela anterior
  }

  Future<void> _excluirDoacao(String doacaoId) async {
    try {
      await _firestore.collection('donations').doc(doacaoId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doação excluída com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao excluir doação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir doação: ${e.toString()}')),
      );
    }
  }

  Future<void> _ocultarDoacao(String doacaoId) async {
    try {
      await _firestore.collection('donations').doc(doacaoId).update({'oculto': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Doação ocultada com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao ocultar doação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ocultar doação: ${e.toString()}')),
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
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Doações',
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
              'Moderação de Doações',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF663572),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _filtroCategoria,
              items: const [
                DropdownMenuItem(value: 'todas', child: Text('Todas as categorias')),
                DropdownMenuItem(value: 'Roupas', child: Text('Roupas')),
                DropdownMenuItem(value: 'Alimentos', child: Text('Alimentos')),
                DropdownMenuItem(value: 'Brinquedos', child: Text('Brinquedos')),
                // Adicione outras categorias conforme necessário
              ],
              onChanged: (value) {
                setState(() {
                  _filtroCategoria = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildDoacoesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDoacoesList() {
    Query query = _firestore.collection('donations').orderBy('timestamp', descending: true);

    if (_filtroCategoria != 'todas') {
      query = query.where('category', isEqualTo: _filtroCategoria);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar doações: ${snapshot.error}'),
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
              'Nenhuma doação encontrada',
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
            final doacao = snapshot.data!.docs[index];
            final data = doacao.data() as Map<String, dynamic>;

            return Card(
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
                      'ID: ${doacao.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF663572),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Título: ${_getFieldValue(data, 'title')}',
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Categoria: ${_getFieldValue(data, 'category')}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data: ${_formatarData(data['timestamp'] as Timestamp?)}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usuário: ${_getFieldValue(data, 'userId')}',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Descrição: ${_getFieldValue(data, 'description')}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Curtidas: ${_getFieldValue(data, 'likes')}',
                          style: const TextStyle(fontSize: 14),
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
                            if (value == 'excluir') {
                              await _excluirDoacao(doacao.id);
                            } else if (value == 'ocultar') {
                              await _ocultarDoacao(doacao.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'excluir',
                              child: Text('Excluir doação'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'ocultar',
                              child: Text('Ocultar doação'),
                            ),
                          ],
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
    );
  }
}