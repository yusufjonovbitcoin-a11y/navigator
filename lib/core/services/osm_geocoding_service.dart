import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OsmPlace {
  final String displayName;
  final String name;
  final double lat;
  final double lng;
  final String type;
  final String? uri;
  final String? subtitle;

  const OsmPlace({
    required this.displayName,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
    this.uri,
    this.subtitle,
  });

  LatLng get latLng => LatLng(lat, lng);

  OsmPlace copyWith({
    String? displayName,
    String? name,
    double? lat,
    double? lng,
    String? type,
    String? uri,
    String? subtitle,
  }) {
    return OsmPlace(
      displayName: displayName ?? this.displayName,
      name: name ?? this.name,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      uri: uri ?? this.uri,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'] as String?;
    final displayName = json['display_name'] as String? ?? 'Unknown Location';
    final name = (rawName != null && rawName.isNotEmpty)
        ? rawName
        : displayName.split(',').first.trim();

    return OsmPlace(
      displayName: displayName,
      name: name,
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0.0,
      lng: double.tryParse(json['lon']?.toString() ?? '0') ?? 0.0,
      type: json['type'] as String? ?? 'place',
    );
  }
}

class OsmGeocodingService {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent': 'SmartRadarNavigator/1.0 (Flutter; OpenStreetMap Integration)',
      },
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<List<OsmPlace>> searchPlaces(String query) async {
    if (query.trim().length < 2) return [];

    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'q': query,
          'format': 'json',
          'addressdetails': 1,
          'limit': 8,
          'countrycodes': 'uz', // Uzbekistan only
          'viewbox': '55.99,45.58,73.15,37.18',
          'bounded': 1,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        final results = <OsmPlace>[];
        for (final item in list) {
          if (item is! Map<String, dynamic>) continue;
          final address = item['address'] as Map<String, dynamic>?;
          final countryCode = (address?['country_code'] as String?)?.toLowerCase();
          if (countryCode != null && countryCode.isNotEmpty && countryCode != 'uz') {
            continue;
          }
          final place = OsmPlace.fromJson(item);
          // Strict geographic bounds of Uzbekistan
          if (place.lat < 37.0 || place.lat > 45.8 || place.lng < 55.9 || place.lng > 73.3) {
            continue;
          }
          results.add(place);
        }
        return results;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': lat,
          'lon': lng,
          'format': 'json',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final map = response.data as Map<String, dynamic>;
        return map['display_name'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
