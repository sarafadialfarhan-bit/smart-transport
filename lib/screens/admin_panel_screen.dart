import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import 'manage_trips_screen.dart';
import 'user_management_screen.dart';
import 'financial_reports_screen.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "admin_panel".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 30),
            Text(
              "admin_management".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            _buildAdminOption(
              context,
              title: "manage_trips".tr(),
              subtitle: "manage_trips_desc".tr(),
              icon: Icons.bus_alert_rounded,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageTripsScreen()),
                );
              },
            ),
            _buildAdminOption(
              context,
              title: "booking_history".tr(),
              subtitle: "booking_history_desc".tr(),
              icon: Icons.list_alt_rounded,
              color: Colors.orange,
              onTap: () {},
            ),
            _buildAdminOption(
              context,
              title: "manage_users".tr(),
              subtitle: "manage_users_desc".tr(),
              icon: Icons.people_alt_rounded,
              color: Colors.teal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserManagementScreen()),
                );
              },
            ),
            _buildAdminOption(
              context,
              title: "financial_reports".tr(),
              subtitle: "financial_reports_desc".tr(),
              icon: Icons.analytics_rounded,
              color: kGreenColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FinancialReportsScreen()),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              "general_settings".tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            _buildAdminOption(
              context,
              title: "system_alerts".tr(),
              subtitle: "system_alerts_desc".tr(),
              icon: Icons.notification_add_rounded,
              color: Colors.purple,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard("total_trips".tr(), "124", Icons.directions_bus, Colors.blue),
        _buildStatCard("today_bookings".tr(), "45", Icons.bookmark_added, Colors.orange),
        _buildStatCard("total_users".tr(), "1,200", Icons.people, Colors.teal),
        _buildStatCard("earnings".tr(), "2.5M", Icons.payments, kGreenColor),
      ],
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

  Widget _buildAdminOption(BuildContext context, {
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
