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
  final List<LatLng> _routePoints = const [
    LatLng(15.08176, 120.88330), // Jollibee - Santa Ana (Merchant)
    LatLng(15.0823, 120.8981),
    LatLng(15.0814, 120.9125),
    LatLng(15.0786, 120.9224), // San Agustin Bridge
    LatLng(15.0701, 120.9317),
    LatLng(15.0583, 120.9458), // Candaba-Baliuag Rd
    LatLng(15.0443, 120.9572), // User Pinned Location (Home)
  ];

  double _progress = 0.0;
  String _status = "Order received by merchant / preparing food";
  Timer? _simulationTimer;
  final DateTime _startTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startMidtermSimulation();
  }

  /// SYNCHRONIZED SIMULATION FOR MIDTERM REQUIREMENTS
  void _startMidtermSimulation() {
    _simulationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      final elapsedSeconds = DateTime.now().difference(_startTime).inSeconds;

      setState(() {
        if (elapsedSeconds < 60) {
          // PHASE 1 (0-60s): PREPARING
          _status = "Order received by merchant / preparing food";
          _progress = 0.0; // Rider stays at the merchant
        } else if (elapsedSeconds < 120) {
          // PHASE 2 (60-120s): ON THE WAY
          _status = "Delivery is on the way";
          // Rider moves from 0% to 100% within this 60-second window
          _progress = (elapsedSeconds - 60) / 60.0;
        } else {
          // PHASE 3 (120s+): DELIVERED
          _status = "Order Received";
          _progress = 1.0;
          _simulationTimer?.cancel(); // Stop the simulation
        }
      });
    });
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
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

    return LatLng(
      start.latitude + (end.latitude - start.latitude) * segmentProgress,
      start.longitude + (end.longitude - start.longitude) * segmentProgress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Order Tracking')),
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(15.0650, 120.9200),
              zoom: 13.0,
            ),
            polylines: {
              Polyline(
                polylineId: const PolylineId('route'),
                points: _routePoints,
                color: AppColors.grabGreen.withOpacity(0.3),
                width: 5,
              ),
              Polyline(
                polylineId: const PolylineId('traveled'),
                points: _routePoints.sublist(0, (_progress * (_routePoints.length - 1)).floor() + 1)
                  ..add(_getRiderPos()),
                color: AppColors.grabGreen,
                width: 6,
              ),
            },
            markers: {
              Marker(markerId: const MarkerId('merchant'), position: _routePoints.first, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
              Marker(markerId: const MarkerId('home'), position: _routePoints.last, icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)),
              Marker(markerId: const MarkerId('rider'), position: _getRiderPos(), icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure)),
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _StatusCard(status: _status, progress: _progress),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String status;
  final double progress;
  const _StatusCard({required this.status, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: CupertinoColors.systemGrey.withOpacity(0.2), blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          CupertinoProgressBar(value: progress), 
        ],
      ),
    );
  }
}

class CupertinoProgressBar extends StatelessWidget {
  final double value;
  const CupertinoProgressBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10,
      width: double.infinity,
      decoration: BoxDecoration(color: CupertinoColors.systemGrey6, borderRadius: BorderRadius.circular(5)),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(decoration: BoxDecoration(color: AppColors.grabGreen, borderRadius: BorderRadius.circular(5))),
      ),
    );
  }
}
