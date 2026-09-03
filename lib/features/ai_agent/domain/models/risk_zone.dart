import 'package:latlong2/latlong.dart';

enum RiskLevel {
  low,
  moderate,
  high,
  extreme,
}

class RiskZone {
  final String id;
  final String name;
  final double lat;
  final double lng;
  final double radiusMeters;
  final RiskLevel riskLevel;
  final String reason;
  final int cameraCount;

  const RiskZone({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.riskLevel,
    required this.reason,
    required this.cameraCount,
  });

  LatLng get latLng => LatLng(lat, lng);

  factory RiskZone.fromJson(Map<String, dynamic> json) {
    return RiskZone(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Risk Zone',
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 300.0,
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == json['riskLevel'],
        orElse: () => RiskLevel.moderate,
      ),
      reason: json['reason'] as String? ?? 'High radar density & blind turns',
      cameraCount: json['cameraCount'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lat': lat,
      'lng': lng,
      'radiusMeters': radiusMeters,
      'riskLevel': riskLevel.name,
      'reason': reason,
      'cameraCount': cameraCount,
    };
  }
}
