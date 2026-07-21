import 'package:cloud_firestore/cloud_firestore.dart';

class BusService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addBus(Map<String, dynamic> busData) async {
    await _db.collection('buses').add({
      ...busData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBus(String id, Map<String, dynamic> busData) async {
    await _db.collection('buses').doc(id).update(busData);
  }

  Future<void> deleteBus(String id) async {
    await _db.collection('buses').doc(id).delete();
  }

  Stream<QuerySnapshot> getCompanyBuses(String companyId) {
    return _db.collection('buses')
        .where('companyId', isEqualTo: companyId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
