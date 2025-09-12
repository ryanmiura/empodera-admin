import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventController {
  final FirebaseFirestore firestore;
  final String collectionName;

  EventController({
    required this.firestore,
    this.collectionName = 'events',
  });

  CollectionReference get _eventsCollection => firestore.collection(collectionName);

  Future<List<Evento>> fetchEvents() async {
    final snapshot = await _eventsCollection.orderBy('eventDate', descending: true).get();
    return snapshot.docs
        .map((doc) => Evento.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> addEvent(Evento evento) async {
    await _eventsCollection.add(evento.toMap());
  }

  Future<void> updateEvent(Evento evento) async {
    await _eventsCollection.doc(evento.id).update(evento.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _eventsCollection.doc(id).delete();
  }
}
