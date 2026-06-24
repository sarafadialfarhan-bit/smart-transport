import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {"name": "أحمد محمد", "email": "ahmed@example.com", "role": "مسافر", "status": "نشط"},
      {"name": "سارة علي", "email": "sara@example.com", "role": "مسافر", "status": "نشط"},
      {"name": "محمد حسن", "email": "mohammed@example.com", "role": "سائق", "status": "نشط"},
      {"name": "ليلى محمود", "email": "layla@example.com", "role": "مسافر", "status": "محظور"},
    ];

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "manage_users".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final bool isBlocked = user['status'] == "محظور";

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: kWhiteColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kSecondaryColor.withOpacity(0.1),
                  child: Text(
                    user['name']![0],
                    style: const TextStyle(color: kSecondaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user['email']!, style: const TextStyle(color: kGreyColor, fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isBlocked ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isBlocked ? "blocked".tr() : "active".tr(),
                        style: TextStyle(
                          color: isBlocked ? Colors.red : Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      user['role'] == "سائق" ? "driver".tr() : "passenger".tr(),
                      style: const TextStyle(color: kGreyColor, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: kGreyColor),
                  itemBuilder: (context) => [
                    PopupMenuItem(child: Text("edit".tr())),
                    PopupMenuItem(child: Text(isBlocked ? "unblock".tr() : "block".tr())),
                    PopupMenuItem(child: Text("delete".tr(), style: const TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
