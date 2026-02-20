import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/colors.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // 📍 REAL ROAD POINTS (Jollibee Santa Ana -> Candaba-Baliuag Rd -> Candaba)
  final List<LatLng> _routePoints = const [
    LatLng(15.08176, 120.88330), // Jollibee - Santa Ana
    LatLng(15.0823, 120.8981),  // Crossing/Intersection
    LatLng(15.0814, 120.9125),  // Near San Pedro
    LatLng(15.0786, 120.9224),  // San Agustin Bridge
    LatLng(15.0701, 120.9317),  // Turning South East
    LatLng(15.0583, 120.9458),  // Candaba-Baliuag Rd
    LatLng(15.0443, 120.9572),  // Destination (Candaba Area)
  ];

  late LatLng restaurantLoc;
  late LatLng homeLoc;

  double _progress = 0.0;
  Timer? _riderMoveTimer;
  String _status = "Order received by merchant / preparing food";

  @override
  void initState() {
    super.initState();
    restaurantLoc = _routePoints.first;
    homeLoc = _routePoints.last;
    _startStatusUpdates();
    _startRiderMovement();
  }

  /// Handles the TIME-BASED status updates as per your requirement.
  void _startStatusUpdates() {
    // After 1 minute, change status to "On The Way"
    Future.delayed(const Duration(minutes: 1), () {
      if (mounted) {
        setState(() {
          _status = "On The Way";
        });
      }
    });
  }

  /// Handles the VISUAL rider movement on the map.
  void _startRiderMovement() {
    _riderMoveTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.0025; 
        if (_progress >= 1.0) {
          _progress = 1.0;
          _status = "Order Received"; // Final status on arrival
          _riderMoveTimer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _riderMoveTimer?.cancel();
    super.dispose();
  }

  LatLng _getRiderPos() {
    if (_progress <= 0) return _routePoints.first;
    if (_progress >= 1) return _routePoints.last;

    double totalSegments = (_routePoints.length - 1).toDouble();
    double segmentIndex = _progress * totalSegments;
    int index = segmentIndex.floor();
    double segmentProgress = segmentIndex - index;

    LatLng start = _routePoints[index];
    LatLng end = _routePoints[index + 1];

    double lat = start.latitude + (end.latitude - start.latitude) * segmentProgress;
    double lng = start.longitude + (end.longitude - start.longitude) * segmentProgress;
    return LatLng(lat, lng);
  }

  String _getArrivalTime() {
    final now = DateTime.now().add(const Duration(minutes: 25));
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? "PM" : "AM";
    return "Arriving by $hour:$minute $ampm";
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // REAL GOOGLE MAP
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(15.0650, 120.9200),
              zoom: 13.5,
            ),
            mapType: MapType.normal,
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: AppColors.grabGreen.withOpacity(0.3),
                width: 6,
              ),
              Polyline(
                polylineId: const PolylineId('traveled_route'),
                points: _routePoints.sublist(0, (_progress * (_routePoints.length - 1)).floor() + 1)
                  ..add(_getRiderPos()),
                color: AppColors.grabGreen,
                width: 7,
                jointType: JointType.round,
                startCap: Cap.roundCap,
                endCap: Cap.roundCap,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('restaurant'),
                position: restaurantLoc,
                infoWindow: const InfoWindow(title: 'Jollibee Santa Ana'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('home'),
                position: homeLoc,
                infoWindow: const InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              ),
              Marker(
                markerId: const MarkerId('rider'),
                position: _getRiderPos(),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              ),
            },
          ),

          // BOTTOM GRAB INFO CARD
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomCard(
              arrivalTime: _getArrivalTime(),
              status: _status,
              progress: _progress,
            ),
          ),

          // BACK BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(blurRadius: 10, color: Color(0x33000000))],
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

class _BottomCard extends StatelessWidget {
  const _BottomCard({required this.arrivalTime, required this.status, required this.progress});
  final String arrivalTime;
  final String status;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Color(0x1A000000))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "Priority Delivery",
              style: TextStyle(
                color: AppColors.grabGreen,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(arrivalTime, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                "On time",
                style: TextStyle(color: AppColors.grabGreen, fontWeight: FontWeight.w900),
              ),
              const Text(" • "),
              Expanded(
                child: Text(
                  status,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: CupertinoColors.systemGrey, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.0, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.grabGreen,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
