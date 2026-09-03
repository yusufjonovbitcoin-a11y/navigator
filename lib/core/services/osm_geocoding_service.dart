import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class OsmPlace {
  final String displayName;
  final String name;
  final double lat;
  final double lng;
  final String type;

  const OsmPlace({
    required this.displayName,
    required this.name,
    required this.lat,
    required this.lng,
    required this.type,
  });

  LatLng get latLng => LatLng(lat, lng);

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
          'limit': 6,
          'countrycodes': 'uz', // Uzbekistan first, or global
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = response.data as List;
        return list.map((item) => OsmPlace.fromJson(item as Map<String, dynamic>)).toList();
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
