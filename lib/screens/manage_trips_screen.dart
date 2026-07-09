import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';
import '../services/trip_service.dart';
import '../services/notification_service.dart';
import '../components/skeleton.dart';

class ManageTripsScreen extends StatefulWidget {
  final String? companyName;
  const ManageTripsScreen({super.key, this.companyName});

  @override
  State<ManageTripsScreen> createState() => _ManageTripsScreenState();
}

class _ManageTripsScreenState extends State<ManageTripsScreen> {
  final TripService _tripService = TripService();
  final NotificationService _notificationService = NotificationService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _priceNormalController = TextEditingController();
  final TextEditingController _priceVipController = TextEditingController();
  final TextEditingController _totalSeatsController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

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

  void _cancelTrip(String id, String from, String to) async {
    await FirebaseFirestore.instance.collection('trips').doc(id).update({
      'status': 'cancelled',
    });

    await _notificationService.notifyTripStatusChange(
      tripId: id,
      status: 'cancelled',
      from: from,
      to: to,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("trip_cancelled".tr())),
      );
    }
  }

  void _postponeTrip(String id, Timestamp current, String from, String to) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current.toDate().isAfter(DateTime.now()) ? current.toDate() : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(current.toDate()),
      );

      if (pickedTime != null) {
        final newDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        await FirebaseFirestore.instance.collection('trips').doc(id).update({
          'dateTime': Timestamp.fromDate(newDateTime),
          'status': 'postponed',
        });

        await _notificationService.notifyTripStatusChange(
          tripId: id,
          status: 'postponed',
          from: from,
          to: to,
          newDateTime: newDateTime,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("trip_postponed".tr())),
          );
        }
      }
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
            return Column(
              children: [
                _buildHeaderStats([]),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: 5,
                    itemBuilder: (context, index) => const ManageTripSkeleton(),
                  ),
                ),
              ],
            );
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
    String status = trip['status'] ?? 'active';

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
                  if (status != 'active') ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: status == 'cancelled' ? Colors.red.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status == 'cancelled' ? "cancelled".tr() : "postponed".tr(),
                        style: TextStyle(
                          color: status == 'cancelled' ? Colors.red : Colors.orange,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              PopupMenuButton<String>(
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(value: 'postpone', child: Row(children: [const Icon(Icons.history_rounded, size: 20, color: Colors.orange), const SizedBox(width: 8), Text("postpone".tr())])),
                  PopupMenuItem<String>(value: 'cancel_trip', child: Row(children: [const Icon(Icons.cancel_rounded, size: 20, color: Colors.red), const SizedBox(width: 8), Text("cancel_trip".tr())])),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(value: 'edit', child: Row(children: [const Icon(Icons.edit, size: 20, color: Colors.blue), const SizedBox(width: 8), Text("edit".tr())])),
                  PopupMenuItem<String>(value: 'delete', child: Row(children: [const Icon(Icons.delete_forever, size: 20, color: Colors.red), const SizedBox(width: 8), Text("delete".tr(), style: const TextStyle(color: Colors.red))])),
                ],
                onSelected: (val) {
                  if (val == 'delete') _deleteTrip(id);
                  if (val == 'cancel_trip') _cancelTrip(id, trip['from'] ?? '', trip['to'] ?? '');
                  if (val == 'postpone') _postponeTrip(id, trip['dateTime'] as Timestamp, trip['from'] ?? '', trip['to'] ?? '');
                  if (val == 'edit') _showEditTripDialog(id, trip);
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
                  Text(
                    "${trip['duration'] ?? '--'} ${"hours".tr()}",
                    style: const TextStyle(fontSize: 12, color: kPrimaryColor, fontWeight: FontWeight.bold),
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
    _durationController.clear();
    _fromCity = null;
    _toCity = null;
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();

    _showTripFormDialog(title: "add_new_trip".tr(), isEdit: false);
  }

  void _showEditTripDialog(String id, Map<String, dynamic> trip) {
    _companyController.text = trip['company'] ?? '';
    _priceNormalController.text = trip['priceNormal']?.toString() ?? '';
    _priceVipController.text = trip['priceVip']?.toString() ?? '';
    _totalSeatsController.text = trip['totalSeats']?.toString() ?? '';
    _durationController.text = trip['duration']?.toString() ?? '';
    _fromCity = trip['from'];
    _toCity = trip['to'];
    
    DateTime dt = (trip['dateTime'] as Timestamp).toDate();
    _selectedDate = dt;
    _selectedTime = TimeOfDay.fromDateTime(dt);

    _showTripFormDialog(title: "edit_trip".tr(), isEdit: true, tripId: id);
  }

  void _showTripFormDialog({required String title, required bool isEdit, String? tripId}) {
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
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor)),
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
                              firstDate: DateTime.now().isBefore(_selectedDate) && isEdit ? DateTime.now().subtract(const Duration(days: 365)) : DateTime.now(),
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
                  const SizedBox(height: 15),
                  _buildTextField("trip_duration_field".tr(), Icons.timer_outlined, controller: _durationController, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
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

                          final tripData = {
                            'company': _companyController.text,
                            'from': _fromCity,
                            'to': _toCity,
                            'dateTime': Timestamp.fromDate(dateTime),
                            'priceNormal': double.parse(_priceNormalController.text),
                            'priceVip': double.parse(_priceVipController.text),
                            'totalSeats': int.parse(_totalSeatsController.text),
                            'duration': double.tryParse(_durationController.text) ?? 4.0,
                          };

                          if (isEdit && tripId != null) {
                            await _tripService.updateTrip(tripId, tripData);
                          } else {
                            await _tripService.addTrip({
                              ...tripData,
                              'bookedSeats': 0,
                              'status': 'active',
                            });
                          }
                          
                          if (mounted) {
                             Navigator.pop(context);
                             ScaffoldMessenger.of(context).showSnackBar(
                               SnackBar(content: Text(isEdit ? "trip_updated".tr() : "trip_saved".tr())),
                             );
                          }
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

class ManageTripSkeleton extends StatelessWidget {
  const ManageTripSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: kWhiteColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Skeleton(width: 20, height: 20, borderRadius: 10),
                  SizedBox(width: 8),
                  Skeleton(width: 100, height: 18),
                ],
              ),
              Skeleton(width: 30, height: 30, borderRadius: 15),
            ],
          ),
          const Divider(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Skeleton(width: 60, height: 18),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Skeleton(width: 16, height: 16),
                  ),
                  Skeleton(width: 60, height: 18),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Skeleton(width: 70, height: 18),
                  SizedBox(height: 5),
                  Skeleton(width: 120, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Skeleton(height: 10, borderRadius: 5),
              ),
              const SizedBox(width: 10),
              Skeleton(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
