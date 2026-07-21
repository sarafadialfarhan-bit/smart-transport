import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../constants.dart';
import '../services/booking_service.dart';
import '../components/skeleton.dart';
import 'trip_chat_screen.dart';
import 'bus_tracking_screen.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final bookingService = BookingService();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          title: Text(
            "my_bookings".tr(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kWhiteColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kWhiteColor),
          bottom: TabBar(
            indicatorColor: kWhiteColor,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: [
              Tab(text: "upcoming_trips".tr()),
              Tab(text: "past_trips".tr()),
            ],
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: bookingService.getUserBookings(user!.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                itemCount: 3,
                itemBuilder: (context, index) => const MyTripSkeleton(),
              );
            }

            final bookings = snapshot.data?.docs ?? [];

            final upcoming = bookings.where((b) {
              final data = b.data() as Map<String, dynamic>;
              return data['status'] == 'confirmed' ||
                  data['status'] == 'postponed';
            }).toList();
            final past = bookings.where((b) {
              final data = b.data() as Map<String, dynamic>;
              return data['status'] == 'finished' ||
                  data['status'] == 'cancelled';
            }).toList();

            return TabBarView(
              children: [
                UpcomingTripsList(bookings: upcoming),
                PastTripsList(bookings: past),
              ],
            );
          },
        ),
      ),
    );
  }
}

class UpcomingTripsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> bookings;
  const UpcomingTripsList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        context,
        "no_upcoming_trips".tr(),
        Icons.airplane_ticket_outlined,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index].data() as Map<String, dynamic>;
        final dateTime =
            (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

        return _buildTicketCard(context, {
          "id": bookings[index].id,
          "tripId": data['tripId']?.toString() ?? "",
          "company": data['company']?.toString() ?? "",
          "from": (data['from']?.toString() ?? "").tr(),
          "to": (data['to']?.toString() ?? "").tr(),
          "date": DateFormat('yyyy/MM/dd').format(dateTime),
          "time": DateFormat('hh:mm a').format(dateTime),
          "seat": (data['seatPref']?.toString() ?? "").tr(),
          "price":
              "${(data['totalPrice'] ?? 0).toStringAsFixed(0)} ${"currency".tr()}",
          "status": (data['status']?.toString() ?? "").tr(),
          "busNum": bookings[index].id.substring(0, 6).toUpperCase(),
          "dateTime": dateTime.toIso8601String(),
        }, isUpcoming: true);
      },
    );
  }
}

