import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class ManageTripsScreen extends StatefulWidget {
  const ManageTripsScreen({super.key});

  @override
  State<ManageTripsScreen> createState() => _ManageTripsScreenState();
}

class _ManageTripsScreenState extends State<ManageTripsScreen> {
  // بيانات تجريبية للرحلات
  List<Map<String, dynamic>> trips = [
    {
      "id": "1",
      "company": "شركة الأمان",
      "from": "حلب",
      "to": "دمشق",
      "date": "2024/05/20",
      "time": "08:00 AM",
      "price": "45,000",
      "totalSeats": 40,
      "bookedSeats": 12,
    },
    {
      "id": "2",
      "company": "شركة القدموس",
      "from": "دمشق",
      "to": "اللاذقية",
      "date": "2024/05/21",
      "time": "10:30 AM",
      "price": "35,000",
      "totalSeats": 30,
      "bookedSeats": 30,
    },
  ];

  void _deleteTrip(String id) {
    setState(() {
      trips.removeWhere((trip) => trip['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("trip_saved".tr())), // Reusing trip_saved or we should add trip_deleted
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "manage_trips".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kSecondaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTripDialog(),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: kWhiteColor),
        label: Text("add_trip".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildHeaderStats(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: trips.length,
              itemBuilder: (context, index) {
                return _buildTripAdminCard(trips[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: kSecondaryColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("total_trips".tr(), trips.length.toString()),
          _buildStatItem("full_trips".tr(), trips.where((t) => t['bookedSeats'] == t['totalSeats']).length.toString()),
          _buildStatItem("active_now".tr(), "5"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: kWhiteColor, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: kWhiteColor.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }

  Widget _buildTripAdminCard(Map<String, dynamic> trip) {
    bool isFull = trip['bookedSeats'] == trip['totalSeats'];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.business, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(trip['company'], style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text("edit".tr())),
                  PopupMenuItem(value: 'delete', child: Text("delete".tr(), style: const TextStyle(color: Colors.red))),
                ],
                onSelected: (val) {
                  if (val == 'delete') _deleteTrip(trip['id']);
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteInfo(trip['from'], trip['to']),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${trip['price']} ${"currency".tr()}", style: const TextStyle(fontWeight: FontWeight.bold, color: kGreenColor)),
                  Text("${trip['date']} | ${trip['time']}", style: const TextStyle(fontSize: 12, color: kGreyColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: trip['bookedSeats'] / trip['totalSeats'],
                  backgroundColor: Colors.grey.shade200,
                  color: isFull ? Colors.red : kPrimaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "${trip['bookedSeats']}/${trip['totalSeats']} ${"seat_count".tr()}",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isFull ? Colors.red : kGreyColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInfo(String from, String to) {
    return Row(
      children: [
        Text(from, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 16, color: kGreyColor),
        ),
        Text(to, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  void _showAddTripDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 30,
          left: 20,
          right: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("add_new_trip".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor)),
              const SizedBox(height: 20),
              _buildTextField("company_name".tr(), Icons.business),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField("from".tr(), Icons.location_on_outlined)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("to".tr(), Icons.location_on)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(child: _buildTextField("date".tr(), Icons.calendar_today)),
                  const SizedBox(width: 15),
                  Expanded(child: _buildTextField("time".tr(), Icons.access_time)),
                ],
              ),
              const SizedBox(height: 15),
              _buildTextField("price".tr(), Icons.payments_outlined, keyboardType: TextInputType.number),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("save_trip".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {TextInputType? keyboardType}) {
    return TextField(
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
