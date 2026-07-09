import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/trips_screen.dart';

class BookingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createBooking({
    required String uid,
    required Trip trip,
    required String passengerName,
    required String mobile,
    required String nationalId,
    required String gender,
    required String seatPref,
  }) async {
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((transaction) async {
      final tripDoc = await transaction.get(_db.collection('trips').doc(trip.id));
      if (!tripDoc.exists) throw "Trip does not exist";

      int currentBooked = tripDoc.data()?['bookedSeats'] ?? 0;
      int totalSeats = tripDoc.data()?['totalSeats'] ?? 1;

      if (currentBooked >= totalSeats) throw "Trip is full";

      transaction.update(_db.collection('trips').doc(trip.id), {
        'bookedSeats': currentBooked + 1,
      });

      transaction.set(bookingRef, {
        'userId': uid,
        'tripId': trip.id,
        'company': trip.company,
        'from': trip.from,
        'to': trip.to,
        'dateTime': Timestamp.fromDate(trip.dateTime),
        'passengerName': passengerName,
        'mobile': mobile,
        'nationalId': nationalId,
        'gender': gender,
        'seatPref': seatPref,
        'totalPrice': trip.price,
        'status': 'confirmed',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot> getUserBookings(String uid) {
    return _db
        .collection('bookings')
        .where('userId', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
