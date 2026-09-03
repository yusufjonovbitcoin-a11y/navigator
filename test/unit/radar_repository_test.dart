import 'package:flutter_test/flutter_test.dart';
import 'package:navigator/features/map_radar/data/mock_radar_repository.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';

void main() {
  group('MockRadarRepository Tests', () {
    late MockRadarRepository repository;

    setUp(() {
      repository = MockRadarRepository();
    });

    test('getNearbyRadars returns radars within specified radius', () async {
      final radars = await repository.getNearbyRadars(
        lat: 41.311081,
        lng: 69.240562,
        radiusKm: 15.0,
      );

      expect(radars, isNotEmpty);
      expect(radars.first.distanceMeters, isNotNull);
      // Verify sorted by distance ascending
      for (int i = 0; i < radars.length - 1; i++) {
        expect(radars[i].distanceMeters! <= radars[i + 1].distanceMeters!, isTrue);
      }
    });

    test('getClosestRadar returns nearest radar', () async {
      final nearest = await repository.getClosestRadar(
        lat: 41.311081,
        lng: 69.240562,
        maxDistanceMeters: 5000.0,
      );

      expect(nearest, isNotNull);
      expect(nearest!.type, anyOf(RadarType.stationary, RadarType.mobile, RadarType.speedTrap, RadarType.redLight));
    });

    test('confirmRadar increments confirmation count', () async {
      final radar = await repository.getRadarById('radar-001');
      final initialCount = radar.confirmedCount;

      final success = await repository.confirmRadar('radar-001');
      expect(success, isTrue);

      final updated = await repository.getRadarById('radar-001');
      expect(updated.confirmedCount, equals(initialCount + 1));
    });
  });
}
