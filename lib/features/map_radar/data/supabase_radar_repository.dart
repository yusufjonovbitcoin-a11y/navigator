import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/map_radar/data/mock_radar_repository.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/domain/repositories/radar_repository.dart';

class SupabaseRadarRepository implements RadarRepository {
  final MockRadarRepository _fallback = MockRadarRepository();

  @override
  Future<List<RadarPoint>> getNearbyRadars({
    required double lat,
    required double lng,
    double radiusKm = 25.0,
  }) async {
    try {
      final response = await SupabaseService.client
          .from('radars')
          .select()
          .order('created_at', ascending: false);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isEmpty) {
        return await _fallback.getNearbyRadars(lat: lat, lng: lng, radiusKm: radiusKm);
      }

      final radars = data.map((json) {
        final r = RadarPoint.fromJson(json as Map<String, dynamic>);
        final d = LocationService.calculateDistance(lat, lng, r.lat, r.lng);
        return r.copyWith(distanceMeters: d);
      }).toList();

      // Sort by proximity
      radars.sort((a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0));
      return radars;
    } catch (_) {
      // Fallback seamlessly if offline
      return await _fallback.getNearbyRadars(lat: lat, lng: lng, radiusKm: radiusKm);
    }
  }

  @override
  Future<RadarPoint?> getClosestRadar({
    required double lat,
    required double lng,
    double maxDistanceMeters = 2000.0,
  }) async {
    final list = await getNearbyRadars(lat: lat, lng: lng);
    if (list.isEmpty) return null;
    final closest = list.first;
    if ((closest.distanceMeters ?? double.infinity) <= maxDistanceMeters) {
      return closest;
    }
    return null;
  }

  @override
  Future<RadarPoint> getRadarById(String id) async {
    try {
      final response = await SupabaseService.client
          .from('radars')
          .select()
          .eq('id', id)
          .single();
      return RadarPoint.fromJson(response);
    } catch (_) {
      return await _fallback.getRadarById(id);
    }
  }

  @override
  Future<bool> confirmRadar(String id) async {
    try {
      final existing = await getRadarById(id);
      await SupabaseService.client.from('radars').update({
        'confirmed_count': existing.confirmedCount + 1,
        'last_confirmed': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return true;
    } catch (_) {
      return await _fallback.confirmRadar(id);
    }
  }

  Future<bool> addRadar(RadarPoint point) async {
    try {
      await SupabaseService.client.from('radars').insert(point.toSupabase());
      return true;
    } catch (_) {
      return false;
    }
  }
}
