import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroStatus = 'todos'; // 'todos', 'publicado', 'oculto'

  void _handleNavigation(int index) {
    Navigator.pop(context); // Fecha o drawer
    if (index == 1) return; // Já estamos na tela do fórum
    Navigator.pop(context); // Volta para a tela anterior
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

  Future<void> _publicarPost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({'oculto': false});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post publicado com sucesso')),
      );
    } catch (e) {
      debugPrint('Erro ao publicar post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao publicar post: ${e.toString()}')),
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
      appBar: const CustomAppBar(title: 'Fórum'),
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
                DropdownMenuItem(value: 'todos', child: Text('Todos os posts')),
                DropdownMenuItem(value: 'publicado', child: Text('Publicados')),
                DropdownMenuItem(value: 'oculto', child: Text('Ocultos')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildPostsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList() {
    Query query = _firestore.collection('posts').orderBy('timestamp', descending: true);

    if (_filtroStatus != 'todos') {
      final oculto = _filtroStatus == 'oculto';
      query = query.where('oculto', isEqualTo: oculto);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar posts: ${snapshot.error}'),
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
              'Nenhum post encontrado',
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
            final post = snapshot.data!.docs[index];
            final data = post.data() as Map<String, dynamic>;
            final isOculto = data['oculto'] == true;

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
                    Row(
                      children: [
                        if (isOculto)
                          const Icon(Icons.visibility_off, color: Colors.red, size: 16),
                        if (isOculto) const SizedBox(width: 4),
                        Text(
                          'ID: ${post.id}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF663572),
                            fontStyle: isOculto ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Título: ${_getFieldValue(data, 'title')}',
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
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
                        'Conteúdo: ${_getFieldValue(data, 'content')}',
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
                              await _excluirPost(post.id);
                            } else if (value == 'ocultar') {
                              await _ocultarPost(post.id);
                            } else if (value == 'publicar') {
                              await _publicarPost(post.id);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            if (isOculto)
                              const PopupMenuItem<String>(
                                value: 'publicar',
                                child: Text('Publicar post'),
                              ),
                            if (!isOculto)
                              const PopupMenuItem<String>(
                                value: 'ocultar',
                                child: Text('Ocultar post'),
                              ),
                            const PopupMenuItem<String>(
                              value: 'excluir',
                              child: Text('Excluir post'),
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