import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/core/network/api_client.dart';
import 'package:navigator/core/services/audio_alert_service.dart';
import 'package:navigator/core/services/location_service.dart';
import 'package:navigator/core/services/storage_service.dart';
import 'package:navigator/features/settings/domain/models/app_settings.dart';

// Storage service provider
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized in main');
});

// Audio service provider
final audioAlertServiceProvider = Provider<AudioAlertService>((ref) {
  final service = AudioAlertService();
  ref.onDispose(() => service.stop());
  return service;
});

// Location service provider
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

// User location stream
final userLocationStreamProvider = StreamProvider.autoDispose<UserLocation>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  locationService.startLocationTracking();
  return locationService.onLocationChanged;
});

// Api client provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return ApiClient(baseUrl: settings.apiBaseUrl);
});

// Settings StateNotifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(AppSettings.initial()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final langCode = _storage.getLanguage();
    final isDark = _storage.isDarkMode();
    final units = _storage.getUnits();
    final alertDist = _storage.getAlertDistance();
    final voiceEnabled = _storage.areVoiceAlertsEnabled();
    final chimesEnabled = _storage.areSoundChimesEnabled();
    final useMock = _storage.getUseMockData();
    final baseUrl = _storage.getApiBaseUrl();

    state = AppSettings(
      language: AppLanguage.fromCode(langCode),
      isDarkMode: isDark,
      units: units,
      alertDistanceMeters: alertDist,
      voiceAlertsEnabled: voiceEnabled,
      soundChimesEnabled: chimesEnabled,
      useMockData: useMock,
      apiBaseUrl: baseUrl,
    );
  }

  Future<void> setLanguage(AppLanguage lang) async {
    await _storage.setLanguage(lang.code);
    state = state.copyWith(language: lang);
  }

  Future<void> setDarkMode(bool isDark) async {
    await _storage.setDarkMode(isDark);
    state = state.copyWith(isDarkMode: isDark);
  }

  Future<void> setUnits(String units) async {
    await _storage.setUnits(units);
    state = state.copyWith(units: units);
  }

  Future<void> setAlertDistance(int meters) async {
    await _storage.setAlertDistance(meters);
    state = state.copyWith(alertDistanceMeters: meters);
  }

  Future<void> setVoiceAlerts(bool enabled) async {
    await _storage.setVoiceAlertsEnabled(enabled);
    state = state.copyWith(voiceAlertsEnabled: enabled);
  }

  Future<void> setSoundChimes(bool enabled) async {
    await _storage.setSoundChimesEnabled(enabled);
    state = state.copyWith(soundChimesEnabled: enabled);
  }

  Future<void> setUseMockData(bool useMock) async {
    await _storage.setUseMockData(useMock);
    state = state.copyWith(useMockData: useMock);
  }

  Future<void> setApiBaseUrl(String url) async {
    await _storage.setApiBaseUrl(url);
    state = state.copyWith(apiBaseUrl: url);
  }
}

final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SettingsNotifier(storage);
});

// Derived Locale
final currentLocaleProvider = Provider<Locale>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return Locale(settings.language.code);
});
