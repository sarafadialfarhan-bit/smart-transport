import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:latlong2/latlong.dart';
import '../constants.dart';

class BusTrackingScreen extends StatefulWidget {
  final String tripId;
  final String from;
  final String to;

  const BusTrackingScreen({
    super.key,
    required this.tripId,
    required this.from,
    required this.to,
  });

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.from.tr()} → ${widget.to.tr()}",
          style: const TextStyle(color: kWhiteColor),
        ),
        backgroundColor: kPrimaryColor,
        iconTheme: const IconThemeData(color: kWhiteColor),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trips')
            .doc(widget.tripId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null || data['isLive'] != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 60, color: kGreyColor),
                  const SizedBox(height: 15),
                  Text(
                    "tracking_not_available".tr(),
                    style: const TextStyle(color: kGreyColor),
                  ),
                ],
              ),
            );
          }

          final lat = data['currentLat'] as double;
          final lng = data['currentLng'] as double;
          final pos = LatLng(lat, lng);

          // Update map center automatically
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _mapController.move(pos, _mapController.camera.zoom);
          });

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: pos, initialZoom: 14.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smart.transport.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: pos,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.directions_bus,
                      color: kSecondaryColor,
                      size: 40,
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
