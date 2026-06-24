import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummaryCard(),
            const SizedBox(height: 30),
            Text(
              "revenue_details".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            _buildReportItem("daily_revenue".tr(), "450,000", "currency".tr(), Icons.today, Colors.blue),
            _buildReportItem("weekly_revenue".tr(), "3,150,000", "currency".tr(), Icons.calendar_view_week, Colors.orange),
            _buildReportItem("monthly_revenue".tr(), "12,600,000", "currency".tr(), Icons.calendar_month, Colors.purple),
            const SizedBox(height: 30),
            Text(
              "recent_transactions".tr(),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            _buildTransactionTile("حجز رحلة #12345", "75,000", "currency".tr(), "10:30 AM"),
            _buildTransactionTile("شحن محفظة - كاش", "100,000", "currency".tr(), "09:15 AM"),
            _buildTransactionTile("حجز رحلة #12344", "65,000", "currency".tr(), "08:45 AM"),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
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
            "25,450,000 ${"currency".tr()}",
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat("trips".tr(), "342"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildSimpleStat("users".tr(), "1,204"),
            ],
          ),
        ],
      ),
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
          Text("$amount $unit", style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor)),
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
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(time, style: const TextStyle(color: kGreyColor, fontSize: 11)),
              ],
            ),
          ),
          Text("+$amount $unit", style: const TextStyle(color: kGreenColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
