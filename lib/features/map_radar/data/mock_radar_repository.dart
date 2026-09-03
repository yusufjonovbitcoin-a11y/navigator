import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/features/map_radar/data/mock_radar_data.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/domain/repositories/radar_repository.dart';

class MockRadarRepository implements RadarRepository {
  final List<RadarPoint> _radars = List.from(mockRadarsTashkent);

  @override
  Future<List<RadarPoint>> getNearbyRadars({
    required double lat,
    required double lng,
    double radiusKm = 15.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final radiusMeters = radiusKm * 1000.0;
    final List<RadarPoint> results = [];

    for (final radar in _radars) {
      final dist = LocationService.calculateDistance(lat, lng, radar.lat, radar.lng);
      if (dist <= radiusMeters) {
        results.add(radar.copyWith(distanceMeters: dist));
      }
    }

    results.sort((a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
    return results;
  }

  @override
  Future<RadarPoint?> getClosestRadar({
    required double lat,
    required double lng,
    double maxDistanceMeters = 2000.0,
  }) async {
    final radars = await getNearbyRadars(lat: lat, lng: lng, radiusKm: maxDistanceMeters / 1000.0);
    if (radars.isEmpty) return null;
    return radars.first;
  }

  @override
  Future<RadarPoint> getRadarById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _radars.firstWhere(
      (r) => r.id == id,
      orElse: () => _radars.first,
    );
  }

  @override
  Future<bool> confirmRadar(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _radars.indexWhere((r) => r.id == id);
    if (index != -1) {
      final r = _radars[index];
      _radars[index] = r.copyWith(
        confirmedCount: r.confirmedCount + 1,
        lastConfirmed: DateTime.now(),
      );
      return true;
    }
    return false;
  }
}
