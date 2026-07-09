import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final NotificationService notificationService = NotificationService();

    if (user == null) {
      return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text("notifications".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor)),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
        ),
        body: Center(child: Text("login_required".tr())),
      );
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "notifications".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: notificationService.getNotifications(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;
              return _buildNotificationItem(doc.id, data, notificationService);
            },
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(String id, Map<String, dynamic> item, NotificationService service) {
    IconData icon;
    Color iconColor;
    bool isRead = item['isRead'] ?? false;

    switch (item['type']) {
      case 'alert':
        icon = Icons.notifications_active;
        iconColor = Colors.orange;
        break;
      case 'wallet':
        icon = Icons.account_balance_wallet;
        iconColor = kGreenColor;
        break;
      default:
        icon = Icons.local_offer;
        iconColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        if (!isRead) service.markAsRead(id);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? kWhiteColor : kWhiteColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: isRead ? null : Border.all(color: kPrimaryColor.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['title']!.toString().tr(),
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatTime(item['time']),
                        style: const TextStyle(color: kGreyColor, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item['body']!.toString(),
                    style: TextStyle(
                      color: isRead ? kGreyColor : Colors.black87,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic time) {
    if (time == null) return "";
    DateTime dt = (time as Timestamp).toDate();
    return DateFormat('hh:mm a').format(dt);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("no_notifications".tr(), style: const TextStyle(color: kGreyColor, fontSize: 16)),
        ],
      ),
    );
  }
}
