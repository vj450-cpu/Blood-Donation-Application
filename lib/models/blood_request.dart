import 'package:cloud_firestore/cloud_firestore.dart';

class BloodRequest {
  final String id;
  final String patientName;
  final String bloodGroup;
  final int units;
  final String city;
  final String note;
  final String phone; // Contact number
  final double lat;
  final double lng;
  final DateTime timestamp;

  BloodRequest({
    required this.id,
    required this.patientName,
    required this.bloodGroup,
    required this.units,
    required this.city,
    required this.note,
    required this.phone, // Contact number
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  factory BloodRequest.fromFirestore(Map<String, dynamic> data) {
    return BloodRequest(
      id: data['id'] ?? '',
      patientName: data['patientName'] ?? 'Unknown Patient',
      bloodGroup: data['bloodGroup'] ?? 'O+',
      units: (data['units'] as num?)?.toInt() ?? 1,
      city: data['city'] ?? 'Unknown City',
      note: data['note'] ?? 'No additional notes.',
      phone: data['phone'] ?? 'N/A', // Contact number
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'patientName': patientName,
      'bloodGroup': bloodGroup,
      'units': units,
      'city': city,
      'note': note,
      'phone': phone, // Contact number
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp,
    };
  }
}
