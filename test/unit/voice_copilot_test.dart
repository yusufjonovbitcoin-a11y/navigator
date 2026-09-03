import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/core/services/storage_service.dart';
import 'package:navigator/core/services/voice_copilot_service.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('VoiceCopilotService Tests', () {
    test('Process Uzbek voice command "O\'ngda YPX turibdi" reports policePatrol', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      container.read(settingsNotifierProvider.notifier).setLanguage(AppLanguage.uz);
      final notifier = container.read(voiceCopilotProvider.notifier);
      final result = await notifier.processVoiceCommand('Hey Radar, o\'ngda YPX turibdi');

      expect(result.intent, equals(VoiceIntentType.reportHazard));
      expect(result.reportedType, equals(ReportType.policePatrol));
      expect(result.responseSpeech, contains('YPX'));
    });

    test('Process Uzbek command with "Navigator" wake-word reports policePatrol', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      container.read(settingsNotifierProvider.notifier).setLanguage(AppLanguage.uz);
      final notifier = container.read(voiceCopilotProvider.notifier);
      final result = await notifier.processVoiceCommand('Navigator, oldinda YPX patruli turibdi');

      expect(result.intent, equals(VoiceIntentType.reportHazard));
      expect(result.reportedType, equals(ReportType.policePatrol));
      expect(result.responseSpeech, contains('YPX'));
    });

    test('Process Russian voice command "Здесь глубокая яма" reports pothole', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      await container.read(settingsNotifierProvider.notifier).setLanguage(AppLanguage.ru);
      final notifier = container.read(voiceCopilotProvider.notifier);
      final result = await notifier.processVoiceCommand('Навигатор, здесь глубокая яма на дороге');

      expect(result.intent, equals(VoiceIntentType.reportHazard));
      expect(result.reportedType, equals(ReportType.pothole));
      expect(result.responseSpeech, contains('яма'));
    });

    test('Process voice command "Yo\'lda radarlar bormi?" queries radars', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      container.read(settingsNotifierProvider.notifier).setLanguage(AppLanguage.uz);
      final notifier = container.read(voiceCopilotProvider.notifier);
      final result = await notifier.processVoiceCommand('Navigator, yo\'lda qanday radarlar bor?');

      expect(result.intent, equals(VoiceIntentType.queryRadars));
      expect(result.responseSpeech, contains('kamera'));
    });

    test('Process voice command "Eng yaqin metan zapravka" queries gas station', () async {
      final storage = await StorageService.init();
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWithValue(storage),
        ],
      );

      container.read(settingsNotifierProvider.notifier).setLanguage(AppLanguage.uz);
      final notifier = container.read(voiceCopilotProvider.notifier);
      final result = await notifier.processVoiceCommand('Navigator, eng yaqin metan zapravkani ko\'rsat');

      expect(result.intent, equals(VoiceIntentType.queryGasStation));
      expect(result.responseSpeech, contains('metan'));
    });
  });
}
