import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import 'trip_chat_screen.dart';

class SupervisorTripsScreen extends StatelessWidget {
  const SupervisorTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("assigned_trips".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .where('supervisorId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final trips = snapshot.data!.docs;
          
          if (trips.isEmpty) {
            return Center(child: Text("no_assigned_trips".tr()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: trips.length,
            itemBuilder: (context, index) {
              final data = trips[index].data() as Map<String, dynamic>;
              final tripId = trips[index].id;
              final dateTime = (data['dateTime'] as Timestamp).toDate();
              final isStarted = data['status'] == 'started';
              
              final now = DateTime.now();
              final showTime = dateTime.subtract(const Duration(hours: 2));
              final hideTime = dateTime.add(Duration(minutes: ((data['duration'] ?? 4.0) * 60).toInt())).add(const Duration(hours: 24));
              
              final isVisible = now.isAfter(showTime) && now.isBefore(hideTime);

              if (!isVisible && !isStarted) return const SizedBox();

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${data['from'].toString().tr()} → ${data['to'].toString().tr()}", 
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isStarted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(data['status'].toString().tr(), 
                              style: TextStyle(color: isStarted ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16, color: kGreyColor),
                          const SizedBox(width: 5),
                          Text(DateFormat('yyyy/MM/dd hh:mm a').format(dateTime), style: const TextStyle(color: kGreyColor)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (isStarted)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TripChatScreen(
                                    tripId: tripId,
                                    from: data['from'],
                                    to: data['to'],
                                    arrivalTime: dateTime.add(Duration(minutes: ((data['duration'] ?? 4.0) * 60).toInt())),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: Text("open_chat".tr()),
                            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: kWhiteColor),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
