import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _keyLanguage = 'app_language';
  static const String _keyDarkMode = 'is_dark_mode';
  static const String _keyUnits = 'units_measurement';
  static const String _keyAlertDistance = 'alert_distance_meters';
  static const String _keyVoiceAlertsEnabled = 'voice_alerts_enabled';
  static const String _keySoundChimesEnabled = 'sound_chimes_enabled';
  static const String _keyOnboardingCompleted = 'onboarding_completed';
  static const String _keyUseMockData = 'use_mock_data';
  static const String _keyApiBaseUrl = 'api_base_url';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Language
  String getLanguage() => _prefs.getString(_keyLanguage) ?? 'uz';
  Future<void> setLanguage(String code) => _prefs.setString(_keyLanguage, code);

  // Theme
  bool isDarkMode() => _prefs.getBool(_keyDarkMode) ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool(_keyDarkMode, value);

  // Units
  String getUnits() => _prefs.getString(_keyUnits) ?? 'km/h';
  Future<void> setUnits(String unit) => _prefs.setString(_keyUnits, unit);

  // Alert Distance (meters: 300, 500, 1000)
  int getAlertDistance() => _prefs.getInt(_keyAlertDistance) ?? 500;
  Future<void> setAlertDistance(int meters) => _prefs.setInt(_keyAlertDistance, meters);

  // Audio Alerts
  bool areVoiceAlertsEnabled() => _prefs.getBool(_keyVoiceAlertsEnabled) ?? true;
  Future<void> setVoiceAlertsEnabled(bool val) => _prefs.setBool(_keyVoiceAlertsEnabled, val);

  bool areSoundChimesEnabled() => _prefs.getBool(_keySoundChimesEnabled) ?? true;
  Future<void> setSoundChimesEnabled(bool val) => _prefs.setBool(_keySoundChimesEnabled, val);

  // Onboarding
  bool isOnboardingCompleted() => _prefs.getBool(_keyOnboardingCompleted) ?? false;
  Future<void> setOnboardingCompleted(bool val) => _prefs.setBool(_keyOnboardingCompleted, val);

  // Dev / API Configuration
  bool getUseMockData() => _prefs.getBool(_keyUseMockData) ?? true;
  Future<void> setUseMockData(bool val) => _prefs.setBool(_keyUseMockData, val);

  String getApiBaseUrl() => _prefs.getString(_keyApiBaseUrl) ?? 'https://api.smartradar.io/v1';
  Future<void> setApiBaseUrl(String url) => _prefs.setString(_keyApiBaseUrl, url);
}
