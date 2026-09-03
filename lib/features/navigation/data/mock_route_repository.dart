import 'package:latlong2/latlong.dart';
import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/core/services/osrm_routing_service.dart';
import 'package:navigator/features/navigation/domain/models/navigation_step.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';
import 'package:navigator/features/navigation/domain/repositories/route_repository.dart';

class MockRouteRepository implements RouteRepository {
  final OsrmRoutingService _osrmService = OsrmRoutingService();

  @override
  Future<List<RouteInfo>> planRoutes({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // 1. Try real OpenStreetMap OSRM driving engine
    try {
      final realOsmRoutes = await _osrmService.calculateRealOsmRoutes(
        origin: origin,
        destination: destination,
      );
      if (realOsmRoutes.isNotEmpty) {
        return realOsmRoutes;
      }
    } catch (_) {}

    // 2. Dynamic fallback routes between origin and destination
    await Future.delayed(const Duration(milliseconds: 200));

    final distMeters = LocationService.calculateDistance(
      origin.latitude,
      origin.longitude,
      destination.latitude,
      destination.longitude,
    );
    final distKm = (distMeters / 1000.0).clamp(0.5, 500.0);
    final durationFastest = (distKm / 50.0 * 60).round().clamp(2, 600);
    final durationSafest = (distKm / 40.0 * 60).round().clamp(3, 750);

    final pointsFastest = [
      origin,
      LatLng(
        origin.latitude * 0.67 + destination.latitude * 0.33,
        origin.longitude * 0.67 + destination.longitude * 0.33,
      ),
      LatLng(
        origin.latitude * 0.33 + destination.latitude * 0.67,
        origin.longitude * 0.33 + destination.longitude * 0.67,
      ),
      destination,
    ];

    final pointsSafest = [
      origin,
      LatLng(
        origin.latitude * 0.67 + destination.latitude * 0.33 + 0.002,
        origin.longitude * 0.67 + destination.longitude * 0.33 - 0.002,
      ),
      LatLng(
        origin.latitude * 0.33 + destination.latitude * 0.67 + 0.002,
        origin.longitude * 0.33 + destination.longitude * 0.67 - 0.002,
      ),
      destination,
    ];

    final fastest = RouteInfo(
      id: 'route-fastest',
      name: 'Eng tezkor yo\'nalish',
      points: pointsFastest,
      distanceKm: double.parse(distKm.toStringAsFixed(1)),
      durationMinutes: durationFastest,
      radarCount: 2,
      riskScore: 55,
      isSafest: false,
      summary: 'Optimal vaqt bo\'yicha to\'g\'ri yo\'nalish',
      steps: [
        NavigationStep(
          instruction: 'Harakatni boshlang',
          distanceMeters: distMeters * 0.5,
          maneuver: ManeuverType.straight,
          streetName: 'Asosiy yo\'l',
        ),
        NavigationStep(
          instruction: 'To\'g\'riga davom eting',
          distanceMeters: distMeters * 0.4,
          maneuver: ManeuverType.straight,
          streetName: 'Markaziy ko\'cha',
        ),
        NavigationStep(
          instruction: 'Manzilga yetib keldingiz',
          distanceMeters: 0.0,
          maneuver: ManeuverType.arrive,
          streetName: 'Manzil',
        ),
      ],
      riskZones: const [],
    );

    final safest = RouteInfo(
      id: 'route-safest',
      name: 'Xavfsiz yo\'nalish',
      points: pointsSafest,
      distanceKm: double.parse((distKm * 1.1).toStringAsFixed(1)),
      durationMinutes: durationSafest,
      radarCount: 0,
      riskScore: 15,
      isSafest: true,
      summary: 'Kameralarsiz va tirbandliksiz xavfsiz yo\'nalish',
      steps: [
        NavigationStep(
          instruction: 'Harakatni boshlang',
          distanceMeters: distMeters * 0.6,
          maneuver: ManeuverType.straight,
          streetName: 'Aylanma yo\'l',
        ),
        NavigationStep(
          instruction: 'Manzilga yetib keldingiz',
          distanceMeters: 0.0,
          maneuver: ManeuverType.arrive,
          streetName: 'Manzil',
        ),
      ],
      riskZones: const [],
    );

    return [fastest, safest];
  }

  @override
  Future<RouteInfo> getAlternativeRoute({
    required String originalRouteId,
    required String hazardId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    return RouteInfo(
      id: 'route-reroute-dynamic',
      name: 'Dynamic Re-route (Bypassing Hazard)',
      points: const [
        LatLng(41.311081, 69.240562),
        LatLng(41.308000, 69.248000),
        LatLng(41.299000, 69.239000),
        LatLng(41.289000, 69.225000),
        LatLng(41.283000, 69.208000),
      ],
      distanceKm: 8.1,
      durationMinutes: 13,
      radarCount: 1,
      riskScore: 22,
      isSafest: true,
      summary: 'Avoided police checkpoint on Bunyodkor Ave. Saved 4 minutes!',
      steps: const [
        NavigationStep(
          instruction: 'Turn left onto Shakhrisabz St to bypass radar',
          distanceMeters: 500,
          maneuver: ManeuverType.turnLeft,
          streetName: 'Shakhrisabz St',
        ),
        NavigationStep(
          instruction: 'Follow south-west ring road toward Chilonzor',
          distanceMeters: 3200,
          maneuver: ManeuverType.straight,
          streetName: 'Shota Rustaveli St',
        ),
      ],
    );
  }
}
