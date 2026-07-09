import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../services/booking_service.dart';

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
            style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
          ),
          centerTitle: true,
          backgroundColor: kPrimaryColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kWhiteColor),
          bottom: TabBar(
            indicatorColor: kWhiteColor,
            indicatorWeight: 4,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
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
              return const Center(child: CircularProgressIndicator());
            }

            final bookings = snapshot.data?.docs ?? [];
            
            // For simplicity in this demo, we'll treat all as upcoming or separate by status
            final upcoming = bookings.where((b) => (b.data() as Map)['status'] == 'confirmed').toList();
            final past = bookings.where((b) => (b.data() as Map)['status'] == 'finished').toList();

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
      return _buildEmptyState(context, "no_upcoming_trips".tr(), Icons.airplane_ticket_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final data = bookings[index].data() as Map<String, dynamic>;
        final dateTime = (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();
        
        return _buildTicketCard(context, {
          "company": data['company']?.toString() ?? "",
          "from": (data['from']?.toString() ?? "").tr(),
          "to": (data['to']?.toString() ?? "").tr(),
          "date": DateFormat('yyyy/MM/dd').format(dateTime),
          "time": DateFormat('hh:mm a').format(dateTime),
          "seat": (data['seatPref']?.toString() ?? "").tr(),
          "price": "${(data['totalPrice'] ?? 0).toStringAsFixed(0)} ${"currency".tr()}",
          "status": (data['status']?.toString() ?? "").tr(),
          "busNum": bookings[index].id.substring(0, 6).toUpperCase(),
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
        final dateTime = (data['dateTime'] as Timestamp?)?.toDate() ?? DateTime.now();

        return _buildTicketCard(context, {
          "company": data['company']?.toString() ?? "",
          "from": (data['from']?.toString() ?? "").tr(),
          "to": (data['to']?.toString() ?? "").tr(),
          "date": DateFormat('yyyy/MM/dd').format(dateTime),
          "time": DateFormat('hh:mm a').format(dateTime),
          "seat": (data['seatPref']?.toString() ?? "").tr(),
          "price": "${(data['totalPrice'] ?? 0).toStringAsFixed(0)} ${"currency".tr()}",
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
          style: const TextStyle(color: kGreyColor, fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

Widget _buildTicketCard(BuildContext context, Map<String, String> data, {required bool isUpcoming}) {
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
        )
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
                    const Icon(Icons.directions_bus, color: kWhiteColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      data['company']!,
                      style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                Text(
                  "${"ticket_number".tr()}: ${data['busNum']}",
                  style: TextStyle(color: kWhiteColor.withOpacity(0.8), fontSize: 12),
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
                    _buildRouteNode(data['from']!, "departure_station".tr(), true),
                    Expanded(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Row(
                            children: List.generate(
                                15,
                                (index) => Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        height: 1,
                                        color: Colors.grey.shade300,
                                      ),
                                    )),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: kBackgroundColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Icon(Icons.directions_bus_filled, color: isUpcoming ? kPrimaryColor : kGreyColor, size: 18),
                          ),
                        ],
                      ),
                    ),
                    _buildRouteNode(data['to']!, "arrival_destination".tr(), false),
                  ],
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDetailItem("date".tr(), data['date']!, Icons.calendar_today_outlined),
                    _buildDetailItem("time".tr(), data['time']!, Icons.access_time),
                    _buildDetailItem("seat".tr(), data['seat']!, Icons.event_seat_outlined),
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
                        Text("status".tr(), style: const TextStyle(color: kGreyColor, fontSize: 12)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isUpcoming ? kGreenColor.withOpacity(0.1) : kGreyColor.withOpacity(0.1),
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
                        Text("total_price".tr(), style: const TextStyle(color: kGreyColor, fontSize: 12)),
                        const SizedBox(height: 5),
                        Text(
                          data['price']!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: kSecondaryColor, fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),

                if (isUpcoming) ...[
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.qr_code_scanner, size: 20),
                            label: Text("boarding_ticket".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimaryColor,
                              foregroundColor: kWhiteColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => _showCancelDialog(context, data['company']!, data['date']!),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                              side: const BorderSide(color: Colors.redAccent, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            child: Text("cancel".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () => _showRatingDialog(context, data['company']!),
                      icon: const Icon(Icons.star_border_rounded, size: 22),
                      label: Text("rate_trip".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryColor,
                        side: const BorderSide(color: kPrimaryColor),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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

void _showCancelDialog(BuildContext context, String company, String date) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
          const SizedBox(width: 10),
          Text("cancel_booking".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text("confirm_cancel".tr(), style: const TextStyle(color: kWhiteColor)),
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
            Text("rating_title".tr(args: [companyName]),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("rating_msg".tr(),
                textAlign: TextAlign.center, style: const TextStyle(color: kGreyColor)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < selectedStars ? Icons.star_rounded : Icons.star_outline_rounded,
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("send_rating".tr(),
                  style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRouteNode(String city, String label, bool isStart) {
  return Column(
    crossAxisAlignment: isStart ? CrossAxisAlignment.start : CrossAxisAlignment.end,
    children: [
      Text(
        city,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: kSecondaryColor),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(color: kGreyColor, fontSize: 13),
      ),
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
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: kSecondaryColor)),
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

    path.addOval(Rect.fromCircle(center: Offset(0, cutOutPosition), radius: cutOutRadius));
    path.addOval(Rect.fromCircle(center: Offset(size.width, cutOutPosition), radius: cutOutRadius));

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
