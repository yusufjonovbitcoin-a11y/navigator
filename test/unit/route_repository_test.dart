import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/navigation/data/mock_route_repository.dart';

void main() {
  group('MockRouteRepository Tests', () {
    late MockRouteRepository routeRepo;

    setUp(() {
      routeRepo = MockRouteRepository();
    });

    test('planRoutes returns Fastest and Safest route options', () async {
      final routes = await routeRepo.planRoutes(
        origin: const LatLng(41.311081, 69.240562),
        destination: const LatLng(41.283000, 69.208000),
      );

      expect(routes.length, equals(2));
      final fastest = routes.firstWhere((r) => !r.isSafest);
      final safest = routes.firstWhere((r) => r.isSafest);

      expect(fastest.durationMinutes, lessThanOrEqualTo(safest.durationMinutes));
      expect(safest.radarCount, lessThan(fastest.radarCount));
      expect(safest.riskScore, lessThan(fastest.riskScore));
      expect(fastest.steps, isNotEmpty);
    });

    test('getAlternativeRoute returns safe diversion when hazard detected', () async {
      final alt = await routeRepo.getAlternativeRoute(
        originalRouteId: 'route-fastest',
        hazardId: 'patrol_detected',
      );

      expect(alt.id, contains('reroute'));
      expect(alt.isSafest, isTrue);
      expect(alt.steps, isNotEmpty);
    });
  });
}
