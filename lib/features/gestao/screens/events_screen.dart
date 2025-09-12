import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'event_form_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({Key? key}) : super(key: key);

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final EventController _controller;
  List<Evento> _events = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = EventController(
      firestore: FirebaseFirestore.instance,
    );
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _loading = true);
    _events = await _controller.fetchEvents();
    setState(() => _loading = false);
  }

  void _openForm({Evento? evento}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(
          controller: _controller,
          evento: evento,
        ),
      ),
    );
    if (result == true) _fetchEvents();
  }

  void _deleteEvent(String id) async {
    await _controller.deleteEvent(id);
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final evento = _events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: _buildEventImage(evento.image),
                    title: Text(evento.title),
                    subtitle: Text(
                      'Data:  \t${evento.eventDate.day.toString().padLeft(2, '0')}/'
                      '${evento.eventDate.month.toString().padLeft(2, '0')}/'
                      '${evento.eventDate.year}',
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _openForm(evento: evento);
                        } else if (value == 'delete') {
                          _deleteEvent(evento.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Editar')),
                        const PopupMenuItem(value: 'delete', child: Text('Excluir')),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEventImage(String image) {
    if (image.isEmpty) return const Icon(Icons.event);
    try {
      // Verifica se a string já tem o prefixo data:image/png;base64,
      String imageData = image;
      if (!image.startsWith('data:image/png;base64,')) {
        // Se não tiver o prefixo, adiciona
        imageData = 'data:image/png;base64,$image';
      }

      final uri = Uri.parse(imageData);
      if (uri.data == null) return const Icon(Icons.event);
      final bytes = uri.data!.contentAsBytes();
      return Image.memory(
        bytes,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
      );
    } catch (e) {
      return const Icon(Icons.event);
    }
  }
}
