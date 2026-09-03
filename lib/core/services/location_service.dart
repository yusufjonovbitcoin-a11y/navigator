import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class UserLocation {
  final double latitude;
  final double longitude;
  final double speedKmh;
  final double heading;
  final double accuracy;
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.speedKmh = 0.0,
    this.heading = 0.0,
    this.accuracy = 5.0,
    required this.timestamp,
  });

  LatLng get latLng => LatLng(latitude, longitude);

  // Default coordinate: Samarkand Center (Registon)
  static UserLocation get defaultLocation => UserLocation(
        latitude: 39.654760,
        longitude: 66.975830,
        speedKmh: 0.0,
        heading: 0.0,
        timestamp: DateTime.now(),
      );

  static UserLocation get defaultTashkent => defaultLocation;
}

class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;
  final _locationController = StreamController<UserLocation>.broadcast();

  Stream<UserLocation> get onLocationChanged => _locationController.stream;

  Future<bool> checkAndRequestPermissions() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return false;
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<UserLocation> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        return UserLocation.defaultTashkent;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 4),
      );

      final speedKmh = (position.speed * 3.6).clamp(0.0, 220.0);
      final loc = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        speedKmh: speedKmh,
        heading: position.heading,
        accuracy: position.accuracy,
        timestamp: position.timestamp,
      );

      _locationController.add(loc);
      return loc;
    } catch (e) {
      try {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          return UserLocation(
            latitude: lastKnown.latitude,
            longitude: lastKnown.longitude,
            speedKmh: 0.0,
            heading: lastKnown.heading,
            accuracy: lastKnown.accuracy,
            timestamp: lastKnown.timestamp,
          );
        }
      } catch (_) {}
      return UserLocation.defaultTashkent;
    }
  }

  Future<void> startLocationTracking() async {
    _positionSubscription?.cancel();
    _stopSimulation();

    final hasPermission = await checkAndRequestPermissions();
    if (hasPermission) {
      // 1. Immediately push the current position
      try {
        final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.bestForNavigation,
          timeLimit: const Duration(seconds: 3),
        );
        final speedKmh = (pos.speed * 3.6).clamp(0.0, 220.0);
        _locationController.add(
          UserLocation(
            latitude: pos.latitude,
            longitude: pos.longitude,
            speedKmh: speedKmh,
            heading: pos.heading,
            accuracy: pos.accuracy,
            timestamp: pos.timestamp,
          ),
        );
      } catch (_) {
        final lastKnown = await Geolocator.getLastKnownPosition();
        if (lastKnown != null) {
          _locationController.add(
            UserLocation(
              latitude: lastKnown.latitude,
              longitude: lastKnown.longitude,
              speedKmh: 0.0,
              heading: lastKnown.heading,
              accuracy: lastKnown.accuracy,
              timestamp: lastKnown.timestamp,
            ),
          );
        }
      }

      // 2. Continuous real-time GPS stream
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1, // update every 1 meter
        ),
      ).listen(
        (position) {
          final speedKmh = (position.speed * 3.6).clamp(0.0, 220.0);
          _locationController.add(
            UserLocation(
              latitude: position.latitude,
              longitude: position.longitude,
              speedKmh: speedKmh,
              heading: position.heading,
              accuracy: position.accuracy,
              timestamp: position.timestamp,
            ),
          );
        },
        onError: (_) {},
      );
    } else {
      _locationController.add(UserLocation.defaultTashkent);
    }
  }

  void stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  // --- Drive Simulation for Testing ---
  void startDriveSimulation({
    required List<LatLng> waypoints,
    double targetSpeedKmh = 68.0,
    VoidCallback? onFinished,
  }) {
    _positionSubscription?.cancel();
    _stopSimulation();

    if (waypoints.isEmpty) return;

    int currentIndex = 0;
    double currentProgress = 0.0;
    const updateIntervalMs = 250;
    final stepSize = (targetSpeedKmh / 3.6) * (updateIntervalMs / 1000.0); // meters per tick

    _simulationTimer = Timer.periodic(
      const Duration(milliseconds: updateIntervalMs),
      (timer) {
        if (currentIndex >= waypoints.length - 1) {
          _stopSimulation();
          onFinished?.call();
          return;
        }

        double remainingStep = stepSize;
        while (remainingStep > 0 && currentIndex < waypoints.length - 1) {
          final p1 = waypoints[currentIndex];
          final p2 = waypoints[currentIndex + 1];
          final segmentDist = calculateDistance(p1.latitude, p1.longitude, p2.latitude, p2.longitude);

          if (segmentDist <= 0.1) {
            currentIndex++;
            currentProgress = 0.0;
            continue;
          }

          final remainingSegment = segmentDist * (1.0 - currentProgress);
          if (remainingStep >= remainingSegment) {
            remainingStep -= remainingSegment;
            currentIndex++;
            currentProgress = 0.0;
          } else {
            currentProgress += remainingStep / segmentDist;
            remainingStep = 0;
          }
        }

        if (currentIndex >= waypoints.length - 1) {
          _stopSimulation();
          onFinished?.call();
          return;
        }

        final nextP1 = waypoints[currentIndex];
        final nextP2 = waypoints[currentIndex + 1];
        final lat = nextP1.latitude + (nextP2.latitude - nextP1.latitude) * currentProgress;
        final lng = nextP1.longitude + (nextP2.longitude - nextP1.longitude) * currentProgress;
        final heading = calculateBearing(nextP1.latitude, nextP1.longitude, nextP2.latitude, nextP2.longitude);

        // Realistic driving speed variation
        final jitter = (math.Random().nextDouble() - 0.5) * 2.0;
        final simulatedSpeed = (targetSpeedKmh + jitter).clamp(0.0, 140.0);

        _locationController.add(
          UserLocation(
            latitude: lat,
            longitude: lng,
            speedKmh: simulatedSpeed,
            heading: heading,
            timestamp: DateTime.now(),
          ),
        );
      },
    );
  }

  void _stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void stopDriveSimulation() {
    _stopSimulation();
  }

  bool get isSimulating => _simulationTimer != null && _simulationTimer!.isActive;

  static double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  static double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * (math.pi / 180.0);
    final y = math.sin(dLon) * math.cos(lat2 * (math.pi / 180.0));
    final x = math.cos(lat1 * (math.pi / 180.0)) * math.sin(lat2 * (math.pi / 180.0)) -
        math.sin(lat1 * (math.pi / 180.0)) * math.cos(lat2 * (math.pi / 180.0)) * math.cos(dLon);
    final radians = math.atan2(y, x);
    return (radians * (180.0 / math.pi) + 360.0) % 360.0;
  }

  void dispose() {
    _positionSubscription?.cancel();
    _simulationTimer?.cancel();
    _locationController.close();
  }
}
