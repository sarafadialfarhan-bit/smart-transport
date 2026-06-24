import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../components/custom_text_form_field.dart';
import 'trips_screen.dart';

class PassengerDataScreen extends StatefulWidget {
  final Trip trip;

  const PassengerDataScreen({super.key, required this.trip});

  @override
  State<PassengerDataScreen> createState() => _PassengerDataScreenState();
}

class _PassengerDataScreenState extends State<PassengerDataScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedSeatPref;
  String? gender;

  @override
  void initState() {
    super.initState();
    selectedSeatPref = "window";
    gender = "male";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(
          "passenger_data".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: kWhiteColor),
        ),
        centerTitle: true,
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // رأس الصفحة مع تصميم جذاب
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30, top: 10),
              decoration: const BoxDecoration(
                color: kPrimaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_add_alt_1, size: 40, color: kWhiteColor),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "confirm_booking_details".tr(),
                    style: const TextStyle(color: kWhiteColor, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "one_step_away".tr(),
                    style: TextStyle(color: kWhiteColor.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // بطاقة ملخص الرحلة (على شكل تذكرة)
                    _buildSectionTitle("ticket_summary".tr()),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: kWhiteColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: kPrimaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.directions_bus, color: kPrimaryColor),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(widget.trip.company, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(widget.trip.busType, style: const TextStyle(color: kGreyColor, fontSize: 12)),
                                ],
                              ),
                              const Spacer(),
                              Text(widget.trip.price, style: const TextStyle(color: kGreenColor, fontWeight: FontWeight.bold, fontSize: 18)),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Divider(thickness: 1, color: kBackgroundColor),
                          ),
                          _buildTicketDetail(Icons.location_on_outlined, "${"from".tr()}:", widget.trip.from),
                          const SizedBox(height: 10),
                          _buildTicketDetail(Icons.location_on, "${"to".tr()}:", widget.trip.to),
                          const SizedBox(height: 10),
                          _buildTicketDetail(Icons.access_time, "${"time".tr()}:", widget.trip.time),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildSectionTitle("personal_info".tr()),
                    CustomTextFormField(
                      title: "full_name_id".tr(),
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "enter_name_error".tr();
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextFormField(
                            title: "mobile_number".tr(),
                            icon: Icons.phone_android,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) return "enter_mobile_error".tr();
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kPrimaryColor.withOpacity(0.3)),
                          ),
                          child: DropdownButton<String>(
                            value: gender,
                            underline: const SizedBox(),
                            items: [
                              DropdownMenuItem(value: "male", child: Text("male".tr())),
                              DropdownMenuItem(value: "female", child: Text("female".tr())),
                            ],
                            onChanged: (val) => setState(() => gender = val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    CustomTextFormField(
                      title: "national_id".tr(),
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return "enter_national_id_error".tr();
                        if (value.length != 11) return "national_id_length_error".tr();
                        return null;
                      },
                    ),

                    const SizedBox(height: 25),

                    _buildSectionTitle("seating_preferences".tr()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildSeatOption("window", Icons.grid_view_rounded),
                        _buildSeatOption("aisle", Icons.view_column_outlined),
                        _buildSeatOption("front", Icons.front_hand_outlined),
                      ],
                    ),

                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _showSuccessDialog();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 5,
                          shadowColor: kPrimaryColor.withOpacity(0.4),
                        ),
                        child: Text(
                          "confirm_final_booking".tr(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kWhiteColor),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, right: 5),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kSecondaryColor),
      ),
    );
  }

  Widget _buildTicketDetail(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kGreyColor),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: kGreyColor, fontSize: 14)),
        const SizedBox(width: 10),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }

  Widget _buildSeatOption(String key, IconData icon) {
    bool isSelected = selectedSeatPref == key;
    return GestureDetector(
      onTap: () => setState(() => selectedSeatPref = key),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.28,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : kWhiteColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: isSelected ? kPrimaryColor : kPrimaryColor.withOpacity(0.1)),
          boxShadow: isSelected ? [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))] : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? kWhiteColor : kPrimaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              key.tr(),
              style: TextStyle(
                color: isSelected ? kWhiteColor : kSecondaryColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            const Icon(Icons.check_circle_rounded, color: kGreenColor, size: 100),
            const SizedBox(height: 25),
            Text(
              "booking_success".tr(),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kSecondaryColor),
            ),
            const SizedBox(height: 15),
            Text(
              "booking_success_msg".tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: kGreyColor, fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 35),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text("back_to_home".tr(), style: const TextStyle(color: kWhiteColor, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
