import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "wallet".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          double balance = 0.0;
          if (snapshot.hasData && snapshot.data!.exists) {
            balance = (snapshot.data!.data() as Map<String, dynamic>)['walletBalance']?.toDouble() ?? 0.0;
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // بطاقة الرصيد العلوي
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "available_balance".tr(),
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${NumberFormat("#,###").format(balance)} ${"currency".tr()}",
                        style: const TextStyle(
                          color: kWhiteColor,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildHeaderButton(Icons.add_circle_outline, "top_up".tr()),
                          const SizedBox(width: 20),
                          _buildHeaderButton(Icons.history, "history".tr()),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "last_transactions".tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
                      ),
                      const SizedBox(height: 15),
                      // Mock transactions for now or fetch from Firestore
                      _buildTransactionItem(
                        "booking_trip_with".tr(args: ["company_aman".tr()]),
                        "two_hours_ago".tr(),
                        "- 45,000 ${"currency".tr()}",
                        false,
                      ),
                      _buildTransactionItem(
                        "top_up_cash".tr(),
                        "yesterday".tr(),
                        "+ 100,000 ${"currency".tr()}",
                        true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: kWhiteColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: kWhiteColor, size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String date, String amount, bool isCredit) {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCredit ? kGreenColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? kGreenColor : Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(date, style: const TextStyle(color: kGreyColor, fontSize: 12)),
                ],
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCredit ? kGreenColor : Colors.red,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
