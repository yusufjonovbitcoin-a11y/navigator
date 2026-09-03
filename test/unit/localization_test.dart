import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/core/services/storage_service.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/features/settings/presentation/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AppLocalizations Tests', () {
    test('English translations return correct values', () {
      final loc = AppLocalizations(const Locale('en'));
      expect(loc.tr('app_name'), equals('Radar AI Navigator'));
      expect(loc.tr('stationary_camera'), equals('Stationary Camera'));
      expect(loc.tr('tab_home'), equals('Map'));
      expect(loc.tr('fastest_route'), equals('Fastest Route'));
      expect(loc.tr('live_community_feed'), equals('Live Community Feed'));
    });

    test('Russian translations return correct values', () {
      final loc = AppLocalizations(const Locale('ru'));
      expect(loc.tr('app_name'), equals('Радар ИИ Навигатор'));
      expect(loc.tr('stationary_camera'), equals('Стационарная Камера'));
      expect(loc.tr('tab_home'), equals('Карта'));
      expect(loc.tr('fastest_route'), equals('Самый Быстрый'));
      expect(loc.tr('live_community_feed'), equals('Лента сообщества'));
    });

    test('Uzbek translations return correct values', () {
      final loc = AppLocalizations(const Locale('uz'));
      expect(loc.tr('app_name'), equals('Radar AI Navigator'));
      expect(loc.tr('stationary_camera'), equals('Statsionar Kamera'));
      expect(loc.tr('tab_home'), equals('Karta'));
      expect(loc.tr('fastest_route'), equals('Eng Tez Yo\'l'));
      expect(loc.tr('live_community_feed'), equals('Jonli xabarlar tasmasi'));
    });

    testWidgets('MaterialApp with Uzbek Locale renders AppBar and Settings without MaterialLocalizations error', (tester) async {
      final storage = await StorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            locale: Locale('uz'),
            supportedLocales: [
              Locale('uz', ''),
              Locale('ru', ''),
              Locale('en', ''),
            ],
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Sozlamalar'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('MaterialApp with Russian Locale renders AppBar and Settings without error', (tester) async {
      final storage = await StorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            locale: Locale('ru'),
            supportedLocales: [
              Locale('uz', ''),
              Locale('ru', ''),
              Locale('en', ''),
            ],
            localizationsDelegates: [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Настройки'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
