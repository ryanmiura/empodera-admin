import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart'; // Adicionado para StreamZip
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class ComentarioScreen extends StatefulWidget {
  const ComentarioScreen({super.key});

  @override
  State<ComentarioScreen> createState() => _ComentarioScreenState();
}

class _ComentarioScreenState extends State<ComentarioScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroTipo = 'todos'; // 'todos', 'post', 'doacao'

  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 3) return; // Já estamos na tela de comentários
    Navigator.pop(context); // Volta para a tela anterior
  }

  Future<void> _excluirComentario(String colecao, String comentarioId) async {
    try {
      await _firestore.collection(colecao).doc(comentarioId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário excluído com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao excluir comentário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir comentário: ${e.toString()}')),
      );
    }
  }

  Future<void> _ocultarComentario(String colecao, String comentarioId) async {
    try {
      await _firestore.collection(colecao).doc(comentarioId).update({'oculto': true});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comentário ocultado com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao ocultar comentário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ocultar comentário: ${e.toString()}')),
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
        title: 'Comentários',
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
              'Moderação de Comentários',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF663572),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _filtroTipo,
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos os comentários')),
                DropdownMenuItem(value: 'post', child: Text('Comentários em posts')),
                DropdownMenuItem(value: 'doacao', child: Text('Comentários em doações')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroTipo = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildComentariosList()),
          ],
        ),
      ),
    );
  }

  Widget _buildComentariosList() {
    // Se for 'todos', vamos mostrar ambos os tipos de comentários
    final mostrarPosts = _filtroTipo == 'todos' || _filtroTipo == 'post';
    final mostrarDoacoes = _filtroTipo == 'todos' || _filtroTipo == 'doacao';

    // Criar streams separadas
    final streams = <Stream<QuerySnapshot>>[];
    if (mostrarPosts) {
      streams.add(_firestore.collection('comments').orderBy('timestamp', descending: true).snapshots());
    }
    if (mostrarDoacoes) {
      streams.add(_firestore.collection('donation_comments').orderBy('timestamp', descending: true).snapshots());
    }

    // Se não há streams para mostrar, retornar widget vazio
    if (streams.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum comentário encontrado',
          style: TextStyle(
            color: Color(0xFF663572),
            fontSize: 16,
          ),
        ),
      );
    }

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip(streams),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar comentários: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty ||
            snapshot.data!.every((querySnapshot) => querySnapshot.docs.isEmpty)) {
          return const Center(
            child: Text(
              'Nenhum comentário encontrado',
              style: TextStyle(
                color: Color(0xFF663572),
                fontSize: 16,
              ),
            ),
          );
        }

        // Combinar todos os documentos das coleções
        final allDocs = <Map<String, dynamic>>[];
        for (var i = 0; i < snapshot.data!.length; i++) {
          final querySnapshot = snapshot.data![i];
          final tipo = (i == 0 && mostrarPosts) ? 'post' : 'doacao';
          final colecao = tipo == 'post' ? 'comments' : 'donation_comments';

          for (final doc in querySnapshot.docs) {
            allDocs.add({
              'tipo': tipo,
              'colecao': colecao,
              'doc': doc,
            });
          }
        }

        // Ordenar por timestamp (já vem ordenado da query)
        return ListView.builder(
          itemCount: allDocs.length,
          itemBuilder: (context, index) {
            final item = allDocs[index];
            final comentario = item['doc'] as QueryDocumentSnapshot;
            final data = comentario.data() as Map<String, dynamic>;
            final tipo = item['tipo'] as String;
            final colecao = item['colecao'] as String;

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
                      'ID: ${comentario.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF663572),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tipo: ${tipo == 'post' ? 'Comentário em Post' : 'Comentário em Doação'}',
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Usuário: ${_getFieldValue(data, 'userName')} (ID: ${_getFieldValue(data, 'userId')})',
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data: ${_formatarData(data['timestamp'] as Timestamp?)}',
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
                        _getFieldValue(data, 'content'),
                        style: const TextStyle(fontSize: 14),
                      ),
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
                              await _excluirComentario(colecao, comentario.id);
                            } else if (value == 'ocultar') {
                              await _ocultarComentario(colecao, comentario.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'excluir',
                              child: Text('Excluir comentário'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'ocultar',
                              child: Text('Ocultar comentário'),
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