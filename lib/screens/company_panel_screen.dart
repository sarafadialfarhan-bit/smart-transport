import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_transport/screens/user_management_screen.dart';
import '../constants.dart';
import 'manage_trips_screen.dart';
import 'financial_reports_screen.dart';

class CompanyPanelScreen extends StatefulWidget {
  const CompanyPanelScreen({super.key});

  @override
  State<CompanyPanelScreen> createState() => _CompanyPanelScreenState();
}

class _CompanyPanelScreenState extends State<CompanyPanelScreen> {
  String? companyNameAr;
  String? companyNameEn;

  @override
  void initState() {
    super.initState();
    _fetchCompanyData();
  }

  void _fetchCompanyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (mounted) {
        setState(() {
          companyNameAr = doc.data()?['companyNameAr'];
          companyNameEn = doc.data()?['companyNameEn'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          context.locale.languageCode == 'ar' 
              ? (companyNameAr ?? "loading".tr()) 
              : (companyNameEn ?? "loading".tr()),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRealtimeStats(),
            const SizedBox(height: 30),
            Text(
              "company_management".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            _buildOption(
              context,
              title: "manage_my_trips".tr(),
              subtitle: "manage_trips_desc".tr(),
              icon: Icons.bus_alert_rounded,
              color: Colors.blue,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageTripsScreen(
                    companyName: companyNameEn,
                    companyId: user?.uid,
                  )),
                );
              },
            ),
            _buildOption(
              context,
              title: "manage_supervisors".tr(),
              subtitle: "manage_supervisors_desc".tr(),
              icon: Icons.assignment_ind_rounded,
              color: Colors.deepPurple,
              onTap: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserManagementScreen(companyId: user.uid)),
                  );
                }
              },
            ),
            _buildOption(
              context,
              title: "my_profits".tr(),
              subtitle: "financial_reports_desc".tr(),
              icon: Icons.analytics_rounded,
              color: kGreenColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FinancialReportsScreen(companyName: companyNameEn)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRealtimeStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('bookings')
          .where('company', isEqualTo: companyNameEn)
          .snapshots(),
      builder: (context, snapshot) {
        int totalBookings = snapshot.hasData ? snapshot.data!.docs.length : 0;
        double totalEarnings = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            totalEarnings += (doc.data() as Map<String, dynamic>)['totalPrice'] ?? 0.0;
          }
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard("total_bookings".tr(), totalBookings.toString(), Icons.bookmark_added, Colors.orange),
            _buildStatCard("my_earnings".tr(), "${(totalEarnings / 1000).toStringAsFixed(0)}K", Icons.payments, kGreenColor),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(color: kGreyColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: kWhiteColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: kGreyColor, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: kGreyColor),
            ],
          ),
        ),
      ),
    );
  }
}
