import 'package:cloud_firestore/cloud_firestore.dart';

class TripService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getTrips() {
    return _db.collection('trips').orderBy('dateTime', descending: true).snapshots();
  }

  Future<void> addTrip(Map<String, dynamic> tripData) async {
    await _db.collection('trips').add({
      ...tripData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTrip(String id, Map<String, dynamic> tripData) async {
    await _db.collection('trips').doc(id).update(tripData);
  }

  Future<void> deleteTrip(String id) async {
    await _db.collection('trips').doc(id).delete();
  }
}
