import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderSimulator extends ChangeNotifier {
  RiderSimulator({required this.start, required this.destination});

  final LatLng start;
  final LatLng destination;

  LatLng rider = const LatLng(0, 0);
  List<LatLng> route = [];
  Timer? _timer;
  int _idx = 0;

  static const int gridSize = 35;

  void buildRouteWithAStar() {
    final a = _toGrid(start);
    final b = _toGrid(destination);

    final path = _aStar(a, b);
    route = path.map(_toLatLng).toList();

    rider = route.isNotEmpty ? route.first : start;
    _idx = 0;
    notifyListeners();
  }

  void startMoving({Duration step = const Duration(milliseconds: 650)}) {
    if (route.isEmpty) buildRouteWithAStar();
    if (route.isEmpty) return;

    _timer?.cancel();
    _timer = Timer.periodic(step, (_) {
      if (_idx >= route.length - 1) {
        stop();
        return;
      }
      _idx++;
      rider = route[_idx];
      notifyListeners();
    });
  }

  void stop() => _timer?.cancel();
  void disposeSim() => _timer?.cancel();

  // ----- A* grid helpers -----
  Point<int> _toGrid(LatLng p) {
    final minLat = min(start.latitude, destination.latitude) - 0.01;
    final maxLat = max(start.latitude, destination.latitude) + 0.01;
    final minLng = min(start.longitude, destination.longitude) - 0.01;
    final maxLng = max(start.longitude, destination.longitude) + 0.01;

    final x = ((p.latitude - minLat) / (maxLat - minLat) * (gridSize - 1)).round();
    final y = ((p.longitude - minLng) / (maxLng - minLng) * (gridSize - 1)).round();
    return Point<int>(x.clamp(0, gridSize - 1), y.clamp(0, gridSize - 1));
  }

  LatLng _toLatLng(Point<int> g) {
    final minLat = min(start.latitude, destination.latitude) - 0.01;
    final maxLat = max(start.latitude, destination.latitude) + 0.01;
    final minLng = min(start.longitude, destination.longitude) - 0.01;
    final maxLng = max(start.longitude, destination.longitude) + 0.01;

    final lat = minLat + (g.x / (gridSize - 1)) * (maxLat - minLat);
    final lng = minLng + (g.y / (gridSize - 1)) * (maxLng - minLng);
    return LatLng(lat, lng);
  }

  int _h(Point<int> a, Point<int> b) => (a.x - b.x).abs() + (a.y - b.y).abs();

  List<Point<int>> _neighbors(Point<int> p) {
    const dirs = [Point(1, 0), Point(-1, 0), Point(0, 1), Point(0, -1)];
    final res = <Point<int>>[];
    for (final d in dirs) {
      final n = Point<int>(p.x + d.x, p.y + d.y);
      if (n.x >= 0 && n.x < gridSize && n.y >= 0 && n.y < gridSize) res.add(n);
    }
    return res;
  }

  List<Point<int>> _aStar(Point<int> startP, Point<int> goal) {
    final open = <Point<int>>{startP};
    final cameFrom = <Point<int>, Point<int>>{};
    final gScore = <Point<int>, int>{startP: 0};
    final fScore = <Point<int>, int>{startP: _h(startP, goal)};

    Point<int> best() {
      Point<int>? b;
      var bestVal = 1 << 30;
      for (final p in open) {
        final v = fScore[p] ?? (1 << 29);
        if (v < bestVal) {
          bestVal = v;
          b = p;
        }
      }
      return b!;
    }

    while (open.isNotEmpty) {
      final current = best();
      if (current == goal) {
        final path = <Point<int>>[current];
        var cur = current;
        while (cameFrom.containsKey(cur)) {
          cur = cameFrom[cur]!;
          path.add(cur);
        }
        return path.reversed.toList();
      }

      open.remove(current);

      for (final n in _neighbors(current)) {
        final tentativeG = (gScore[current] ?? (1 << 29)) + 1;
        if (tentativeG < (gScore[n] ?? (1 << 29))) {
          cameFrom[n] = current;
          gScore[n] = tentativeG;
          fScore[n] = tentativeG + _h(n, goal);
          open.add(n);
        }
      }
    }

    return [];
  }
}