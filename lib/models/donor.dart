// lib/models/donor.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // Required for FieldValue

class Donor {
  final String id;
  final String name;
  final String bloodGroup;
  final String city;
  final String phone;
  final double lat;
  final double lng;
  final String photoUrl;
  // Note: The avatarText is a computed getter, not a stored field, 
  // which is efficient as it doesn't need to be saved to the database.

  Donor({
    required this.id,
    required this.name,
    required this.bloodGroup,
    required this.city,
    required this.phone,
    required this.lat,
    required this.lng,
    this.photoUrl = '',
  });

  // Computed getter for avatar initials (Kept as is, as it's computed)
  String get avatarText {
    final parts = name.trim().split(' ');
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    if (name.isNotEmpty) return name[0].toUpperCase();
    return '?';
  }

  // 1. Factory Constructor: To create a Donor object from a Firestore snapshot
  factory Donor.fromFirestore(Map<String, dynamic> doc) {
    // Note: Casts are necessary to ensure type safety when reading from Firestore
    return Donor(
      id: doc['id'] as String,
      name: doc['name'] as String,
      bloodGroup: doc['bloodGroup'] as String,
      city: doc['city'] as String,
      phone: doc['phone'] as String,
      // Firestore stores numbers as num, so we cast to double
      lat: (doc['lat'] as num).toDouble(), 
      lng: (doc['lng'] as num).toDouble(),
      photoUrl: (doc['photoUrl'] as String?) ?? '',
    );
  }

  // 2. Method: To convert the Donor object to a Map for uploading to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'bloodGroup': bloodGroup,
      'city': city,
      'phone': phone,
      'lat': lat,
      'lng': lng,
      'photoUrl': photoUrl,
      // Adding a timestamp is useful for ordering and recent activity feeds
      'timestamp': FieldValue.serverTimestamp(), 
    };
  }
}