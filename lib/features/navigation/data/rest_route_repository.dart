import 'package:latlong2/latlong.dart';
import 'package:navigator/core/constants/api_endpoints.dart';
import 'package:navigator/core/network/api_client.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';
import 'package:navigator/features/navigation/domain/repositories/route_repository.dart';

class RestRouteRepository implements RouteRepository {
  final ApiClient _apiClient;

  RestRouteRepository(this._apiClient);

  @override
  Future<List<RouteInfo>> planRoutes({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final response = await _apiClient.post<List<RouteInfo>>(
      ApiEndpoints.planRoute,
      data: {
        'origin': {'lat': origin.latitude, 'lng': origin.longitude},
        'destination': {'lat': destination.latitude, 'lng': destination.longitude},
      },
      fromJson: (jsonList) {
        if (jsonList is List) {
          return jsonList
              .map((item) => RouteInfo.fromJson(item as Map<String, dynamic>))
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
  Future<RouteInfo> getAlternativeRoute({
    required String originalRouteId,
    required String hazardId,
  }) async {
    final endpoint = ApiEndpoints.reportRouteHazard.replaceAll('{id}', originalRouteId);
    final response = await _apiClient.post<RouteInfo>(
      endpoint,
      data: {'hazardId': hazardId},
      fromJson: (json) => RouteInfo.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to calculate alternative route');
  }
}
