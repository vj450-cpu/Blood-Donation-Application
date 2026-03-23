// lib/models/drive.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Drive {
  final String id;
  final String title;
  final String city;
  final DateTime date;
  final String image;

  Drive({
    required this.id,
    required this.title,
    required this.city,
    required this.date,
    required this.image,
  });

  /// ✅ Factory: Create Drive from Firestore document data
  factory Drive.fromFirestore(Map<String, dynamic> data) {
    return Drive(
      id: data['id']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      city: data['city']?.toString() ?? '',
      date: (data['date'] is Timestamp)
          ? (data['date'] as Timestamp).toDate()
          : DateTime.tryParse(data['date']?.toString() ?? '') ?? DateTime.now(),
      image: data['image']?.toString() ?? '',
    );
  }

  /// ✅ Convert Drive object to a Firestore-compatible Map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'city': city,
      'date': Timestamp.fromDate(date),
      'image': image,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }
}
