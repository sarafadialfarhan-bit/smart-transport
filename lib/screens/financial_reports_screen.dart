import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../components/skeleton.dart';

class FinancialReportsScreen extends StatelessWidget {
  final String? companyName;
  const FinancialReportsScreen({super.key, this.companyName});

  @override
  Widget build(BuildContext context) {
    Query bookingsQuery = FirebaseFirestore.instance.collection('bookings').orderBy('createdAt', descending: true);
    if (companyName != null) {
      bookingsQuery = bookingsQuery.where('company', isEqualTo: companyName);
    }

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "financial_reports".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: bookingsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const FinancialSkeleton();
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final bookings = snapshot.data?.docs ?? [];
          double totalEarnings = 0;
          double dailyRevenue = 0;
          double weeklyRevenue = 0;
          double monthlyRevenue = 0;

          DateTime now = DateTime.now();
          DateTime today = DateTime(now.year, now.month, now.day);
          DateTime weekAgo = now.subtract(const Duration(days: 7));
          DateTime monthAgo = DateTime(now.year, now.month - 1, now.day);

          for (var doc in bookings) {
            final data = doc.data() as Map<String, dynamic>;
            double price = (data['totalPrice'] ?? 0).toDouble();
            totalEarnings += price;

            Timestamp? createdAt = data['createdAt'] as Timestamp?;
            if (createdAt != null) {
              DateTime date = createdAt.toDate();
              if (date.isAfter(today)) dailyRevenue += price;
              if (date.isAfter(weekAgo)) weeklyRevenue += price;
              if (date.isAfter(monthAgo)) monthlyRevenue += price;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCard(totalEarnings),
                const SizedBox(height: 30),
                Text(
                  "revenue_details".tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
                ),
                const SizedBox(height: 15),
                _buildReportItem("daily_revenue".tr(), dailyRevenue.toStringAsFixed(0), "currency".tr(), Icons.today, Colors.blue),
                _buildReportItem("weekly_revenue".tr(), weeklyRevenue.toStringAsFixed(0), "currency".tr(), Icons.calendar_view_week, Colors.orange),
                _buildReportItem("monthly_revenue".tr(), monthlyRevenue.toStringAsFixed(0), "currency".tr(), Icons.calendar_month, Colors.purple),
                const SizedBox(height: 30),
                Text(
                  "recent_transactions".tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
                ),
                const SizedBox(height: 15),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: bookings.length > 10 ? 10 : bookings.length,
                  itemBuilder: (context, index) {
                    final data = bookings[index].data() as Map<String, dynamic>;
                    String title = "${"booking".tr()} ${data['from']} -> ${data['to']}";
                    String amount = (data['totalPrice'] ?? 0).toString();
                    Timestamp? createdAt = data['createdAt'] as Timestamp?;
                    String time = createdAt != null ? DateFormat('hh:mm a').format(createdAt.toDate()) : "--:--";
                    
                    return _buildTransactionTile(title, amount, "currency".tr(), time);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(double totalEarnings) {
    Query tripsQuery = FirebaseFirestore.instance.collection('trips');
    if (companyName != null) {
      tripsQuery = tripsQuery.where('company', isEqualTo: companyName);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: tripsQuery.snapshots(),
      builder: (context, tripsSnapshot) {
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, usersSnapshot) {
            int totalTrips = tripsSnapshot.hasData ? tripsSnapshot.data!.docs.length : 0;
            int totalUsers = usersSnapshot.hasData ? usersSnapshot.data!.docs.length : 0;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [kSecondaryColor, kSecondaryColor.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(color: kSecondaryColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "total_earnings".tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${NumberFormat('#,###').format(totalEarnings)} ${"currency".tr()}",
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSimpleStat("trips".tr(), totalTrips.toString()),
                      if (companyName == null) ...[
                        Container(width: 1, height: 30, color: Colors.white24),
                        _buildSimpleStat("users".tr(), totalUsers.toString()),
                      ],
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildReportItem(String title, String amount, String unit, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 15),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text("${NumberFormat('#,###').format(double.parse(amount))} $unit", style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(String title, String amount, String unit, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(color: kGreenColor, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(time, style: const TextStyle(color: kGreyColor, fontSize: 11)),
              ],
            ),
          ),
          Text("+${NumberFormat('#,###').format(double.parse(amount))} $unit", style: const TextStyle(color: kGreenColor, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}

class FinancialSkeleton extends StatelessWidget {
  const FinancialSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Skeleton(height: 180, borderRadius: 25),
          const SizedBox(height: 30),
          const Skeleton(width: 150, height: 20),
          const SizedBox(height: 15),
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Skeleton(height: 70, borderRadius: 15),
          )),
          const SizedBox(height: 30),
          const Skeleton(width: 150, height: 20),
          const SizedBox(height: 15),
          ...List.generate(5, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Skeleton(height: 50, borderRadius: 10),
          )),
        ],
      ),
    );
  }
}
