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
        // Pure OpenStreetMap: 100% Free, open source, no watermarks, no API key required
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
      case MapStyle.darkNavigation:
        // ArcGIS Dark Gray Base: Free, high-contrast night navigation, no watermarks
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}';
      case MapStyle.satellite:
        // ArcGIS Satellite Imagery: Free high-resolution aerial imagery, no watermarks
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
    }
  }

  List<String> get subdomains {
    switch (this) {
      case MapStyle.osmStandard:
        return const [];
      case MapStyle.darkNavigation:
        return const [];
      case MapStyle.satellite:
        return const [];
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
