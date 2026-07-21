import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> getMessages(String tripId) {
    return _db
        .collection('trips')
        .doc(tripId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> sendMessage({
    required String tripId,
    required String senderId,
    required String senderName,
    required String text,
    String type = 'text',
    Map<String, double>? location,
  }) async {
    await _db.collection('trips').doc(tripId).collection('messages').add({
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type,
      'location': location,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> triggerEmergency({
    required String tripId,
    required String senderId,
    required String senderName,
    required Map<String, double> location,
  }) async {
    await sendMessage(
      tripId: tripId,
      senderId: senderId,
      senderName: senderName,
      text: 'EMERGENCY_ALERT',
      type: 'emergency',
      location: location,
    );
    
    // Optional: Update trip status or notify admin
    await _db.collection('trips').doc(tripId).update({
      'hasEmergency': true,
      'lastEmergencyLocation': location,
    });
  }
}
