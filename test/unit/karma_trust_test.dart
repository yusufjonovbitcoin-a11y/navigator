import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigator/core/services/storage_service.dart';
import 'package:navigator/features/profile/domain/models/user_profile.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Karma & Driver Trust System Tests', () {
    test('UserProfile computes correct Driver Level based on Karma', () {
      final userLevel5 = UserProfile.defaultUser();
      expect(userLevel5.driverLevel, equals(5));
      expect(userLevel5.isLevel5, isTrue);

      final userLevel2 = userLevel5.copyWith(karmaPoints: 150);
      expect(userLevel2.driverLevel, equals(2));
      expect(userLevel2.isLevel5, isFalse);
    });

    test('Report by Level 5 driver is immediately visible on map', () {
      final level5Report = UserReport(
        id: 'rep-test-1',
        type: ReportType.policePatrol,
        lat: 41.3,
        lng: 69.2,
        timestamp: DateTime.now(),
        userId: 'usr_me',
        authorTrustLevel: 5,
      );

      expect(level5Report.isVisibleOnMap, isTrue);
      expect(level5Report.isExpired, isFalse);
    });

    test('Report with downvotes >= 2 is marked as expired and removed', () {
      final falseReport = UserReport(
        id: 'rep-test-2',
        type: ReportType.policePatrol,
        lat: 41.3,
        lng: 69.2,
        timestamp: DateTime.now(),
        userId: 'usr_stranger',
        authorTrustLevel: 2,
        upvotes: 1,
        downvotes: 3,
      );

      expect(falseReport.isExpired, isTrue);
      expect(falseReport.isVisibleOnMap, isFalse);
    });

    test('Submitting a report awards Karma bonus to the driver', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      final initialKarma = container.read(userKarmaProvider);
      final notifier = container.read(reportListProvider.notifier);

      final success = await notifier.submitReport(
        type: ReportType.policePatrol,
        lat: 41.31,
        lng: 69.24,
        note: 'Test YPX radar',
      );

      expect(success, isTrue);
      final newKarma = container.read(userKarmaProvider);
      expect(newKarma, equals(initialKarma + 15)); // +15 for Level 5
    });

    test('Upvoting a report awards +5 Karma', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      final initialKarma = container.read(userKarmaProvider);
      final notifier = container.read(reportListProvider.notifier);

      await notifier.upvote('rep-01');
      final newKarma = container.read(userKarmaProvider);
      expect(newKarma, equals(initialKarma + 5));
    });
  });
}
