import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ContaProfiInfoScreen extends StatefulWidget {
  final String usuarioId;

  const ContaProfiInfoScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<ContaProfiInfoScreen> createState() => _ContaProfiInfoScreenState();
}

class _ContaProfiInfoScreenState extends State<ContaProfiInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? usuarioData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      DocumentSnapshot usuarioSnapshot =
          await _firestore.collection('usuario').doc(widget.usuarioId).get();

      if (!usuarioSnapshot.exists) {
        throw Exception('Usuário não encontrado');
      }

      setState(() {
        usuarioData = usuarioSnapshot.data() as Map<String, dynamic>;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Erro ao carregar dados: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatarData(Timestamp? timestamp) {
    if (timestamp == null) return '--';
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Usuário'),
        backgroundColor: const Color(0xFF663572),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),
              ),
            )
          : usuarioData == null
              ? const Center(child: Text('Usuário não encontrado'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho com avatar e nome
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFF663572),
                              child: Text(
                                (usuarioData!['nome']?.toString() ?? 'U')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              usuarioData!['nome']?.toString() ?? 'Nome não informado',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF663572),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(usuarioData!['status']?.toString() ?? ''),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                usuarioData!['status']?.toString() ?? 'Status não informado',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Informações de contato com botões de cópia
                      const Text(
                        'Informações de Contato',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF663572),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoTileComCopia(
                        'Email',
                        usuarioData!['email']?.toString(),
                        Icons.email,
                        () => _copiarParaAreaTransferencia(
                          usuarioData!['email']?.toString() ?? '',
                          'Email',
                        ),
                      ),
                      _buildInfoTileComCopia(
                        'Telefone',
                        usuarioData!['telefone']?.toString(),
                        Icons.phone,
                        () => _copiarParaAreaTransferencia(
                          usuarioData!['telefone']?.toString() ?? '',
                          'Telefone',
                        ),
                      ),
                      _buildInfoTileComCopia(
                        'CPF',
                        usuarioData!['cpf']?.toString(),
                        Icons.badge,
                        () => _copiarParaAreaTransferencia(
                          usuarioData!['cpf']?.toString() ?? '',
                          'CPF',
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Informações do perfil
                      const Text(
                        'Informações do Perfil',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color(0xFF663572),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _infoTile('Data de Criação', _formatarData(usuarioData!['dataCriacao'] as Timestamp?)),
                      _infoTile('Última Atividade', _formatarData(usuarioData!['ultimaAtividade'] as Timestamp?)),
                      _infoTile('Tipo de Usuário', usuarioData!['tipoUsuario']?.toString()),
                      _infoTile('Status', usuarioData!['status']?.toString()),

                      const SizedBox(height: 32),

                      // Botões de ação
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _aprovarUsuario(),
                              icon: const Icon(Icons.check),
                              label: const Text('Aprovar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _rejeitarUsuario(),
                              icon: const Icon(Icons.close),
                              label: const Text('Rejeitar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildInfoTileComCopia(String label, String? value, IconData icon, VoidCallback onCopy) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF663572)),
        title: Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF663572),
          ),
        ),
        subtitle: Text(
          value ?? 'Não informado',
          style: const TextStyle(fontSize: 16),
        ),
        trailing: value != null && value.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.copy, color: Color(0xFF663572)),
                onPressed: onCopy,
                tooltip: 'Copiar $label',
              )
            : null,
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? '--',
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'profissional aprovado':
        return Colors.green;
      case 'profissional rejeitado':
        return Colors.red;
      case 'validação profissional pendente':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Future<void> _aprovarUsuario() async {
    try {
      await _firestore.collection('usuario').doc(widget.usuarioId).update({
        'status': 'profissional aprovado',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário aprovado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Erro ao aprovar usuário: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao aprovar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejeitarUsuario() async {
    try {
      await _firestore.collection('usuario').doc(widget.usuarioId).update({
        'status': 'profissional rejeitado',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuário rejeitado com sucesso!'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Erro ao rejeitar usuário: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao rejeitar: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
