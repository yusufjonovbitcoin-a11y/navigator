import 'package:latlong2/latlong.dart';

class ParkingZone {
  final String id;
  final String name;
  final List<LatLng> points;
  final bool isPaid;
  final String priceInfo;
  final int capacity;
  final int availableSpots;
  final DateTime createdAt;
  final int colorValue;

  const ParkingZone({
    required this.id,
    required this.name,
    required this.points,
    this.isPaid = false,
    this.priceInfo = 'Bepul',
    this.capacity = 20,
    this.availableSpots = 15,
    required this.createdAt,
    this.colorValue = 0xFF007AFF,
  });

  /// Calculates the approximate center point of the polygon to place the 🅿️ icon marker
  LatLng get centerPoint {
    if (points.isEmpty) return const LatLng(41.311081, 69.240562);
    double sumLat = 0;
    double sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'isPaid': isPaid,
      'priceInfo': priceInfo,
      'capacity': capacity,
      'availableSpots': availableSpots,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => {'latitude': p.latitude, 'longitude': p.longitude}).toList(),
      'is_paid': isPaid,
      'price_info': priceInfo,
      'capacity': capacity,
      'available_spots': availableSpots,
      'color_value': colorValue,
    };
  }

  factory ParkingZone.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List<dynamic>?)?.map((p) {
          final lat = (p['latitude'] ?? p['lat'] as num?)?.toDouble() ?? 0.0;
          final lng = (p['longitude'] ?? p['lng'] as num?)?.toDouble() ?? 0.0;
          return LatLng(lat, lng);
        }).toList() ??
        [];

    return ParkingZone(
      id: json['id'] as String,
      name: json['name'] as String,
      points: pointsList,
      isPaid: json['is_paid'] as bool? ?? json['isPaid'] as bool? ?? false,
      priceInfo: json['price_info'] as String? ?? json['priceInfo'] as String? ?? 'Bepul',
      capacity: json['capacity'] as int? ?? 20,
      availableSpots: json['available_spots'] as int? ?? json['availableSpots'] as int? ?? 15,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      colorValue: (json['color_value'] ?? json['colorValue'] as num?)?.toInt() ?? 0xFF007AFF,
    );
  }
}
