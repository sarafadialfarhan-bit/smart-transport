import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/trip_model.dart';

class TripCardWidget extends StatelessWidget {
  final Trip trip;
  final VoidCallback onAction;
  final VoidCallback? onCardTap;
  final String? actionLabel;
  final bool isFull;
  final bool showPrice;

  TripCardWidget({
    super.key,
    required this.trip,
    required this.onAction,
    this.onCardTap,
    this.actionLabel,
    this.showPrice = true,
  }) : isFull = trip.availableSeats == 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCardTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: kWhiteColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.directions_bus, color: kPrimaryColor),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                trip.company.tr(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                              Text(
                                trip.busType.toLowerCase() == "vip" 
                                    ? "VIP - ${"very_comfortable".tr()}" 
                                    : "${"normal".tr()} - ${"air_conditioned".tr()}",
                                style: const TextStyle(color: kGreyColor, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (showPrice)
                        Text(
                          "${trip.price.toStringAsFixed(0)} ${"currency".tr()}",
                          style: const TextStyle(
                            color: kGreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    child: Divider(thickness: 1, height: 1),
                  ),
                  Row(
                    children: [
                      Column(
                        children: [
                          const Icon(Icons.radio_button_checked, size: 16, color: kPrimaryColor),
                          Container(width: 1.5, height: 40, color: Colors.grey.shade300),
                          const Icon(Icons.location_on, size: 18, color: Colors.redAccent),
                        ],
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
                                  DateFormat('hh:mm a').format(trip.dateTime),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                                Text(
                                  trip.from.tr(),
                                  style: const TextStyle(color: kSecondaryColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "trip_duration".tr(args: ["${trip.duration} ${"hours".tr()}"]),
                              style: const TextStyle(color: kGreyColor, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "approx_arrival".tr(),
                                  style: const TextStyle(fontWeight: FontWeight.w500, color: kGreyColor, fontSize: 14),
                                ),
                                Text(
                                  trip.to.tr(),
                                  style: const TextStyle(color: kSecondaryColor, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isFull ? Colors.grey.shade50 : kPrimaryColor.withOpacity(0.03),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isFull ? Icons.block : Icons.event_seat,
                        size: 18,
                        color: isFull ? Colors.red : kGreenColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isFull ? "full".tr() : "${"seats".tr()}: ${trip.availableSeats}",
                        style: TextStyle(
                          color: isFull ? Colors.red : kGreenColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: isFull ? null : onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: kWhiteColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    child: Text(actionLabel ?? "confirm".tr()),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
