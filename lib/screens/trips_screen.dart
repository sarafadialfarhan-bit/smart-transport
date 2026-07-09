import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import '../constants.dart';
import 'passenger_data_screen.dart';

class Trip {
  final String company;
  final String from;
  final String to;
  final String time;
  final String price;
  final int availableSeats;
  final String busType;
  final String duration;

  Trip({
    required this.company,
    required this.from,
    required this.to,
    required this.time,
    required this.price,
    required this.availableSeats,
    required this.busType,
    required this.duration,
  });
}

class TripsScreen extends StatefulWidget {
  final String fromCity;
  final String toCity;
  final DateTime date;
  final String seatType;

  const TripsScreen({
    super.key,
    required this.fromCity,
    required this.toCity,
    required this.date,
    required this.seatType,
  });

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  late List<Trip> filteredTrips;
  String selectedFilter = 'cheapest';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    List<Trip> allTrips = [
      Trip(
        company: "company_aman",
        from: widget.fromCity,
        to: widget.toCity,
        time: "08:00 AM",
        price: "45,000",
        availableSeats: 5,
        busType: "VIP",
        duration: "4.0",
      ),
      Trip(
        company: "company_kadmous",
        from: widget.fromCity,
        to: widget.toCity,
        time: "10:30 AM",
        price: "48,000",
        availableSeats: 12,
        busType: "normal",
        duration: "4.5",
      ),
      Trip(
        company: "company_ittihad",
        from: widget.fromCity,
        to: widget.toCity,
        time: "01:00 PM",
        price: "42,000",
        availableSeats: 8,
        busType: "normal",
        duration: "5.0",
      ),
      Trip(
        company: "company_aman",
        from: widget.fromCity,
        to: widget.toCity,
        time: "03:30 PM",
        price: "55,000",
        availableSeats: 3,
        busType: "VIP",
        duration: "3.5",
      ),
      Trip(
        company: "company_kadmous",
        from: widget.fromCity,
        to: widget.toCity,
        time: "09:00 PM",
        price: "45,000",
        availableSeats: 0,
        busType: "normal",
        duration: "4.2",
      ),
    ];

    // Filter by bus type if not "all" (or just show all if search screen logic passes something else)
    if (widget.seatType != "all") {
      filteredTrips = allTrips.where((trip) => 
        trip.busType.toLowerCase() == widget.seatType.toLowerCase()
      ).toList();
    } else {
      filteredTrips = List.from(allTrips);
    }

    // Fallback if filtered list is empty
    if (filteredTrips.isEmpty) {
      filteredTrips = List.from(allTrips);
    }

    _applyFilter('cheapest');
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      switch (filter) {
        case 'fastest':
          filteredTrips.sort((a, b) => double.parse(a.duration).compareTo(double.parse(b.duration)));
          break;
        case 'cheapest':
          filteredTrips.sort((a, b) => 
            double.parse(a.price.replaceAll(',', '')).compareTo(double.parse(b.price.replaceAll(',', ''))));
          break;
        case 'earliest':
          filteredTrips.sort((a, b) => _parseTime(a.time).compareTo(_parseTime(b.time)));
          break;
        case 'latest':
          filteredTrips.sort((a, b) => _parseTime(b.time).compareTo(_parseTime(a.time)));
          break;
      }
    });
  }

  DateTime _parseTime(String timeStr) {
    try {
      return DateFormat("hh:mm a").parse(timeStr);
    } catch (e) {
      return DateTime.now();
    }
  }

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
            child: filteredTrips.isEmpty 
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 5, 16, 16),
                  itemCount: filteredTrips.length,
                  itemBuilder: (context, index) {
                    return _buildTripCard(filteredTrips[index]);
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSummary() {
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
                  "${widget.fromCity.tr()} ← ${widget.toCity.tr()}",
                  style: const TextStyle(
                    color: kWhiteColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('yyyy/MM/dd').format(widget.date),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(width: 15),
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

  Widget _buildTripCard(Trip trip) {
    bool isFull = trip.availableSeats == 0;

    return Container(
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
                              trip.busType == "VIP" 
                                  ? "VIP - ${"very_comfortable".tr()}" 
                                  : "${"normal".tr()} - ${"air_conditioned".tr()}",
                              style: const TextStyle(color: kGreyColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      "${trip.price} ${"currency".tr()}",
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
                                _formatTime(trip.time),
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
                  onPressed: isFull ? null : () => _confirmBooking(trip),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: kWhiteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text("confirm".tr()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time) {
    if (time.contains("AM")) {
      return time.replaceFirst("AM", "am".tr());
    } else if (time.contains("PM")) {
      return time.replaceFirst("PM", "pm".tr());
    }
    return time;
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
              _buildModalRow("time".tr(), _formatTime(trip.time)),
              _buildModalRow("price".tr(), "${trip.price} ${"currency".tr()}"),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PassengerDataScreen(trip: trip),
                      ),
                    );
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
