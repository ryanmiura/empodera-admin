import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';

class UsuarioScreen extends StatefulWidget {
  const UsuarioScreen({super.key});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  final FirebaseFirestore _primaryFirestore = FirebaseFirestore.instance;
  late final FirebaseFirestore _secondaryFirestore;
  bool _showSecondaryDatabase = false;
  bool _secondaryAppInitialized = false;
  String? _initializationError;
  String _filtroStatus = 'todos'; // 'todos', 'aprovado', 'não aprovado'

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
    if (index == 5) return;
    Navigator.pop(context);
  }

  Future<void> _atualizarStatusUsuario(String userId, String novoStatus) async {
    try {
      final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;

      await firestore
          .collection('usuario')
          .doc(userId)
          .update({'status': novoStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status alterado para $novoStatus!')),
      );
    } catch (e) {
      debugPrint('Erro ao atualizar status do usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar: ${e.toString()}')),
      );
    }
  }

  Future<void> _excluirUsuario(String userId) async {
    try {
      final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;

      await firestore.collection('usuario').doc(userId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário excluído com sucesso!')),
      );
    } catch (e) {
      debugPrint('Erro ao excluir usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao excluir: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Gestão de Usuários',
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
                      ? 'Usuários (Secundário)'
                      : 'Usuários',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF663572),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_secondaryAppInitialized)
                  Chip(
                    label: Text(_showSecondaryDatabase ? 'Secundário' : 'Principal'),
                    backgroundColor: const Color(0xFF663572),
                    labelStyle: const TextStyle(color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Filtro de status
            DropdownButton<String>(
              value: _filtroStatus,
              items: const [
                DropdownMenuItem(value: 'todos', child: Text('Todos os usuários')),
                DropdownMenuItem(value: 'aprovado', child: Text('Aprovados')),
                DropdownMenuItem(value: 'não aprovado', child: Text('Não aprovados')),
              ],
              onChanged: (value) {
                setState(() {
                  _filtroStatus = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _showSecondaryDatabase && !_secondaryAppInitialized
                  ? _buildSecondaryAppError()
                  : _buildUsuariosList(),
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

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return '--';
    return '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}';
  }

  String _getFieldValue(Map<String, dynamic> data, String field) {
    return data[field]?.toString() ?? '--';
  }

  Widget _buildUsuariosList() {
    final firestore = _showSecondaryDatabase ? _secondaryFirestore : _primaryFirestore;
    Query query = firestore.collection('usuario');

    // Aplicar filtro de status
    if (_filtroStatus != 'todos') {
      query = query.where('status', isEqualTo: _filtroStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.orderBy('nome').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar usuários: ${snapshot.error}'),
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
                  ? 'Nenhum usuário no banco secundário'
                  : 'Nenhum usuário encontrado',
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
            final usuario = snapshot.data!.docs[index];
            final data = usuario.data() as Map<String, dynamic>;
            final status = data['status'] ?? 'não aprovado';
            Color statusColor = Colors.grey;

            if (status == 'aprovado') statusColor = Colors.green;
            else if (status == 'não aprovado') statusColor = Colors.orange;

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
                      _getFieldValue(data, 'nome'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF663572),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email: ${_getFieldValue(data, 'email')}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'CPF: ${_getFieldValue(data, 'cpf')}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Data de criação: ${_formatarData(data['dataCriacao'] as Timestamp?)}',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text(
                          'Status: ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
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
                            if (value == 'excluir') {
                              await _excluirUsuario(usuario.id);
                            } else {
                              await _atualizarStatusUsuario(usuario.id, value);
                            }
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'aprovado',
                              child: Text('Marcar como Aprovado'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'não aprovado',
                              child: Text('Marcar como Não Aprovado'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'excluir',
                              child: Text('Excluir Usuário', style: TextStyle(color: Colors.red)),
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