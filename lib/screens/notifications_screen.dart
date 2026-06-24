import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notifications = [
      {
        "title": "notification_remind_trip_title",
        "body": "notification_remind_trip_body",
        "time": "notification_time_hour_ago",
        "type": "alert"
      },
      {
        "title": "notification_wallet_topup_title",
        "body": "notification_wallet_topup_body",
        "time": "notification_time_yesterday",
        "type": "wallet"
      },
      {
        "title": "notification_promo_title",
        "body": "notification_promo_body",
        "time": "notification_time_two_days_ago",
        "type": "promo"
      },
    ];

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
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationItem(notifications[index]);
              },
            ),
    );
  }

  Widget _buildNotificationItem(Map<String, String> item) {
    IconData icon;
    Color iconColor;

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

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
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
                      item['title']!.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      item['time']!.tr(),
                      style: const TextStyle(color: kGreyColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['body']!.tr(),
                  style: const TextStyle(color: kGreyColor, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
