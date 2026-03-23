import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/donor.dart';
import '../models/blood_request.dart';
import '../models/drive.dart';

class AppState extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // -------------------- DATA STREAMS --------------------

  Stream<List<Donor>> get donorsStream => _db
      .collection('donors')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .handleError((error) {
        // 🚨 FIX: Explicit error handling to prevent StreamBuilder hang
        debugPrint('🔴 Firestore Stream Error (Donors): $error');
        throw error;
      })
      .map((snapshot) => snapshot.docs
          .map((doc) => Donor.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList());

  // -------------------- SAFE BLOOD REQUESTS STREAM (FIXED) --------------------
  Stream<List<BloodRequest>> get requestsStream => _db
      .collection('requests')
      .snapshots()
      .handleError((error) {
        // 🚨 FIX: Explicit error handling to prevent StreamBuilder hang
        debugPrint('🔴 Firestore Stream Error (Requests): $error');
        throw error;
      })
      .map((snapshot) {
        final requests = snapshot.docs.map((doc) {
          try {
            final data = doc.data() as Map<String, dynamic>;
            // Ensure timestamp exists
            data['timestamp'] ??= Timestamp.now();
            return BloodRequest.fromFirestore(data);
          } catch (e) {
            debugPrint('Error parsing BloodRequest doc ${doc.id}: $e');
            return null;
          }
        }).whereType<BloodRequest>().toList();

        // Optional: sort descending by timestamp
        requests.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        return requests;
      });

  Stream<List<Drive>> get drivesStream => _db
      .collection('drives')
      .orderBy('date', descending: false)
      .snapshots()
      .handleError((error) {
        // 🚨 FIX: Explicit error handling to prevent StreamBuilder hang
        debugPrint('🔴 Firestore Stream Error (Drives): $error');
        throw error;
      })
      .map((snapshot) => snapshot.docs
          .map((doc) => Drive.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList());

  // -------------------- MAP / MARKER MANAGEMENT --------------------

  final List<Marker> markers = [];
  void Function(BloodRequest request)? _showRequestInfoCallback;

  void registerMarkerTapCallback(void Function(BloodRequest request) callback) {
    _showRequestInfoCallback = callback;
  }

  Future<void> initializeMarkers() async {
    final snapshot = await _db.collection('requests').get();
    final requestList = snapshot.docs.map((doc) {
      try {
        final data = doc.data() as Map<String, dynamic>;
        data['timestamp'] ??= Timestamp.now();
        return BloodRequest.fromFirestore(data);
      } catch (e) {
        debugPrint('Error parsing BloodRequest doc ${doc.id}: $e');
        return null;
      }
    }).whereType<BloodRequest>().toList();

    markers.clear();
    for (var req in requestList) {
      if (req.lat != 0.0 && req.lng != 0.0) {
        markers.add(_createMarkerForRequest(req));
      }
    }
    notifyListeners();
  }

  // -------------------- DATA WRITE OPERATIONS --------------------

  Future<void> addDonor(Donor donor) async {
    await _db.collection('donors').doc(donor.id).set(donor.toFirestore());
  }

  Future<void> addRequest(BloodRequest request) async {
    await _db.collection('requests').doc(request.id).set(request.toFirestore());
  }

  Future<void> addDrive(Drive drive) async {
    await _db.collection('drives').doc(drive.id).set(drive.toFirestore());
  }

  // -------------------- SEARCH / FILTERING --------------------

  Future<List<Donor>> searchDonors({String? bloodGroup, String? city}) async {
    Query query = _db.collection('donors');

    if (bloodGroup != null && bloodGroup.isNotEmpty) {
      query = query.where('bloodGroup', isEqualTo: bloodGroup);
    }

    final snapshot = await query.get();
    List<Donor> results = snapshot.docs
        .map((doc) => Donor.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();

    if (city != null && city.isNotEmpty) {
      results =
          results.where((d) => d.city.toLowerCase().contains(city.toLowerCase())).toList();
    }

    return results;
  }

  // -------------------- MARKER HELPERS --------------------

  Marker _createMarkerForDonor(Donor donor) {
    return Marker(
      width: 40,
      height: 40,
      point: LatLng(donor.lat, donor.lng),
      child: GestureDetector(
        onTap: () => debugPrint('Donor tapped: ${donor.name}'),
        child: const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 36,
        ),
      ),
    );
  }

  Marker _createMarkerForRequest(BloodRequest request) {
    return Marker(
      width: 40,
      height: 40,
      point: LatLng(request.lat, request.lng),
      child: GestureDetector(
        onTap: () => _showRequestInfoCallback?.call(request),
        child: const Icon(
          Icons.location_on,
          color: Colors.red,
          size: 36,
        ),
      ),
    );
  }

  // -------------------- FETCH SINGLE DONOR --------------------

  Future<Donor?> fetchDonorById(String id) async {
    final doc = await _db.collection('donors').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return Donor.fromFirestore(doc.data() as Map<String, dynamic>);
    }
    return null;
  }
}