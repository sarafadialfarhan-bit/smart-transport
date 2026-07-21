import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/bus_service.dart';
import '../components/skeleton.dart';

class FleetManagementScreen extends StatefulWidget {
  final String companyId;
  const FleetManagementScreen({super.key, required this.companyId});

  @override
  State<FleetManagementScreen> createState() => _FleetManagementScreenState();
}

class _FleetManagementScreenState extends State<FleetManagementScreen> {
  final BusService _busService = BusService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  String _busType = 'standard'; // standard (2+2), vip (2+1)

  void _showAddBusDialog([String? id, Map<String, dynamic>? data]) {
    if (data != null) {
      _nameController.text = data['name'] ?? '';
      _seatsController.text = data['totalSeats']?.toString() ?? '';
      _busType = data['type'] ?? 'standard';
    } else {
      _nameController.clear();
      _seatsController.clear();
      _busType = 'standard';
    }

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
                  Text(id == null ? "add_new_bus".tr() : "edit_bus".tr(), 
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kSecondaryColor)),
                  const SizedBox(height: 20),
                  _buildTextField("bus_name_hint".tr(), Icons.directions_bus, _nameController),
                  const SizedBox(height: 15),
                  _buildTextField("total_seats".tr(), Icons.event_seat, _seatsController, keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  Text("bus_type".tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTypeOption(setModalState, "standard", "2+2 Standard"),
                      const SizedBox(width: 10),
                      _buildTypeOption(setModalState, "vip", "2+1 VIP"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final busData = {
                            'name': _nameController.text,
                            'totalSeats': int.parse(_seatsController.text),
                            'type': _busType,
                            'companyId': widget.companyId,
                          };
                          if (id == null) {
                            await _busService.addBus(busData);
                          } else {
                            await _busService.updateBus(id, busData);
                          }
                          if (mounted) Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: Text("save".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
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

  Widget _buildTypeOption(StateSetter setModalState, String type, String label) {
    bool isSelected = _busType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setModalState(() => _busType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller, {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: (val) => val == null || val.isEmpty ? "required".tr() : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text("fleet_management".tr(), style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor)),
        backgroundColor: kSecondaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBusDialog(),
        backgroundColor: kPrimaryColor,
        icon: const Icon(Icons.add, color: kWhiteColor),
        label: Text("add_bus".tr(), style: const TextStyle(color: kWhiteColor, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _busService.getCompanyBuses(widget.companyId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final buses = snapshot.data!.docs;

          if (buses.isEmpty) {
            return Center(child: Text("no_buses_yet".tr()));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: buses.length,
            itemBuilder: (context, index) {
              final data = buses[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: const CircleAvatar(backgroundColor: kBackgroundColor, child: Icon(Icons.directions_bus, color: kPrimaryColor)),
                  title: Text(data['name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${data['totalSeats']} ${"seats".tr()} | ${data['type'].toString().toUpperCase()}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showAddBusDialog(buses[index].id, data)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _busService.deleteBus(buses[index].id)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
