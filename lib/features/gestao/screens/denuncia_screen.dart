import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class DenunciaScreen extends StatefulWidget {
  const DenunciaScreen({super.key});

  @override
  State<DenunciaScreen> createState() => _DenunciaScreenState();
}

class _DenunciaScreenState extends State<DenunciaScreen> {
  final FirebaseFirestore _primaryFirestore = FirebaseFirestore.instance;
  late final FirebaseFirestore _secondaryFirestore;
  bool _showSecondaryDatabase = false;
  bool _secondaryAppInitialized = false;
  String? _initializationError;

  @override
  void initState() {
    super.initState();
    _initializeSecondaryFirestore();
  }

  Future<void> _initializeSecondaryFirestore() async {
    try {
      final secondaryApp = Firebase.app('SecondaryApp');
      _secondaryFirestore = FirebaseFirestore.instanceFor(app: secondaryApp);
      setState(() {
        _secondaryAppInitialized = true;
      });
    } catch (e) {
      setState(() {
        _secondaryAppInitialized = false;
        _initializationError = e.toString();
      });
      debugPrint('Erro ao acessar SecondaryApp: $e');
    }
  }

  void _handleNavigation(int index) {
    Navigator.pop(context);
    if (index == 4) return;
    Navigator.pop(context);
  }

  Future<void> _atualizarStatusDenuncia(String denunciaId, String novoStatus) async {
    try {
      final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;

      await firestore
          .collection('report')
          .doc(denunciaId)
          .update({'status': novoStatus});

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
      final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;

      await firestore.collection('posts').doc(postId).delete();

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
      final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;

      await firestore.collection('posts').doc(postId).update({'oculto': true});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Denúncias',
      ),
      drawer: CustomDrawer(
        onNavigate: _handleNavigation,
      ),
      floatingActionButton: _secondaryAppInitialized
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _showSecondaryDatabase = !_showSecondaryDatabase;
          });
        },
        child: Icon(_showSecondaryDatabase ? Icons.switch_left : Icons.switch_right),
        backgroundColor: const Color(0xFF663572),
      )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _showSecondaryDatabase
                      ? 'Denúncias (Secundário)'
                      : 'Denúncias ',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Chip(
                  label: Text('Secundário'),
                  backgroundColor: const Color(0xFF663572),
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _showSecondaryDatabase && !_secondaryAppInitialized
                  ? _buildSecondaryAppError()
                  : _buildDenunciasList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryAppError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text(
            'Banco secundário não disponível',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          if (_initializationError != null) ...[
            const SizedBox(height: 10),
            Text(
              _initializationError!,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => _showSecondaryDatabase = false),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF663572),
            ),
            child: const Text('Voltar para o banco principal'),
          ),
        ],
      ),
    );
  }

  Widget _buildDenunciasList() {
    return StreamBuilder<QuerySnapshot>(
      stream: (_showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore)
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
          return Center(
            child: Text(
              _showSecondaryDatabase
                  ? 'Nenhuma denúncia no banco secundário'
                  : 'Nenhuma denúncia pendente',
              style: const TextStyle(
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

            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  postId != null
                      ? 'Post ID: $postId'
                      : 'Denúncia ID: ${denuncia.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF663572),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (data['motivo'] != null)
                      Text(
                        'Motivo: ${data['motivo']}',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (data['timestamp'] != null)
                      Text(
                        'Data: ${(data['timestamp'] as Timestamp).toDate().toString().split('.')[0]}',
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
              ),
            );
          },
        );
      },
    );
  }
}