import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    await _db.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'type': type,
      'time': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<QuerySnapshot> getNotifications(String userId) {
    return _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('time', descending: true)
        .snapshots();
  }

  Future<void> markAsRead(String notificationId) async {
    await _db.collection('notifications').doc(notificationId).update({'isRead': true});
  }

  Future<void> notifyTripStatusChange({
    required String tripId,
    required String status,
    required String from,
    required String to,
    DateTime? newDateTime,
  }) async {
    final bookings = await _db.collection('bookings').where('tripId', isEqualTo: tripId).get();

    for (var doc in bookings.docs) {
      final userId = doc.data()['userId'];
      if (userId != null) {
        String title = '';
        String body = '';

        if (status == 'cancelled') {
          title = 'notification_trip_cancelled_title';
          body = 'notification_trip_cancelled_body'.tr(args: [from.tr(), to.tr()]);
        } else if (status == 'postponed') {
          title = 'notification_trip_postponed_title';
          body = 'notification_trip_postponed_body'.tr(args: [from.tr(), to.tr()]);
        }

        await sendNotification(
          userId: userId,
          title: title,
          body: body,
          type: 'alert',
        );
      }
    }
  }
}
