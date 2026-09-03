import 'package:navigator/core/constants/api_endpoints.dart';
import 'package:navigator/core/localization/app_localizations.dart';

class AppSettings {
  final AppLanguage language;
  final bool isDarkMode;
  final String units; // 'km/h' or 'mph'
  final int alertDistanceMeters; // 300, 500, 1000
  final bool voiceAlertsEnabled;
  final bool soundChimesEnabled;
  final bool useMockData;
  final String apiBaseUrl;

  const AppSettings({
    required this.language,
    required this.isDarkMode,
    required this.units,
    required this.alertDistanceMeters,
    required this.voiceAlertsEnabled,
    required this.soundChimesEnabled,
    required this.useMockData,
    required this.apiBaseUrl,
  });

  factory AppSettings.initial() {
    return const AppSettings(
      language: AppLanguage.uz,
      isDarkMode: false,
      units: 'km/h',
      alertDistanceMeters: 500,
      voiceAlertsEnabled: true,
      soundChimesEnabled: true,
      useMockData: true,
      apiBaseUrl: ApiEndpoints.defaultBaseUrl,
    );
  }

  AppSettings copyWith({
    AppLanguage? language,
    bool? isDarkMode,
    String? units,
    int? alertDistanceMeters,
    bool? voiceAlertsEnabled,
    bool? soundChimesEnabled,
    bool? useMockData,
    String? apiBaseUrl,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      units: units ?? this.units,
      alertDistanceMeters: alertDistanceMeters ?? this.alertDistanceMeters,
      voiceAlertsEnabled: voiceAlertsEnabled ?? this.voiceAlertsEnabled,
      soundChimesEnabled: soundChimesEnabled ?? this.soundChimesEnabled,
      useMockData: useMockData ?? this.useMockData,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }
}
