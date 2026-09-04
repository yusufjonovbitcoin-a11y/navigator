import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:navigator/core/services/osm_geocoding_service.dart';

class YandexGeocodingService {
  static const String geocoderApiKey = 'c33eac17-3760-48ec-bb09-0eef0e09bf30';
  static const String suggestApiKey = 'df68caf9-f7eb-436e-8505-74dd342bba96';

  // Uzbekistan boundaries
  static const double minLat = 37.0;
  static const double maxLat = 45.8;
  static const double minLng = 55.9;
  static const double maxLng = 73.3;
  static const String uzbekistanBbox = '55.99,37.18~73.15,45.58';

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  final OsmGeocodingService _fallbackService = OsmGeocodingService();
  final Map<String, OsmPlace> _uriCache = {};

  Future<List<OsmPlace>> searchPlaces(
    String query, {
    double? userLat,
    double? userLng,
  }) async {
    if (query.trim().length < 2) return [];

    final centerLat = userLat ?? 41.2995;
    final centerLng = userLng ?? 69.2401;

    // 1. Primary: Yandex Geosuggest API (instant autocomplete, POI, business, streets, strictly Uzbekistan)
    try {
      final suggestResults = await _suggestPlaces(query, centerLat, centerLng);
      if (suggestResults.isNotEmpty) {
        // Pre-cache top 2 suggestions in background
        for (final item in suggestResults.take(2)) {
          if (item.uri != null && item.lat == 0.0) {
            resolveUri(item.uri!);
          }
        }
        return suggestResults;
      }
    } catch (e) {
      debugPrint('[YandexSuggest] API error: $e');
    }

    // 2. Secondary: Yandex Geocoder API (exact coordinates, addresses)
    try {
      final geocoderResults = await _searchWithGeocoder(query, centerLat, centerLng);
      if (geocoderResults.isNotEmpty) {
        return geocoderResults;
      }
    } catch (e) {
      debugPrint('[YandexGeocoding] Geocoder error: $e');
    }

    // 3. Fallback: OSM Nominatim (strictly Uzbekistan)
    return _fallbackService.searchPlaces(query);
  }

  Future<List<OsmPlace>> _suggestPlaces(String query, double centerLat, double centerLng) async {
    final response = await _dio.get(
      'https://suggest-maps.yandex.ru/v1/suggest',
      queryParameters: {
        'apikey': suggestApiKey,
        'text': query,
        'lang': 'ru_RU',
        'results': 10,
        'll': '$centerLng,$centerLat',
        'spn': '1.5,1.5',
        'attrs': 'uri',
        'bbox': uzbekistanBbox,
        'strict_bounds': 1,
        'types': 'biz,geo,transit',
      },
    );

    if (response.statusCode == 200 && response.data is Map) {
      final resultsJson = response.data['results'] as List?;
      if (resultsJson != null && resultsJson.isNotEmpty) {
        final list = <OsmPlace>[];
        for (final item in resultsJson) {
          if (item is! Map<String, dynamic>) continue;
          final title = item['title']?['text'] as String? ?? '';
          if (title.isEmpty) continue;

          final subtitle = item['subtitle']?['text'] as String? ?? '';
          final uri = item['uri'] as String?;
          final tags = item['tags'] as List?;
          final type = (tags != null && tags.isNotEmpty) ? tags.first.toString() : 'place';
          final displayName = subtitle.isNotEmpty ? '$title, $subtitle' : title;

          if (uri != null && _uriCache.containsKey(uri)) {
            list.add(_uriCache[uri]!);
          } else {
            list.add(
              OsmPlace(
                displayName: displayName,
                name: title,
                subtitle: subtitle.isNotEmpty ? subtitle : null,
                lat: 0.0,
                lng: 0.0,
                type: type,
                uri: uri,
              ),
            );
          }
        }
        return list;
      }
    }
    return [];
  }

