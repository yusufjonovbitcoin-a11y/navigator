import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigator/core/services/driving_behavior_service.dart';
import 'package:navigator/core/services/storage_service.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DrivingBehaviorService Tests', () {
    test('DrivingBehaviorState returns correct weekly summary in Uzbek', () async {
      const state = DrivingBehaviorState(
        safetyScore: 96.0,
        weeklyDistanceKm: 240.0,
        violationCount: 0,
        fuelSavedPercentage: 8.0,
      );

      final summary = state.getWeeklySummary('uz');
      expect(summary, contains('240 km'));
      expect(summary, contains('0 ta qoidabuzarlik'));
      expect(summary, contains('96/100'));
      expect(summary, contains('8%'));
    });

    test('DrivingBehaviorState returns correct weekly summary in Russian', () async {
      const state = DrivingBehaviorState(
        safetyScore: 96.0,
        weeklyDistanceKm: 240.0,
        violationCount: 0,
        fuelSavedPercentage: 8.0,
      );

      final summary = state.getWeeklySummary('ru');
      expect(summary, contains('240 км'));
      expect(summary, contains('0 нарушений'));
      expect(summary, contains('96/100'));
      expect(summary, contains('8%'));
    });

    test('DrivingBehaviorNotifier initializes with default 96 safety score and 240km distance', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      final state = container.read(drivingBehaviorProvider);
      expect(state.safetyScore, equals(96.0));
      expect(state.weeklyDistanceKm, equals(240.0));
      expect(state.violationCount, equals(0));
      expect(state.fuelSavedPercentage, equals(8.0));
    });
  });
}
