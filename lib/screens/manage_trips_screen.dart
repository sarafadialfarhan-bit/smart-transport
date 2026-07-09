import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../services/trip_service.dart';

class ManageTripsScreen extends StatefulWidget {
  final String? companyName;
  const ManageTripsScreen({super.key, this.companyName});

  @override
  State<ManageTripsScreen> createState() => _ManageTripsScreenState();
}

class _ManageTripsScreenState extends State<ManageTripsScreen> {
  final TripService _tripService = TripService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceNormalController = TextEditingController();
  final TextEditingController _priceVipController = TextEditingController();
  final TextEditingController _totalSeatsController = TextEditingController();

  String? _fromCity;
  String? _toCity;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    if (widget.companyName != null) {
      _companyController.text = widget.companyName!;
    }
  }

  void _deleteTrip(String id) async {
    await _tripService.deleteTrip(id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("trip_deleted".tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.companyName ?? "manage_trips".tr(),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: widget.companyName == null 
          ? _tripService.getTrips() 
          : FirebaseFirestore.instance.collection('trips').where('company', isEqualTo: widget.companyName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trips = snapshot.data!.docs;

          return Column(
            children: [
              _buildHeaderStats(trips),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index].data() as Map<String, dynamic>;
                    final tripId = trips[index].id;
                    return _buildTripAdminCard(tripId, trip);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderStats(List<QueryDocumentSnapshot> trips) {
    int total = trips.length;
    int full = trips.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return (data['bookedSeats'] ?? 0) >= (data['totalSeats'] ?? 1);
    }).length;

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
          _buildStatItem("total_trips".tr(), total.toString()),
          _buildStatItem("full_trips".tr(), full.toString()),
          _buildStatItem("active_now".tr(), total.toString()),
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

  Widget _buildTripAdminCard(String id, Map<String, dynamic> trip) {
    int booked = trip['bookedSeats'] ?? 0;
    int total = trip['totalSeats'] ?? 1;
    bool isFull = booked >= total;

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
                  Text(trip['company'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text("edit".tr())),
                  PopupMenuItem(value: 'delete', child: Text("delete".tr(), style: const TextStyle(color: Colors.red))),
                ],
                onSelected: (val) {
                  if (val == 'delete') _deleteTrip(id);
                },
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRouteInfo(trip['from'] ?? '', trip['to'] ?? ''),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${trip['priceNormal']} ${"currency".tr()}", style: const TextStyle(fontWeight: FontWeight.bold, color: kGreenColor)),
                  Text(
                    "${DateFormat('yyyy/MM/dd').format((trip['dateTime'] as Timestamp).toDate())} | ${DateFormat('hh:mm a').format((trip['dateTime'] as Timestamp).toDate())}",
                    style: const TextStyle(fontSize: 12, color: kGreyColor),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: booked / total,
                  backgroundColor: Colors.grey.shade200,
                  color: isFull ? Colors.red : kPrimaryColor,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "$booked/$total ${"seat_count".tr()}",
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
        Text(from.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.arrow_forward, size: 16, color: kGreyColor),
        ),
        Text(to.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  void _showAddTripDialog() {
    if (widget.companyName == null) {
      _companyController.clear();
    } else {
      _companyController.text = widget.companyName!;
    }
    _priceNormalController.clear();
    _priceVipController.clear();
    _totalSeatsController.clear();
    _fromCity = null;
    _toCity = null;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 30,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("add_new_trip".tr(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor)),
                  const SizedBox(height: 20),
                  _buildTextField(
                    "company_name".tr(), 
                    Icons.business, 
                    controller: _companyController, 
                    readOnly: widget.companyName != null
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCityDropdown("from".tr(), _fromCity, (val) => setModalState(() => _fromCity = val)),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildCityDropdown("to".tr(), _toCity, (val) => setModalState(() => _toCity = val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) setModalState(() => _selectedDate = picked);
                          },
                          child: _buildFakeField(DateFormat('yyyy/MM/dd').format(_selectedDate), Icons.calendar_today),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null) setModalState(() => _selectedTime = picked);
                          },
                          child: _buildFakeField(_selectedTime.format(context), Icons.access_time),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: _buildTextField("price_normal".tr(), Icons.payments_outlined, controller: _priceNormalController, keyboardType: TextInputType.number)),
                      const SizedBox(width: 15),
                      Expanded(child: _buildTextField("price_vip".tr(), Icons.stars, controller: _priceVipController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField("total_seats".tr(), Icons.event_seat, controller: _totalSeatsController, keyboardType: TextInputType.number),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate() && _fromCity != null && _toCity != null) {
                          final dateTime = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                            _selectedTime.hour,
                            _selectedTime.minute,
                          );

                          await _tripService.addTrip({
                            'company': _companyController.text,
                            'from': _fromCity,
                            'to': _toCity,
                            'dateTime': Timestamp.fromDate(dateTime),
                            'priceNormal': double.parse(_priceNormalController.text),
                            'priceVip': double.parse(_priceVipController.text),
                            'totalSeats': int.parse(_totalSeatsController.text),
                            'bookedSeats': 0,
                          });
                          if (mounted) Navigator.pop(context);
                        }
                      },
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
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, {TextEditingController? controller, TextInputType? keyboardType, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      validator: (value) => value == null || value.isEmpty ? 'required'.tr() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade200 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCityDropdown(String hint, String? value, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: kSyrianCities.map((city) => DropdownMenuItem(value: city, child: Text(city.tr(), style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFakeField(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 20),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
