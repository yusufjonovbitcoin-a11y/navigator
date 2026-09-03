import 'package:latlong2/latlong.dart';
import '../models/route_info.dart';

abstract class RouteRepository {
  Future<List<RouteInfo>> planRoutes({
    required LatLng origin,
    required LatLng destination,
  });

  Future<RouteInfo> getAlternativeRoute({
    required String originalRouteId,
    required String hazardId,
  });
}
