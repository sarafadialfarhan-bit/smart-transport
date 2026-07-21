import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
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
    required String seatNumber,
  }) async {
    final bookingRef = _db.collection('bookings').doc();

    await _db.runTransaction((transaction) async {
      final tripRef = _db.collection('trips').doc(trip.id);
      final tripDoc = await transaction.get(tripRef);
      if (!tripDoc.exists) throw "Trip does not exist";

      Map<String, dynamic> tripData = tripDoc.data() as Map<String, dynamic>;
      String status = tripData['status'] ?? 'active';
      if (status != 'active') throw "trip_no_longer_available".tr();

      Map<String, dynamic> seats = Map<String, dynamic>.from(tripData['seats'] ?? {});
      if (seats[seatNumber] != 'available') throw "seat_already_booked".tr();

      int currentBooked = tripData['bookedSeats'] ?? 0;
      
      // Update seats map and booked count
      seats[seatNumber] = "occupied";
      transaction.update(tripRef, {
        'bookedSeats': currentBooked + 1,
        'seats': seats,
      });

      transaction.set(bookingRef, {
        'id': bookingRef.id,
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
        'seat': seatNumber,
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

  Future<void> markAsBoarded(String bookingId) async {
    await _db.runTransaction((transaction) async {
      final bookingRef = _db.collection('bookings').doc(bookingId);
      final bookingDoc = await transaction.get(bookingRef);
      if (!bookingDoc.exists) return;

      final data = bookingDoc.data() as Map<String, dynamic>;
      final String tripId = data['tripId'];
      final String seatNum = data['seat'];

      // Update booking status
      transaction.update(bookingRef, {
        'status': 'boarded',
        'boardedAt': FieldValue.serverTimestamp(),
      });

      // Update trip seat status
      final tripRef = _db.collection('trips').doc(tripId);
      final tripDoc = await transaction.get(tripRef);
      if (tripDoc.exists) {
        Map<String, dynamic> seats = Map<String, dynamic>.from(tripDoc.data()?['seats'] ?? {});
        seats[seatNum] = "boarded";
        transaction.update(tripRef, {'seats': seats});
      }
    });
  }
}
