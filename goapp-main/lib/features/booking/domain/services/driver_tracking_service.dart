import 'dart:math' as math;

import '../entities/geo_point.dart';

class DriverTrackingSample {
  final GeoPoint location;
  final double progress;
  final List<GeoPoint> remainingPath;

  const DriverTrackingSample({
    required this.location,
    required this.progress,
    required this.remainingPath,
  });
}

class DriverTrackingService {
  final Duration interval;
  final int steps;
  final double approachDistanceKm;

  const DriverTrackingService({
    this.interval = const Duration(milliseconds: 700),
    this.steps = 20,
    this.approachDistanceKm = 0.8,
  });

  Stream<DriverTrackingSample> trackToPickup({
    required GeoPoint pickup,
    String? encodedPath,
  }) {
    final path = _buildPathToPickup(
      pickup: pickup,
      routePoints: _decodePolyline(encodedPath),
    );
    if (path.length < 2) {
      return _trackLinear(
        start: _offsetStart(pickup),
        end: pickup,
      );
    }
    return _trackAlongPath(path);
  }

  Stream<DriverTrackingSample> trackToDrop({
    required GeoPoint pickup,
    required GeoPoint drop,
    String? encodedPath,
  }) {
    final path = _buildPathToDrop(
      pickup: pickup,
      drop: drop,
      routePoints: _decodePolyline(encodedPath),
    );
    if (path.length < 2) {
      return _trackAlongPath([pickup, drop]);
    }
    return _trackAlongPath(path);
  }

  Stream<DriverTrackingSample> _trackLinear({
    required GeoPoint start,
    required GeoPoint end,
  }) {
    final totalSteps = steps <= 0 ? 1 : steps;
    return Stream<DriverTrackingSample>.periodic(
      interval,
      (index) {
        final step = index > totalSteps ? totalSteps : index;
        final progress = step / totalSteps;
        final lat = start.lat + (end.lat - start.lat) * progress;
        final lng = start.lng + (end.lng - start.lng) * progress;
        final location = GeoPoint(lat: lat, lng: lng);
        return DriverTrackingSample(
          location: location,
          progress: progress,
          remainingPath: _remainingPathLinear(location, end),
        );
      },
    ).take(totalSteps + 1);
  }

  Stream<DriverTrackingSample> _trackAlongPath(List<GeoPoint> path) {
    final totalSteps = steps <= 0 ? 1 : steps;
    return Stream<DriverTrackingSample>.periodic(
      interval,
      (index) {
        final step = index > totalSteps ? totalSteps : index;
        final progress = step / totalSteps;
        final location = _interpolatePath(path, progress);
        return DriverTrackingSample(
          location: location,
          progress: progress,
          remainingPath: _remainingPathAlongPath(path, progress, location),
        );
      },
    ).take(totalSteps + 1);
  }

  GeoPoint _interpolatePath(List<GeoPoint> path, double progress) {
    if (path.isEmpty) {
      return const GeoPoint(lat: 0, lng: 0);
    }
    if (progress <= 0) return path.first;
    if (progress >= 1) return path.last;

    final scaled = (path.length - 1) * progress;
    final lowerIndex = scaled.floor();
    final upperIndex =
        lowerIndex + 1 < path.length ? lowerIndex + 1 : lowerIndex;
    final t = scaled - lowerIndex;
    final start = path[lowerIndex];
    final end = path[upperIndex];
    final lat = start.lat + (end.lat - start.lat) * t;
    final lng = start.lng + (end.lng - start.lng) * t;
    return GeoPoint(lat: lat, lng: lng);
  }

  List<GeoPoint> _remainingPathLinear(GeoPoint current, GeoPoint pickup) {
    return [
      current,
      pickup,
    ];
  }

  List<GeoPoint> _remainingPathAlongPath(
    List<GeoPoint> path,
    double progress,
    GeoPoint current,
  ) {
    if (path.isEmpty) return const [];
    if (progress >= 1) return [path.last];
    final scaled = (path.length - 1) * progress;
    final index = scaled.floor();
    if (index >= path.length - 1) {
      return [path.last];
    }
    final tail = path.sublist(index + 1);
    return [current, ...tail];
  }

  List<GeoPoint> _buildPathToPickup({
    required GeoPoint pickup,
    required List<GeoPoint> routePoints,
  }) {
    if (routePoints.isEmpty) return routePoints;

    final int cutoffIndex = _findApproachIndex(
      pickup: pickup,
      routePoints: routePoints,
    );
    if (cutoffIndex < 1) {
      return const [];
    }
    final segment = routePoints.sublist(0, cutoffIndex + 1);
    final reversed = segment.reversed.toList();
    if (!_isNear(reversed.last, pickup)) {
      return List<GeoPoint>.from(reversed)..add(pickup);
    }
    return reversed;
  }

  List<GeoPoint> _buildPathToDrop({
    required GeoPoint pickup,
    required GeoPoint drop,
    required List<GeoPoint> routePoints,
  }) {
    if (routePoints.isEmpty) return routePoints;
    final int startIndex = _findNearestIndex(
      target: pickup,
      points: routePoints,
    );
    if (startIndex < 0) return const [];
    final path = List<GeoPoint>.from(routePoints.sublist(startIndex));
    if (!_isNear(path.first, pickup)) {
      path.insert(0, pickup);
    }
    if (!_isNear(path.last, drop)) {
      path.add(drop);
    }
    return path;
  }

  bool _isNear(GeoPoint a, GeoPoint b) {
    const tolerance = 1e-4;
    return (a.lat - b.lat).abs() < tolerance &&
        (a.lng - b.lng).abs() < tolerance;
  }

  GeoPoint _offsetStart(GeoPoint pickup) {
    return GeoPoint(
      lat: pickup.lat + 0.01,
      lng: pickup.lng + 0.01,
    );
  }

  int _findApproachIndex({
    required GeoPoint pickup,
    required List<GeoPoint> routePoints,
  }) {
    if (routePoints.length < 2) return 0;
    if (!_isNear(routePoints.first, pickup)) {
      return 0;
    }
    double distance = 0;
    for (int i = 1; i < routePoints.length; i += 1) {
      distance += _distanceKm(routePoints[i - 1], routePoints[i]);
      if (distance >= approachDistanceKm) {
        return i;
      }
    }
    return routePoints.length - 1;
  }

  int _findNearestIndex({
    required GeoPoint target,
    required List<GeoPoint> points,
  }) {
    if (points.isEmpty) return -1;
    int bestIndex = 0;
    double bestDistance = double.infinity;
    for (int i = 0; i < points.length; i += 1) {
      final distance = _distanceKm(points[i], target);
      if (distance < bestDistance) {
        bestDistance = distance;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  double _distanceKm(GeoPoint a, GeoPoint b) {
    const earthRadiusKm = 6371.0;
    final lat1 = _degToRad(a.lat);
    final lat2 = _degToRad(b.lat);
    final dLat = lat2 - lat1;
    final dLng = _degToRad(b.lng - a.lng);
    final x = dLng * math.cos((lat1 + lat2) / 2);
    final y = dLat;
    return earthRadiusKm * math.sqrt(x * x + y * y);
  }

  double _degToRad(double deg) => deg * math.pi / 180;

  List<GeoPoint> _decodePolyline(String? encoded) {
    if (encoded == null || encoded.isEmpty) return const [];

    final List<GeoPoint> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final int deltaLat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20 && index < encoded.length);
      final int deltaLng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      points.add(GeoPoint(lat: lat / 1e5, lng: lng / 1e5));
    }

    return points;
  }
}
