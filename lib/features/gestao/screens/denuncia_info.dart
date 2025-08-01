import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
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
  Widget _buildConteudoInfo(String? tipo, Map<String, dynamic> data) {
    Widget _imagemWidget(String? base64) {
      if (base64 == null || base64.isEmpty) {
        return _infoTile('Imagem', '--');
      }
      try {
        final bytes = base64Decode(base64);
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(bytes, height: 120, fit: BoxFit.cover),
          ),
        );
      } catch (e) {
        return _infoTile('Imagem', 'Erro ao carregar imagem');
      }
    }
    switch (tipo) {
      case 'post':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Categoria', data['category'] ?? '--'),
            _infoTile('Conteúdo', data['content'] ?? '--'),
            _imagemWidget(data['image']),
          ],
        );
      case 'donation':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Categoria', data['category'] ?? '--'),
            _infoTile('Descrição', data['description'] ?? '--'),
            _imagemWidget(data['image']),
          ],
        );
      case 'comment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Conteúdo', data['content'] ?? '--'),
            _infoTile('Post ID', data['postId'] ?? '--'),
            _infoTile('Usuário', data['userName'] ?? data['userId'] ?? '--'),
            _infoTile('Data', _formatarData(data['timestamp'] as Timestamp?)),
          ],
        );
      case 'donation_comment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Conteúdo', data['content'] ?? '--'),
            _infoTile('Post ID', data['postId'] ?? '--'),
            _infoTile('Usuário', data['userName'] ?? data['userId'] ?? '--'),
            _infoTile('Data', _formatarData(data['timestamp'] as Timestamp?)),
          ],
        );
      case 'chat':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoTile('Última Mensagem', data['lastMessage'] ?? '--'),
            _infoTile('Horário da Última Mensagem', _formatarData(data['lastMessageTime'] as Timestamp?)),
            _infoTile('Oculto', (data['oculto'] == true) ? 'Sim' : 'Não'),
            _infoTile('Participantes', (data['userNames'] ?? (data['participants'] ?? '--')).toString()),
          ],
        );
      default:
        return const Text('Tipo de conteúdo não reconhecido');
    }
  }
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

      // Buscar dados do conteúdo denunciado conforme o tipo
      String contentType = denuncia['contentType'] ?? '';
      String contentId = denuncia['contentId'] ?? denuncia['postId'] ?? '';
      Map<String, dynamic>? conteudoData;
      if (contentType == 'post') {
        DocumentSnapshot snap = await _firestore.collection('posts').doc(contentId).get();
        conteudoData = snap.data() as Map<String, dynamic>?;
        debugPrint('Dados do post: ${jsonEncode(conteudoData)}');
      } else if (contentType == 'donation') {
        DocumentSnapshot snap = await _firestore.collection('donations').doc(contentId).get();
        conteudoData = snap.data() as Map<String, dynamic>?;
      } else if (contentType == 'comment') {
        DocumentSnapshot snap = await _firestore.collection('comments').doc(contentId).get();
        conteudoData = snap.data() as Map<String, dynamic>?;
      } else if (contentType == 'donation_comment') {
        DocumentSnapshot snap = await _firestore.collection('donation_comments').doc(contentId).get();
        conteudoData = snap.data() as Map<String, dynamic>?;
      } else if (contentType == 'chat') {
        DocumentSnapshot snap = await _firestore.collection('chats').doc(contentId).get();
        conteudoData = snap.data() as Map<String, dynamic>?;
      }
      setState(() {
        denunciaData = denuncia;
        postData = conteudoData;
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
            _infoTile('Tipo de Denúncia', denunciaData!['contentType']),
            _infoTile('Status', denunciaData!['status']),
            _infoTile('Data',
                _formatarData(denunciaData!['timestamp'] as Timestamp?)),
            _infoTile('Post ID', denunciaData!['contentId']),
            const Divider(height: 32, thickness: 1),
            Text(
              'Informações do Conteúdo Denunciado',
              style: const TextStyle(
                fontSize: 20,
                color: Color(0xFF663572),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            postData != null
                ? _buildConteudoInfo(denunciaData!['contentType'], postData!)
                : Text(
                    'O conteúdo não foi encontrado (pode ter sido excluído)',
                    style: const TextStyle(color: Colors.red),
                  ),
// Função declarada fora da lista de widgets
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
