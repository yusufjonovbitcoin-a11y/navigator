import 'package:navigator/core/localization/app_localizations.dart';

enum MapStyle {
  osmStandard,
  darkNavigation,
  satellite,
}

extension MapStyleExtension on MapStyle {
  String getLocalizedName(AppLocalizations tr) {
    switch (this) {
      case MapStyle.osmStandard:
        return tr.tr('osm_standard');
      case MapStyle.darkNavigation:
        return tr.tr('osm_dark');
      case MapStyle.satellite:
        return tr.tr('satellite');
    }
  }

  String get name {
    switch (this) {
      case MapStyle.osmStandard:
        return 'OSM Standard';
      case MapStyle.darkNavigation:
        return 'Dark Navigation HUD';
      case MapStyle.satellite:
        return 'Satellite';
    }
  }

  String get urlTemplate {
    switch (this) {
      case MapStyle.osmStandard:
        // Google Maps Standard Driving Tiles: Ultra fast CDN, zero watermarks, 99.99% uptime
        return 'https://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}';
      case MapStyle.darkNavigation:
        // ArcGIS Dark Gray Base: High-contrast night navigation
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.satellite:
        // Google Hybrid Satellite: High-resolution aerial imagery with street labels
        return 'https://mt{s}.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
    }
  }

  String? get fallbackUrl {
    switch (this) {
      case MapStyle.osmStandard:
        // OpenStreetMap multi-mirror fallback
        return 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyle.darkNavigation:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }

  List<String> get subdomains {
    switch (this) {
      case MapStyle.osmStandard:
        return const ['0', '1', '2', '3'];
      case MapStyle.darkNavigation:
        return const [];
      case MapStyle.satellite:
        return const ['0', '1', '2', '3'];
    }
  }

  int get maxNativeZoom {
    switch (this) {
      case MapStyle.osmStandard:
        return 19;
      case MapStyle.darkNavigation:
        return 16;
      case MapStyle.satellite:
        return 18;
    }
  }
}
