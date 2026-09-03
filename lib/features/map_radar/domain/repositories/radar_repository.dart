import '../models/radar_point.dart';

abstract class RadarRepository {
  Future<List<RadarPoint>> getNearbyRadars({
    required double lat,
    required double lng,
    double radiusKm = 15.0,
  });

  Future<RadarPoint?> getClosestRadar({
    required double lat,
    required double lng,
    double maxDistanceMeters = 2000.0,
  });

  Future<RadarPoint> getRadarById(String id);

  Future<bool> confirmRadar(String id);
}
