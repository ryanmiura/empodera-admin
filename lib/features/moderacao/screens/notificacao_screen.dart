import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_drawer.dart';
import 'package:flutter/services.dart';

class DataInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length > 6) text = text.substring(0, 6);
    var newText = '';
    for (int i = 0; i < text.length; i++) {
      newText += text[i];
      if (i == 1 || i == 3) {
        newText += '/';
      }
    }
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class NotificacaoScreens extends StatefulWidget {
  const NotificacaoScreens({super.key});

  @override
  State<NotificacaoScreens> createState() => _NotificacaoScreensState();
}

class _NotificacaoScreensState extends State<NotificacaoScreens> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeEventoController = TextEditingController();
  final TextEditingController _dataInicioController = TextEditingController();
  final TextEditingController _dataFinalController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();

  Future<void> _enviarNotificacao() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await _firestore.collection('notifica').add({
        'nomeEvento': _nomeEventoController.text,
        'dataInicio': _dataInicioController.text,
        'dataFinal': _dataFinalController.text,
        'endereco': _enderecoController.text,
        'link': _linkController.text,
        'status': 'ativo',
        'criadoEm': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notificação criada com sucesso!')),
      );
      _formKey.currentState!.reset();
      _nomeEventoController.clear();
      _dataInicioController.clear();
      _dataFinalController.clear();
      _enderecoController.clear();
      _linkController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar notificação:  [${e.toString()}')),
      );
    }
  }

  Future<void> _atualizarStatusNotificacao(String id, String novoStatus) async {
    try {
      await _firestore.collection('notifica').doc(id).update({
        'status': novoStatus,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status atualizado para $novoStatus!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar status: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(onNavigate: (index) {}),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nomeEventoController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do Evento',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Preencha o nome do evento'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dataInicioController,
                    decoration: const InputDecoration(
                      labelText: 'Data de Início',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      DataInputFormatter(),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Preencha a data de início';
                      if (!RegExp(
                        r'^[0-9]{2}/[0-9]{2}/[0-9]{2}',
                      ).hasMatch(value))
                        return 'Formato: dd/mm/aa';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _dataFinalController,
                    decoration: const InputDecoration(labelText: 'Data Final'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      DataInputFormatter(),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Preencha a data final';
                      if (!RegExp(
                        r'^[0-9]{2}/[0-9]{2}/[0-9]{2}',
                      ).hasMatch(value))
                        return 'Formato: dd/mm/aa';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _enderecoController,
                    decoration: const InputDecoration(
                      labelText: 'Endereço do Local',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Preencha o endereço'
                        : null,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _linkController,
                    decoration: const InputDecoration(
                      labelText: 'Link (opcional)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _enviarNotificacao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF663572),
                    ),
                    child: const Text(
                      'Enviar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Notificações já criadas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(child: _buildNotificacoesList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificacoesList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('notifica')
          .orderBy('criadoEm', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Erro ao carregar notificações: ${snapshot.error}'),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Nenhuma notificação encontrada.'));
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(data['nomeEvento'] ?? '--'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Início: ${data['dataInicio'] ?? '--'}'),
                    Text('Final: ${data['dataFinal'] ?? '--'}'),
                    Text('Endereço: ${data['endereco'] ?? '--'}'),
                    if ((data['link'] ?? '').toString().isNotEmpty)
                      Text('Link: ${data['link']}'),
                    Text('Status: ${data['status'] ?? 'ativo'}'),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'concluido') {
                      _atualizarStatusNotificacao(doc.id, 'concluido');
                    } else if (value == 'expirado') {
                      _atualizarStatusNotificacao(doc.id, 'expirado');
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'concluido',
                      child: Text('Marcar como Concluído'),
                    ),
                    const PopupMenuItem(
                      value: 'expirado',
                      child: Text('Marcar como Expirado'),
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

  @override
  void dispose() {
    _nomeEventoController.dispose();
    _dataInicioController.dispose();
    _dataFinalController.dispose();
    _enderecoController.dispose();
    _linkController.dispose();
    super.dispose();
  }
}
