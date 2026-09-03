import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/map_radar/domain/models/parking_zone.dart';
import 'package:navigator/features/map_radar/presentation/providers/parking_zone_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ParkingZone & Drawing Engine Tests', () {
    test('ParkingZone centerPoint calculates average polygon coordinates correctly', () {
      final zone = ParkingZone(
        id: 'test_1',
        name: 'Test Parking',
        points: const [
          LatLng(40.0, 60.0),
          LatLng(40.0, 70.0),
          LatLng(50.0, 70.0),
          LatLng(50.0, 60.0),
        ],
        createdAt: DateTime(2026, 1, 1),
      );

      final center = zone.centerPoint;
      expect(center.latitude, closeTo(45.0, 0.001));
      expect(center.longitude, closeTo(65.0, 0.001));
    });

    test('ParkingZone serializes and deserializes to JSON correctly', () {
      final zone = ParkingZone(
        id: 'park_123',
        name: 'Chilonzor Parking',
        isPaid: true,
        priceInfo: '6,000 so\'m/soat',
        capacity: 50,
        availableSpots: 20,
        points: const [
          LatLng(41.2840, 69.2065),
          LatLng(41.2852, 69.2085),
          LatLng(41.2841, 69.2098),
          LatLng(41.2830, 69.2078),
        ],
        createdAt: DateTime(2026, 9, 1),
        colorValue: 0xFF007AFF,
      );

      final json = zone.toJson();
      final reconstructed = ParkingZone.fromJson(json);

      expect(reconstructed.id, equals(zone.id));
      expect(reconstructed.name, equals(zone.name));
      expect(reconstructed.isPaid, equals(true));
      expect(reconstructed.capacity, equals(50));
      expect(reconstructed.points.length, equals(4));
    });

    test('ParkingZoneNotifier manages drawing draft points and saves custom polygon', () {
      final notifier = ParkingZoneNotifier();

      // Initial state has sample zones
      expect(notifier.state.savedZones.isNotEmpty, isTrue);
      expect(notifier.state.isDrawingMode, isFalse);

      // Toggle drawing mode
      notifier.toggleDrawingMode();
      expect(notifier.state.isDrawingMode, isTrue);
      expect(notifier.state.draftPoints.isEmpty, isTrue);

      // Add 4 polygon corners
      notifier.addDraftPoint(const LatLng(41.311, 69.240));
      notifier.addDraftPoint(const LatLng(41.312, 69.242));
      notifier.addDraftPoint(const LatLng(41.310, 69.243));
      notifier.addDraftPoint(const LatLng(41.309, 69.241));
      expect(notifier.state.draftPoints.length, equals(4));

      // Test Undo
      notifier.undoLastPoint();
      expect(notifier.state.draftPoints.length, equals(3));

      // Save Zone
      final saved = notifier.saveCurrentZone(
        name: 'Amir Temur Maydoni Parkovkasi',
        isPaid: false,
        priceInfo: 'Bepul',
        capacity: 40,
      );

      expect(saved, isTrue);
      expect(notifier.state.isDrawingMode, isFalse);
      expect(notifier.state.draftPoints.isEmpty, isTrue);
      expect(notifier.state.savedZones.first.name, equals('Amir Temur Maydoni Parkovkasi'));
      expect(notifier.state.savedZones.first.points.length, equals(3));
    });

    test('ParkingZoneNotifier rejects saving when points are less than 3', () {
      final notifier = ParkingZoneNotifier();
      notifier.toggleDrawingMode();
      notifier.addDraftPoint(const LatLng(41.311, 69.240));
      notifier.addDraftPoint(const LatLng(41.312, 69.242));

      final saved = notifier.saveCurrentZone(
        name: 'Invalid Zone',
        isPaid: true,
        priceInfo: '5,000 so\'m',
        capacity: 10,
      );

      expect(saved, isFalse);
    });

    test('ParkingZoneNotifier deletes saved zone by ID', () {
      final notifier = ParkingZoneNotifier();
      final initialCount = notifier.state.savedZones.length;
      final targetId = notifier.state.savedZones.first.id;

      notifier.deleteZone(targetId);
      expect(notifier.state.savedZones.length, equals(initialCount - 1));
      expect(notifier.state.savedZones.any((z) => z.id == targetId), isFalse);
    });
  });
}
