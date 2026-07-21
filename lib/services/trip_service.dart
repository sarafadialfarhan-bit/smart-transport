import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTrips() {
    return _db.collection('trips').orderBy('dateTime', descending: true).snapshots();
  }

  Future<void> addTrip(Map<String, dynamic> tripData) async {
    await _db.collection('trips').add({
      ...tripData,
      'status': 'active', // active, started, completed, cancelled, postponed
      'supervisorId': tripData['supervisorId'] ?? '',
      'supervisorName': tripData['supervisorName'] ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTrip(String id, Map<String, dynamic> tripData) async {
    await _db.collection('trips').doc(id).update(tripData);
  }

  Future<void> startTrip(String id) async {
    await _db.collection('trips').doc(id).update({
      'status': 'started',
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTrip(String id) async {
    await _db.collection('trips').doc(id).delete();
  }

  Stream<QuerySnapshot> getSupervisors(String? companyId) {
    var query = _db.collection('users').where('role', isEqualTo: 'supervisor');
    if (companyId != null) {
      query = query.where('companyId', isEqualTo: companyId);
    }
    return query.snapshots();
  }
}
