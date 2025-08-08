import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'conta_profi_info_screen.dart';

class ContaProfiScreen extends StatefulWidget {
  const ContaProfiScreen({super.key});

  @override
  State<ContaProfiScreen> createState() => _ContaProfiScreenState();
}

class _ContaProfiScreenState extends State<ContaProfiScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroAtual = 'validaçao profissional pendente';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getTituloFiltro(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF663572),
            ),
          ),
          const SizedBox(height: 12),
          _buildFiltroDropdown(),
          const SizedBox(height: 16),
          Expanded(child: _buildUsuariosList()),
        ],
      ),
    );
  }

  Widget _buildUsuariosList() {
    Query query = _firestore.collection('usuario')
        .where('estatos', isEqualTo: _filtroAtual);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
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
              _getMensagemVazia(),
              style: const TextStyle(fontSize: 16, color: Color(0xFF663572)),
            ),
          );
        }

        final usuarios = snapshot.data!.docs;
        
        return ListView.builder(
          itemCount: usuarios.length,
          itemBuilder: (context, index) {
            final usuario = usuarios[index];
            final data = usuario.data() as Map<String, dynamic>;
            
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
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: const Color(0xFF663572),
                          child: Text(
                            (data['nome']?.toString() ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['nome']?.toString() ?? 'Nome não informado',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF663572),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Email com botão de cópia
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['email']?.toString() ?? 'Email não informado',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (data['email'] != null && data['email'].toString().isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 16, color: Color(0xFF663572)),
                                      onPressed: () => _copiarParaAreaTransferencia(
                                        data['email'].toString(),
                                        'Email',
                                      ),
                                      tooltip: 'Copiar email',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              // Telefone com botão de cópia
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['telefone']?.toString() ?? 'Telefone não informado',
                                      style: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (data['telefone'] != null && data['telefone'].toString().isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.copy, size: 16, color: Color(0xFF663572)),
                                      onPressed: () => _copiarParaAreaTransferencia(
                                        data['telefone'].toString(),
                                        'Telefone',
                                      ),
                                      tooltip: 'Copiar telefone',
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(data['estatos']?.toString() ?? ''),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  data['estatos']?.toString() ?? 'Status não informado',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBotoesAcao(usuario.id, data['estatos']?.toString() ?? ''),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _aprovarUsuario(String userId) async {
    try {
      await _firestore.collection('usuario').doc(userId).update({
        'estatos': 'profissional aprovado',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário aprovado com sucesso!')),
      );
    } catch (e) {
      debugPrint('Erro ao aprovar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao aprovar: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejeitarUsuario(String userId) async {
    try {
      await _firestore.collection('usuario').doc(userId).update({
        'estatos': 'profissional rejeitado',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário rejeitado com sucesso!')),
      );
    } catch (e) {
      debugPrint('Erro ao rejeitar usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao rejeitar: ${e.toString()}')),
      );
    }
  }

  Future<void> _copiarParaAreaTransferencia(String texto, String tipo) async {
    await Clipboard.setData(ClipboardData(text: texto));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$tipo copiado para a área de transferência!'),
          backgroundColor: const Color(0xFF663572),
        ),
      );
    }
  }

  void _verDetalhes(String userId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ContaProfiInfoScreen(usuarioId: userId),
      ),
    );
  }

  String _getTituloFiltro() {
    switch (_filtroAtual) {
      case 'validaçao profissional pendente':
        return 'Validação Profissional Pendente';
      case 'profissional aprovado':
        return 'Profissionais Aprovados';
      case 'profissional rejeitado':
        return 'Profissionais Rejeitados';
      default:
        return 'Validação Profissional';
    }
  }

  String _getMensagemVazia() {
    switch (_filtroAtual) {
      case 'validaçao profissional pendente':
        return 'Nenhum usuário com validação profissional pendente';
      case 'profissional aprovado':
        return 'Nenhum profissional aprovado encontrado';
      case 'profissional rejeitado':
        return 'Nenhum profissional rejeitado encontrado';
      default:
        return 'Nenhum usuário encontrado';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'profissional aprovado':
        return Colors.green;
      case 'profissional rejeitado':
        return Colors.red;
      case 'validaçao profissional pendente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildFiltroDropdown() {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF663572)),
      ),
      child: DropdownButton<String>(
        value: _filtroAtual,
        underline: Container(),
        icon: const Icon(Icons.filter_list, color: Color(0xFF663572)),
        style: const TextStyle(
          color: Color(0xFF663572),
          fontSize: 14,
        ),
        items: const [
          DropdownMenuItem(
            value: 'validaçao profissional pendente',
            child: Text('Pendentes'),
          ),
          DropdownMenuItem(
            value: 'profissional aprovado',
            child: Text('Aprovados'),
          ),
          DropdownMenuItem(
            value: 'profissional rejeitado',
            child: Text('Rejeitados'),
          ),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _filtroAtual = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildBotoesAcao(String userId, String status) {
    switch (status) {
      case 'profissional aprovado':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _rejeitarUsuario(userId),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Rejeitar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _verDetalhes(userId),
              icon: const Icon(Icons.info, size: 18),
              label: const Text('Detalhes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF663572),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        );
      case 'profissional rejeitado':
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _aprovarUsuario(userId),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Aprovar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _verDetalhes(userId),
              icon: const Icon(Icons.info, size: 18),
              label: const Text('Detalhes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF663572),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        );
      default: // validaçao profissional pendente
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _aprovarUsuario(userId),
                icon: const Icon(Icons.check, size: 18),
                label: const Text('Aprovar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _rejeitarUsuario(userId),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Rejeitar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => _verDetalhes(userId),
              icon: const Icon(Icons.info, size: 18),
              label: const Text('Detalhes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF663572),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ],
        );
    }
  }
}
