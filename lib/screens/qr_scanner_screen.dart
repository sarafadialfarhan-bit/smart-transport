import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:easy_localization/easy_localization.dart';
import '../constants.dart';
import '../services/booking_service.dart';

class QRScannerScreen extends StatefulWidget {
  final String tripId;
  const QRScannerScreen({super.key, required this.tripId});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final BookingService _bookingService = BookingService();
  bool _isScanning = true;

  void _onDetect(BarcodeCapture capture) async {
    if (!_isScanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? bookingId = barcodes.first.rawValue;
      if (bookingId != null) {
        setState(() => _isScanning = false);
        _processBoarding(bookingId);
      }
    }
  }

  void _processBoarding(String bookingId) async {
    try {
      // Logic to verify booking belongs to this trip could be added here
      await _bookingService.markAsBoarded(bookingId);
      
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: kGreenColor, size: 60),
            title: Text("boarding_confirmed".tr()),
            content: Text("passenger_checked_in".tr()),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() => _isScanning = true);
                },
                child: Text("next_passenger".tr()),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context), // Close dialog
                child: Text("finish".tr()),
              ),
            ],
          ),
        ).then((_) {
            if (!_isScanning) Navigator.pop(context);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("error_scanning".tr()), backgroundColor: Colors.red),
        );
        setState(() => _isScanning = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("scan_ticket".tr(), style: const TextStyle(color: kWhiteColor)),
        backgroundColor: kSecondaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: kPrimaryColor, width: 4),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "align_qr_within_box".tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
