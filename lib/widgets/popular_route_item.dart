import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class PopularRouteItem extends StatelessWidget {
  final String from;
  final String to;
  final VoidCallback? onTap;

  const PopularRouteItem({
    super.key,
    required this.from,
    required this.to,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        color: kWhiteColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.directions_bus, color: kPrimaryColor),
          ),
          title: Text("$from ← $to", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("instant_booking_available".tr()),
        ),
      ),
    );
  }
}
