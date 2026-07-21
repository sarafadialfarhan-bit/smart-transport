import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import '../models/trip_model.dart';
import '../widgets/trip_card_widget.dart';
import 'passenger_data_screen.dart';
import 'log_in_screen.dart';
import '../components/skeleton.dart';

class TripsScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final DateTime? date;
  final String seatType;

  const TripsScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    this.date,
    required this.seatType,
  });

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String selectedFilter = 'cheapest';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'popular_routes'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: Column(
        children: [
          _buildSearchSummary(),
          _buildFilterBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (context, index) => const TripSkeleton(),
                  );
                }

                List<Trip> trips = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Trip(
                    id: doc.id,
                    company: data['company'] ?? '',
                    from: data['from'] ?? '',
                    to: data['to'] ?? '',
                    dateTime: (data['dateTime'] as Timestamp).toDate(),
                    price: widget.seatType.toLowerCase() == 'vip' ? (data['priceVip'] ?? 0.0).toDouble() : (data['priceNormal'] ?? 0.0).toDouble(),
                    availableSeats: (data['totalSeats'] ?? 0) - (data['bookedSeats'] ?? 0),
                    busType: widget.seatType,
                    duration: (data['duration'] ?? 4.0).toDouble(),
                  );
                }).toList();

                if (widget.date != null) {
                  trips = trips.where((t) => 
                    t.dateTime.year == widget.date!.year &&
                    t.dateTime.month == widget.date!.month &&
                    t.dateTime.day == widget.date!.day
                  ).toList();
                }

                _applyFilterLogic(trips);

                if (trips.isEmpty) return _buildEmptyState();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    return TripCardWidget(
                      trip: trips[index],
                      onAction: () => _confirmBooking(trips[index]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Query _buildQuery() {
    Query query = FirebaseFirestore.instance.collection('trips').where('status', isEqualTo: 'active');
    if (widget.fromCity.isNotEmpty) {
      query = query.where('from', isEqualTo: widget.fromCity);
    }
    if (widget.toCity.isNotEmpty) {
      query = query.where('to', isEqualTo: widget.toCity);
    }
    return query;
  }

  void _applyFilterLogic(List<Trip> trips) {
    switch (selectedFilter) {
      case 'fastest':
        trips.sort((a, b) => a.duration.compareTo(b.duration));
        break;
      case 'cheapest':
        trips.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'earliest':
        trips.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        break;
      case 'latest':
        trips.sort((a, b) => b.dateTime.compareTo(a.dateTime));
        break;
    }
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  Widget _buildSearchSummary() {
    String routeTitle = widget.fromCity.isNotEmpty && widget.toCity.isNotEmpty
        ? "${widget.fromCity.tr()} ← ${widget.toCity.tr()}"
        : "all_available_trips".tr();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: kPrimaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  routeTitle,
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (widget.date != null) ...[
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                      const SizedBox(width: 5),
                      Text(
                        DateFormat('yyyy/MM/dd').format(widget.date!),
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 15),
                    ],
                    const Icon(Icons.airline_seat_recline_normal, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      widget.seatType.tr(),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.edit, color: kWhiteColor, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: kWhiteColor.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 65,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        children: [
          _buildFilterChip("cheapest", Icons.sell_outlined),
          _buildFilterChip("fastest", Icons.speed),
          _buildFilterChip("earliest", Icons.wb_twilight),
          _buildFilterChip("latest", Icons.nightlight_round),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, IconData icon) {
    bool isSelected = selectedFilter == filterKey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        label: Text(filterKey.tr()),
        avatar: Icon(icon, size: 16, color: isSelected ? kWhiteColor : kPrimaryColor),
        selected: isSelected,
        onSelected: (bool value) {
          if (value) _applyFilter(filterKey);
        },
        backgroundColor: kWhiteColor,
        selectedColor: kPrimaryColor,
        checkmarkColor: kWhiteColor,
        labelStyle: TextStyle(
          color: isSelected ? kWhiteColor : kSecondaryColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: isSelected ? kPrimaryColor : Colors.grey.shade300),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          Text("no_trips_available".tr(), style: const TextStyle(color: kGreyColor, fontSize: 16)),
        ],
      ),
    );
  }

  void _confirmBooking(Trip trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "confirm_booking_details".tr(),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildModalRow("company".tr(), trip.company.tr()),
              _buildModalRow("${"from".tr()} ← ${"to".tr()}", "${trip.from.tr()} ← ${trip.to.tr()}"),
              _buildModalRow("time".tr(), DateFormat('hh:mm a').format(trip.dateTime)),
              _buildModalRow("price".tr(), "${trip.price.toStringAsFixed(0)} ${"currency".tr()}"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (FirebaseAuth.instance.currentUser != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PassengerDataScreen(trip: trip),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("login_required_to_book".tr()),
                          backgroundColor: kSecondaryColor,
                          action: SnackBarAction(
                            label: "login".tr(),
                            textColor: kWhiteColor,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LogInScreen()),
                              );
                            },
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text(
                    "confirm".tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: kGreyColor, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class TripSkeleton extends StatelessWidget {
  const TripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Skeleton(width: 44, height: 44, borderRadius: 12),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Skeleton(width: 100, height: 18),
                      SizedBox(height: 8),
                      Skeleton(width: 140, height: 12),
                    ],
                  ),
                ],
              ),
              const Skeleton(width: 70, height: 22),
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
                  const Skeleton(width: 16, height: 16, borderRadius: 8),
                  Container(width: 1.5, height: 40, color: Colors.grey.shade100),
                  const Skeleton(width: 16, height: 16, borderRadius: 8),
                ],
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Skeleton(width: 60, height: 15),
                        Skeleton(width: 80, height: 15),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Skeleton(width: 100, height: 12),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Skeleton(width: 90, height: 15),
                        Skeleton(width: 80, height: 15),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 100, height: 20),
              Skeleton(width: 100, height: 40, borderRadius: 10),
            ],
          ),
        ],
      ),
    );
  }
}
