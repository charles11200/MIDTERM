import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import '../../core/constants/colors.dart';
import '../../core/widgets/safe_image.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // --- SIMULATION SETTINGS ---
  static const int totalSteps = 60; // 60 updates
  static const Duration tick = Duration(seconds: 1); // 1 step per second
  static const int minutesPerStep = 1; // used for ETA display (tweak)

  int step = 0;
  String status = "Order Confirmed";

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Status auto update after 1 minute (per requirement)
    Future.delayed(const Duration(minutes: 1), () {
      if (!mounted) return;
      setState(() => status = "Delivery is on the way");
    });

    _timer = Timer.periodic(tick, (_) {
      if (!mounted) return;
      setState(() {
        step = min(step + 1, totalSteps);
      });
      if (step >= totalSteps) {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // --- ETA CALCULATION (Arriving by time) ---
  String arrivingByText() {
    final remaining = max(0, totalSteps - step);
    final remainingMinutes = max(1, (remaining * minutesPerStep) ~/ 10); // tweak feel
    final now = DateTime.now();
    final eta = now.add(Duration(minutes: remainingMinutes));

    int hour = eta.hour;
    final minute = eta.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;

    return "Arriving by $hour:$minute ${isPm ? "PM" : "AM"}";
  }

  double progress() => step / totalSteps;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // FAKE MAP BACKGROUND (use your own map screenshot if you want)
          Positioned.fill(
            child: SafeAssetImage(
              path: "assets/images/banners/promo1.jpg", // replace with your own map-like image if you want
              fit: BoxFit.cover,
              radius: 0,
            ),
          ),

          // GREEN ROUTE (fake polyline)
          Positioned.fill(
            child: CustomPaint(
              painter: _RoutePainter(progress: progress()),
            ),
          ),

          // RIDER ICON moving
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;

                // Simple route curve points (fake)
                final start = Offset(w * 0.15, h * 0.65);
                final end = Offset(w * 0.70, h * 0.25);

                // interpolate along curve
                final t = progress();
                final p = Offset(
                  lerpDouble(start.dx, end.dx, t),
                  lerpDouble(start.dy, end.dy, t),
                );

                return Stack(
                  children: [
                    Positioned(
                      left: p.dx - 22,
                      top: p.dy - 22,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 12,
                              offset: Offset(0, 6),
                              color: Color(0x33000000),
                            )
                          ],
                        ),
                        child: const Icon(
                          CupertinoIcons.car_detailed,
                          color: AppColors.grabGreen,
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // BOTTOM CARD (like Grab)
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomGrabCard(
              arrivingBy: arrivingByText(),
              status: status,
              progress: progress(),
            ),
          ),

          // TOP BACK BUTTON
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14),
              children: [
                const TextSpan(
                  text: "On time · ",
                  style: TextStyle(
                    color: AppColors.grabGreen,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                TextSpan(
                  text: status,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // progress bar (like your screenshot line)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 8,
              color: CupertinoColors.systemGrey5,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0, 1),
                child: Container(color: AppColors.grabGreen),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // icons row
          Row(
            children: const [
              Icon(CupertinoIcons.person, size: 18, color: AppColors.grabGreen),
              SizedBox(width: 8),
              Expanded(child: _SmallDotLine()),
              Icon(CupertinoIcons.bag, size: 18, color: AppColors.grabGreen),
              SizedBox(width: 8),
              Expanded(child: _SmallDotLine()),
              Icon(CupertinoIcons.car_detailed, size: 18, color: AppColors.grabGreen),
              SizedBox(width: 8),
              Expanded(child: _SmallDotLine()),
              Icon(CupertinoIcons.house_fill, size: 18, color: CupertinoColors.systemGrey),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallDotLine extends StatelessWidget {
  const _SmallDotLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      color: CupertinoColors.systemGrey4,
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.grabGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.15, h * 0.65)
      ..lineTo(w * 0.30, h * 0.55)
      ..lineTo(w * 0.45, h * 0.60)
      ..lineTo(w * 0.55, h * 0.40)
      ..lineTo(w * 0.70, h * 0.25);

    // draw only partial route (progress)
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return;

    final metric = metrics.first;
    final len = metric.length * progress.clamp(0, 1);
    final partial = metric.extractPath(0, len);

    canvas.drawPath(partial, paint);
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

double lerpDouble(double a, double b, double t) => a + (b - a) * t;
