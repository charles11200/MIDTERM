import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/constants/colors.dart';
import '../../state/address_provider.dart';
import 'rider_simulator.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  Timer? _statusTimer;
  String status = "Order Confirmed";

  RiderSimulator? _sim;

  @override
  void initState() {
    super.initState();

    // ✅ auto update status after 1 minute
    _statusTimer = Timer(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() => status = "Delivery is on the way");
    });

    final saved = AddressStore.instance.saved;
    if (saved != null) {
      final dest = LatLng(saved.lat, saved.lng);

      // mock rider starts slightly away
      final start = LatLng(dest.latitude + 0.01, dest.longitude - 0.01);

      _sim = RiderSimulator(start: start, destination: dest)
        ..buildRouteWithAStar()
        ..startMoving(step: const Duration(milliseconds: 650));

      _sim!.addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _sim?.disposeSim();
    super.dispose();
  }

  String arrivingByText() {
    final sim = _sim;
    if (sim == null || sim.route.isEmpty) return "Arriving soon";

    // estimate remaining steps from route progress
    final remaining = max(0, sim.route.length - 1);
    final now = DateTime.now();
    final eta = now.add(Duration(minutes: max(1, remaining ~/ 12)));

    int hour = eta.hour;
    final minute = eta.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "Arriving by $hour:$minute ${isPm ? "PM" : "AM"}";
  }

  @override
  Widget build(BuildContext context) {
    final saved = AddressStore.instance.saved;
    final sim = _sim;

    if (saved == null || sim == null) {
      return const CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(middle: Text("Tracking")),
        child: SafeArea(
          child: Center(
            child: Text("Set your Saved Address first in Profile."),
          ),
        ),
      );
    }

    final dest = LatLng(saved.lat, saved.lng);

    final markers = <Marker>{
      Marker(markerId: const MarkerId("dest"), position: dest),
      Marker(
        markerId: const MarkerId("rider"),
        position: sim.rider,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId("route"),
        points: sim.route,
        width: 6,
        color: const Color(0xFF00C853),
      ),
    };

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: dest, zoom: 15),
              markers: markers,
              polylines: polylines,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomGrabCard(
              arrivingBy: arrivingByText(),
              status: status,
              progress: sim.route.isEmpty ? 0 : 1, // just visual; rider movement is shown on map
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: CupertinoButton(
                padding: const EdgeInsets.all(10),
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        offset: Offset(0, 6),
                        color: Color(0x22000000),
                      )
                    ],
                  ),
                  child: const Icon(CupertinoIcons.back, color: CupertinoColors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomGrabCard extends StatelessWidget {
  const _BottomGrabCard({
    required this.arrivingBy,
    required this.status,
    required this.progress,
  });

  final String arrivingBy;
  final String status;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFE9F7F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Priority Delivery",
              style: TextStyle(
                color: AppColors.grabGreen,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            arrivingBy,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(
                  text: "On time · ",
                  style: TextStyle(color: AppColors.grabGreen, fontWeight: FontWeight.w900),
                ),
                TextSpan(
                  text: status,
                  style: const TextStyle(color: CupertinoColors.systemGrey, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              color: CupertinoColors.systemGrey5,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 0.7, // purely visual; map shows actual movement
                child: Container(color: AppColors.grabGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}