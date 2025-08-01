import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/widgets/custom_app_bar.dart';
import '../../shared/widgets/custom_drawer.dart';
import '../gestao/screens/denuncia_info.dart';

class DenunciaPostScreen extends StatefulWidget {
  const DenunciaPostScreen({super.key});

  @override
  State<DenunciaPostScreen> createState() => _DenunciaPostScreenState();
}

class _DenunciaPostScreenState extends State<DenunciaPostScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroStatus = 'todos';
  String _filtroOrdenacao = 'denunciadas';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Denúncias de Posts'),
      drawer: CustomDrawer(onNavigate: (index) {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _filtroStatus,
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todas')),
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filtroOrdenacao,
                    items: const [
                      DropdownMenuItem(value: 'recentes', child: Text('Mais recentes')),
                      DropdownMenuItem(value: 'denunciadas', child: Text('Mais denunciadas')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroOrdenacao = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildDenunciasList()),
          ],
        ),
      ),
    );
  }

  Widget _buildDenunciasList() {
    Query query = _firestore.collection('report')
      .where('contentType', isEqualTo: 'post');

    if (_filtroStatus != 'todos') {
      query = query.where('status', isEqualTo: _filtroStatus);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar denúncias: ${snapshot.error}'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF663572)),));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma denúncia encontrada'));
        }
        final denuncias = snapshot.data!.docs;
        // Agrupa por contentId e conta as denúncias
        final Map<String, int> contagemPorConteudo = {};
        for (var d in denuncias) {
          final cid = d['contentId'] ?? d['postId'];
          contagemPorConteudo[cid] = (contagemPorConteudo[cid] ?? 0) + 1;
        }
        List<QueryDocumentSnapshot> listaOrdenada = List.from(denuncias);
        if (_filtroOrdenacao == 'denunciadas') {
          listaOrdenada.sort((a, b) {
            final ca = contagemPorConteudo[a['contentId'] ?? a['postId']] ?? 0;
            final cb = contagemPorConteudo[b['contentId'] ?? b['postId']] ?? 0;
            // Ordem decrescente
            return cb.compareTo(ca);
          });
        } else {
          listaOrdenada.sort((a, b) {
            final ta = a['timestamp'] as Timestamp?;
            final tb = b['timestamp'] as Timestamp?;
            if (ta == null || tb == null) return 0;
            return tb.compareTo(ta);
          });
        }
        return ListView.builder(
          itemCount: listaOrdenada.length,
          itemBuilder: (context, index) {
            final denuncia = listaOrdenada[index];
            final contentId = denuncia['contentId'] ?? denuncia['postId'];
            final count = contagemPorConteudo[contentId] ?? 1;
            return ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Motivo: ${denuncia['motivo'] ?? '--'}'),
                  const SizedBox(height: 4),
                  Text('Total de denúncias do conteúdo: $count',
                    style: const TextStyle(fontSize: 13, color: Colors.deepPurple)),
                ],
              ),
              subtitle: Text('Status: ${denuncia['status'] ?? '--'}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'ver') {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DenunciaInfoScreen(denunciaId: denuncia.id),
                      ),
                    );
                  } else if (value == 'arquivar') {
                    _firestore.collection('report').doc(denuncia.id).update({'status': 'arquivado'});
                  } else if (value == 'resolver') {
                    _firestore.collection('report').doc(denuncia.id).update({'status': 'resolvido'});
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'ver', child: Text('Ver detalhes')),
                  const PopupMenuItem(value: 'arquivar', child: Text('Arquivar')),
                  const PopupMenuItem(value: 'resolver', child: Text('Resolver')),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DenunciaInfoScreen(denunciaId: denuncia.id),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
