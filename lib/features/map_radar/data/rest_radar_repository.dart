import 'package:navigator/core/constants/api_endpoints.dart';
import 'package:navigator/core/network/api_client.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/features/map_radar/domain/repositories/radar_repository.dart';

class RestRadarRepository implements RadarRepository {
  final ApiClient _apiClient;

  RestRadarRepository(this._apiClient);

  @override
  Future<List<RadarPoint>> getNearbyRadars({
    required double lat,
    required double lng,
    double radiusKm = 15.0,
  }) async {
    final response = await _apiClient.get<List<RadarPoint>>(
      ApiEndpoints.getRadarsInBounds,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius_km': radiusKm,
      },
      fromJson: (jsonList) {
        if (jsonList is List) {
          return jsonList
              .map((item) => RadarPoint.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
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
    final endpoint = ApiEndpoints.getRadarDetails.replaceAll('{id}', id);
    final response = await _apiClient.get<RadarPoint>(
      endpoint,
      fromJson: (json) => RadarPoint.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to load radar details');
  }

  @override
  Future<bool> confirmRadar(String id) async {
    final response = await _apiClient.post(
      '${ApiEndpoints.getRadars}/$id/confirm',
    );
    return response.success;
  }
}
