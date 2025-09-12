import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class EventFormScreen extends StatefulWidget {
  final EventController controller;
  final Evento? evento;
  const EventFormScreen({Key? key, required this.controller, this.evento}) : super(key: key);

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  DateTime? _eventDate;
  String _imageBase64 = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.evento?.title ?? '');
    _contentController = TextEditingController(text: widget.evento?.content ?? '');
    _eventDate = widget.evento?.eventDate;
    _imageBase64 = widget.evento?.image ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        // Remove o prefixo data:image/png;base64, e envia apenas o conteúdo base64 puro
        _imageBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _eventDate == null) return;
    setState(() => _loading = true);
    final evento = Evento(
      id: widget.evento?.id ?? '',
      title: _titleController.text,
      content: _contentController.text,
      eventDate: _eventDate!,
      image: _imageBase64,
      createdAt: widget.evento?.createdAt ?? DateTime.now(),
    );
    if (widget.evento == null) {
      await widget.controller.addEvent(evento);
    } else {
      await widget.controller.updateEvent(evento);
    }
    setState(() => _loading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.evento == null ? 'Novo Evento' : 'Editar Evento')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Título'),
                      validator: (v) => v == null || v.isEmpty ? 'Informe o título' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(labelText: 'Conteúdo'),
                      maxLines: 3,
                      validator: (v) => v == null || v.isEmpty ? 'Informe o conteúdo' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(_eventDate == null
                          ? 'Selecione a data do evento'
                          : 'Data: ${_eventDate!.day.toString().padLeft(2, '0')}/'
                            '${_eventDate!.month.toString().padLeft(2, '0')}/'
                            '${_eventDate!.year}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _eventDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => _eventDate = picked);
                      },
                    ),
                    const SizedBox(height: 16),
                    _imageBase64.isNotEmpty
                        ? _buildImagePreview(_imageBase64)
                        : const SizedBox.shrink(),
                    TextButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Selecionar Imagem'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(widget.evento == null ? 'Criar' : 'Salvar'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePreview(String image) {
    if (image.isEmpty) return const SizedBox.shrink();
    try {
      // Verifica se a string já tem o prefixo data:image/png;base64,
      String imageData = image;
      if (!image.startsWith('data:image/png;base64,')) {
        // Se não tiver o prefixo, adiciona
        imageData = 'data:image/png;base64,$image';
      }

      final uri = Uri.parse(imageData);
      if (uri.data == null) return const SizedBox.shrink();
      final bytes = uri.data!.contentAsBytes();
      return Image.memory(
        bytes,
        height: 120,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }
}
