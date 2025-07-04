import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';

class DenunciaInfoScreen extends StatefulWidget {
  final String denunciaId;

  const DenunciaInfoScreen({
    super.key,
    required this.denunciaId,
  });

  @override
  State<DenunciaInfoScreen> createState() => _DenunciaInfoScreenState();
}

class _DenunciaInfoScreenState extends State<DenunciaInfoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? denunciaData;
  Map<String, dynamic>? postData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      // Buscar dados da denúncia
      DocumentSnapshot denunciaSnapshot =
      await _firestore.collection('report').doc(widget.denunciaId).get();

      if (!denunciaSnapshot.exists) {
        throw Exception('Denúncia não encontrada');
      }

      final denuncia = denunciaSnapshot.data() as Map<String, dynamic>;

      // Buscar dados do post denunciado
      DocumentSnapshot postSnapshot = await _firestore
          .collection('posts')
          .doc(denuncia['postId'])
          .get();

      setState(() {
        denunciaData = denuncia;
        postData = postSnapshot.data() as Map<String, dynamic>?;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalhes da Denúncia'),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),
        ),
      )
          : denunciaData == null
          ? const Center(child: Text('Denúncia não encontrada'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações da Denúncia',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF663572),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _infoTile('Motivo', denunciaData!['motivo']),
            _infoTile('Denunciante', denunciaData!['userId']),
            _infoTile('Status', denunciaData!['status']),
            _infoTile('Data',
                _formatarData(denunciaData!['timestamp'] as Timestamp?)),
            _infoTile('Post ID', denunciaData!['postId']),
            const Divider(height: 32, thickness: 1),
            const Text(
              'Informações do Post Denunciado',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF663572),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            postData != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile('Autor', postData!['userId']),
                _infoTile('Conteúdo',
                    postData!['content'] ?? 'Sem conteúdo'),
                _infoTile(
                    'Data de Criação',
                    _formatarData(
                        postData!['timestamp'] as Timestamp?)),
                _infoTile('Oculto',
                    (postData!['oculto'] == true) ? 'Sim' : 'Não'),
              ],
            )
                : const Text(
              'O post não foi encontrado (pode ter sido excluído)',
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
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
}