class PastTripsList extends StatelessWidget {
  final List<QueryDocumentSnapshot> bookings;
  const PastTripsList({super.key, required this.bookings});

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return _buildEmptyState(context, "no_past_trips".tr(), Icons.history);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index].data() as Map<String, dynamic>;
        final dateTime =
            (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

        return _buildTicketCard(context, {
          "company": data['company']?.toString() ?? "",
          "from": (data['from']?.toString() ?? "").tr(),
          "to": (data['to']?.toString() ?? "").tr(),
          "date": DateFormat('yyyy/MM/dd').format(dateTime),
          "time": DateFormat('hh:mm a').format(dateTime),
          "seat": (data['seatPref']?.toString() ?? "").tr(),
          "price":
              "${(data['totalPrice'] ?? 0).toStringAsFixed(0)} ${"currency".tr()}",
          "status": (data['status']?.toString() ?? "").tr(),
          "busNum": bookings[index].id.substring(0, 6).toUpperCase(),
        }, isUpcoming: false);
      },
    );
  }
}

Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: kPrimaryColor.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 70, color: kPrimaryColor.withOpacity(0.2)),
        ),
        const SizedBox(height: 20),
        Text(
          message,
          style: const TextStyle(
            color: kGreyColor,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTicketCard(
  BuildContext context,
  Map<String, String> data, {
  required bool isUpcoming,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 25),
    decoration: BoxDecoration(
      color: kWhiteColor,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: ClipPath(
      clipper: TicketClipper(),
      child: Column(
        children: [
          // رأس التذكرة
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isUpcoming ? kPrimaryColor : Colors.grey.shade400,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.directions_bus,
                      color: kWhiteColor,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      data['company']!,
                      style: const TextStyle(
                        color: kWhiteColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${"ticket_number".tr()}: ${data['busNum']}",
                  style: TextStyle(
                    color: kWhiteColor.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
            child: Column(
              children: [
                Row(
                  children: [
                    _buildRouteNode(
                      data['from']!,
                      "departure_station".tr(),
                      true,
                    ),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: List.generate(
                              15,
                              (index) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  height: 1,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: kBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Icon(
                              Icons.directions_bus_filled,
                              color: isUpcoming ? kPrimaryColor : kGreyColor,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildRouteNode(
                      data['to']!,
                      "arrival_destination".tr(),
                      false,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem(
                      "date".tr(),
                      data['date']!,
                      Icons.calendar_today_outlined,
                    ),
                    _buildDetailItem(
                      "time".tr(),
                      data['time']!,
                      Icons.access_time,
                    ),
                    _buildDetailItem(
                      "seat".tr(),
                      data['seat']!,
                      Icons.event_seat_outlined,
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: MySeparator(color: Colors.grey),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "status".tr(),
                          style: const TextStyle(
                            color: kGreyColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isUpcoming
                                ? kGreenColor.withOpacity(0.1)
                                : kGreyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            data['status']!,
                            style: TextStyle(
                              color: isUpcoming ? kGreenColor : kGreyColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "total_price".tr(),
                          style: const TextStyle(
                            color: kGreyColor,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          data['price']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kSecondaryColor,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (isUpcoming) ...[
                  const SizedBox(height: 25),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('trips')
                        .doc(data['tripId'])
                        .snapshots(),
                    builder: (context, tripSnapshot) {
                      bool isVisible = false;
                      bool isLive = false;
                      double duration = 4.0;
                      if (tripSnapshot.hasData && tripSnapshot.data!.exists) {
                        final tripData =
                            tripSnapshot.data!.data() as Map<String, dynamic>;
                        isLive = tripData['isLive'] ?? false;
                        duration = (tripData['duration'] ?? 4.0).toDouble();

                        final tripDateTime = (tripData['dateTime'] as Timestamp)
                            .toDate();
                        final arrivalDateTime = tripDateTime.add(
                          Duration(minutes: (duration * 60).toInt()),
                        );
                        final now = DateTime.now();

                        // يظهر قبل ساعتين من الرحلة ويختفي بعد 24 ساعة من الوصول
                        final showTime = tripDateTime.subtract(
                          const Duration(hours: 2),
                        );
                        final hideTime = arrivalDateTime.add(
                          const Duration(hours: 24),
                        );

                        isVisible =
                            now.isAfter(showTime) && now.isBefore(hideTime);
                      }

                      return Column(
                        children: [
                          if (isVisible) ...[
                            Row(
                              children: [
                                if (isLive)
                                  Expanded(
                                    child: SizedBox(
                                      height: 50,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  BusTrackingScreen(
                                                    tripId: data['tripId']!,
                                                    from: data['from']!,
                                                    to: data['to']!,
                                                  ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.location_on,
                                          size: 20,
                                        ),
                                        label: Text(
                                          "track_bus".tr(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kGreenColor,
                                          foregroundColor: kWhiteColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (isLive) const SizedBox(width: 10),
                                Expanded(
                                  flex: isLive ? 1 : 2,
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                TripChatScreen(
                                                  tripId: data['tripId']!,
                                                  from: data['from']!,
                                                  to: data['to']!,
                                                  arrivalTime:
                                                      DateTime.parse(
                                                        data['dateTime']!,
                                                      ).add(
                                                        Duration(
                                                          minutes:
                                                              (duration * 60)
                                                                  .toInt(),
                                                        ),
                                                      ),
                                                ),
                                          ),
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.chat_bubble_outline,
                                        size: 20,
                                      ),
                                      label: Text(
                                        "join_chat".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: kSecondaryColor,
                                        foregroundColor: kWhiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      _showBoardingPass(context, data);
                                    },
                                    icon: const Icon(
                                      Icons.qr_code_scanner,
                                      size: 20,
                                    ),
                                    label: Text(
                                      "boarding_ticket".tr(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      foregroundColor: kWhiteColor,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: () => _showCancelDialog(
                                      context,
                                      data['company']!,
                                      data['date']!,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.redAccent,
                                      side: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: Text(
                                      "cancel".tr(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ] else ...[
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showRatingDialog(context, data['company']!),
                      icon: const Icon(Icons.star_border_rounded, size: 22),
                      label: Text(
                        "rate_trip".tr(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kPrimaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    ),
  );
}

void _showBoardingPass(BuildContext context, Map<String, dynamic> data) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            data['company'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 10),
          Text(
            "${data['from']} → ${data['to']}",
            style: const TextStyle(color: kGreyColor),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kBackgroundColor, width: 2),
            ),
            child: QrImageView(
              data: data['id'] ?? '', // Booking ID
              version: QrVersions.auto,
              size: 200.0,
              foregroundColor: kSecondaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "scan_at_boarding".tr(),
            style: const TextStyle(fontSize: 12, color: kGreyColor),
          ),
          const SizedBox(height: 10),
          Text(
            "${"seat".tr()}: ${data['seat']}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("close".tr()),
        ),
      ],
    ),
  );
}

void _showCancelDialog(BuildContext context, String company, String date) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text(
            "cancel_booking".tr(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text("cancel_confirm_msg".tr(args: [company, date])),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("back".tr(), style: const TextStyle(color: kGreyColor)),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("cancel_success".tr()),
                backgroundColor: Colors.orange,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            "confirm_cancel".tr(),
            style: const TextStyle(color: kWhiteColor),
          ),
        ),
      ],
    ),
  );
}

void _showRatingDialog(BuildContext context, String companyName) {
  int selectedStars = 0;
  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        title: Column(
          children: [
            const Icon(Icons.stars_rounded, color: Colors.orange, size: 50),
            const SizedBox(height: 10),
            Text(
              "rating_title".tr(args: [companyName]),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "rating_msg".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: kGreyColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedStars
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.orange,
                    size: 35,
                  ),
                  onPressed: () => setState(() => selectedStars = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "rating_hint".tr(),
                hintStyle: const TextStyle(fontSize: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: selectedStars == 0
                  ? null
                  : () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("rating_thanks".tr()),
                          backgroundColor: kGreenColor,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "send_rating".tr(),
                style: const TextStyle(
                  color: kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRouteNode(String city, String label, bool isStart) {
  return Column(
    crossAxisAlignment: isStart
        ? CrossAxisAlignment.start
        : CrossAxisAlignment.end,
    children: [
      Text(
        city,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: kSecondaryColor,
        ),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: kGreyColor, fontSize: 13)),
    ],
  );
}

Widget _buildDetailItem(String label, String value, IconData icon) {
  return Column(
    children: [
      Icon(icon, size: 18, color: kPrimaryColor.withOpacity(0.7)),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: kGreyColor, fontSize: 12)),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: kSecondaryColor,
        ),
      ),
    ],
  );
}

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);

    double cutOutRadius = 15;
    double cutOutPosition = size.height * 0.68;

    path.addOval(
      Rect.fromCircle(center: Offset(0, cutOutPosition), radius: cutOutRadius),
    );
    path.addOval(
      Rect.fromCircle(
        center: Offset(size.width, cutOutPosition),
        radius: cutOutRadius,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class MySeparator extends StatelessWidget {
  const MySeparator({super.key, this.height = 1, this.color = Colors.black});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color.withOpacity(0.3)),
              ),
            );
          }),
        );
      },
    );
  }
}

class MyTripSkeleton extends StatelessWidget {
  const MyTripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Skeleton(width: 100, height: 20),
                Skeleton(width: 80, height: 15),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
            child: Column(
              children: [
                const Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 60, height: 20),
                        SizedBox(height: 5),
                        Skeleton(width: 80, height: 12),
                      ],
                    ),
                    Expanded(child: SizedBox()),
                    Skeleton(width: 40, height: 40, borderRadius: 20),
                    Expanded(child: SizedBox()),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Skeleton(width: 60, height: 20),
                        SizedBox(height: 5),
                        Skeleton(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Skeleton(width: 70, height: 40),
                    Skeleton(width: 70, height: 40),
                    Skeleton(width: 70, height: 40),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 25),
                  child: MySeparator(color: Colors.grey),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Skeleton(width: 40, height: 12),
                        SizedBox(height: 8),
                        Skeleton(width: 60, height: 20),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Skeleton(width: 40, height: 12),
                        SizedBox(height: 8),
                        Skeleton(width: 80, height: 25),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(child: Skeleton(height: 50, borderRadius: 15)),
                    const SizedBox(width: 10),
                    Expanded(child: Skeleton(height: 50, borderRadius: 15)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