  Future<List<OsmPlace>> _searchWithGeocoder(String query, double centerLat, double centerLng) async {
    final response = await _dio.get(
      'https://geocode-maps.yandex.ru/1.x/',
      queryParameters: {
        'apikey': geocoderApiKey,
        'geocode': query,
        'format': 'json',
        'results': 10,
        'lang': 'ru_RU',
        'll': '$centerLng,$centerLat',
        'spn': '1.5,1.5',
        'bbox': uzbekistanBbox,
        'rspn': 1,
      },
    );

    if (response.statusCode == 200 && response.data is Map) {
      final collection = response.data['response']?['GeoObjectCollection'];
      final members = collection?['featureMember'] as List?;
      if (members != null && members.isNotEmpty) {
        final results = <OsmPlace>[];
        for (final item in members) {
          final geo = item['GeoObject'] as Map<String, dynamic>?;
          if (geo == null) continue;

          final name = geo['name'] as String? ?? '';
          final description = geo['description'] as String? ?? '';
          final displayName = description.isNotEmpty ? '$name, $description' : name;

          final pos = geo['Point']?['pos'] as String? ?? '';
          final posParts = pos.split(' ');
          if (posParts.length >= 2) {
            final lng = double.tryParse(posParts[0]) ?? 0.0;
            final lat = double.tryParse(posParts[1]) ?? 0.0;

            final address = geo['metaDataProperty']?['GeocoderMetaData']?['Address'] as Map<String, dynamic>?;
            final countryCode = (address?['country_code'] as String?)?.toUpperCase();
            if (countryCode != null && countryCode.isNotEmpty && countryCode != 'UZ') {
              continue;
            }

            if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) {
              continue;
            }

            final kind = geo['metaDataProperty']?['GeocoderMetaData']?['kind'] as String? ?? 'place';

            results.add(
              OsmPlace(
                displayName: displayName,
                name: name.isNotEmpty ? name : displayName,
                subtitle: description.isNotEmpty ? description : null,
                lat: lat,
                lng: lng,
                type: kind,
              ),
            );
          }
        }
        return results;
      }
    }
    return [];
  }

  Future<OsmPlace?> resolveUri(String uri) async {
    if (_uriCache.containsKey(uri)) {
      return _uriCache[uri];
    }

    try {
      final response = await _dio.get(
        'https://geocode-maps.yandex.ru/1.x/',
        queryParameters: {
          'apikey': geocoderApiKey,
          'uri': uri,
          'format': 'json',
          'lang': 'ru_RU',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final collection = response.data['response']?['GeoObjectCollection'];
        final members = collection?['featureMember'] as List?;
        if (members != null && members.isNotEmpty) {
          final geo = members.first['GeoObject'] as Map<String, dynamic>?;
          if (geo != null) {
            final name = geo['name'] as String? ?? '';
            final description = geo['description'] as String? ?? '';
            final displayName = description.isNotEmpty ? '$name, $description' : name;

            final address = geo['metaDataProperty']?['GeocoderMetaData']?['Address'] as Map<String, dynamic>?;
            final countryCode = (address?['country_code'] as String?)?.toUpperCase();
            if (countryCode != null && countryCode.isNotEmpty && countryCode != 'UZ') {
              return null;
            }

            final pos = geo['Point']?['pos'] as String? ?? '';
            final posParts = pos.split(' ');
            if (posParts.length >= 2) {
              final lng = double.tryParse(posParts[0]) ?? 0.0;
              final lat = double.tryParse(posParts[1]) ?? 0.0;

              if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) {
                final place = OsmPlace(
                  displayName: displayName,
                  name: name.isNotEmpty ? name : displayName,
                  subtitle: description.isNotEmpty ? description : null,
                  lat: lat,
                  lng: lng,
                  type: geo['metaDataProperty']?['GeocoderMetaData']?['kind'] as String? ?? 'place',
                  uri: uri,
                );
                _uriCache[uri] = place;
                return place;
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[YandexGeocoding] resolveUri error: $e');
    }
    return null;
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    if (lat < minLat || lat > maxLat || lng < minLng || lng > maxLng) {
      return null;
    }

    try {
      final response = await _dio.get(
        'https://geocode-maps.yandex.ru/1.x/',
        queryParameters: {
          'apikey': geocoderApiKey,
          'geocode': '$lng,$lat',
          'format': 'json',
          'results': 1,
          'lang': 'ru_RU',
        },
      );

      if (response.statusCode == 200 && response.data is Map) {
        final collection = response.data['response']?['GeoObjectCollection'];
        final members = collection?['featureMember'] as List?;
        if (members != null && members.isNotEmpty) {
          final geo = members.first['GeoObject'];
          final address = geo?['metaDataProperty']?['GeocoderMetaData']?['Address'] as Map<String, dynamic>?;
          final countryCode = (address?['country_code'] as String?)?.toUpperCase();
          if (countryCode != null && countryCode.isNotEmpty && countryCode != 'UZ') {
            return null;
          }
          final text = geo?['metaDataProperty']?['GeocoderMetaData']?['text'] as String?;
          if (text != null && text.isNotEmpty) return text;
        }
      }
    } catch (e) {
      debugPrint('[YandexGeocoding] Reverse geocode error: $e');
    }

    return _fallbackService.reverseGeocode(lat, lng);
  }
}
