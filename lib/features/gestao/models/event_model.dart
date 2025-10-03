import 'package:cloud_firestore/cloud_firestore.dart';

class Evento {
  final String id;
  final String title;
  final String content;
  final DateTime eventDate;
  final String image; // base64
  final String status;
  final DateTime createdAt;

  Evento({
    required this.id,
    required this.title,
    required this.content,
    required this.eventDate,
    required this.image,
    this.status = 'approved',
    required this.createdAt,
  });

  factory Evento.fromMap(String id, Map<String, dynamic> map) {
    return Evento(
      id: id,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      eventDate: (map['eventDate'] is Timestamp)
          ? (map['eventDate'] as Timestamp).toDate()
          : DateTime.tryParse(map['eventDate'] ?? '') ?? DateTime.now(),
      image: map['image'] ?? '',
      status: map['status'] ?? '',
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'eventDate': eventDate,
      'image': image,
      'status': status,
      'createdAt': createdAt,
    };
  }
}
