import 'package:latlong2/latlong.dart';

enum RadarType {
  stationary, // Fixed roadside speed camera
  mobile,     // Mobile police radar patrol (GAY)
  speedTrap,  // Average speed measurement / section control
  redLight,   // Traffic light & line stop violation camera
  hazard,     // General road hazard
}

extension RadarTypeExtension on RadarType {
  String get displayName {
    switch (this) {
      case RadarType.stationary:
        return 'Kamera';
      case RadarType.mobile:
        return 'Radar';
      case RadarType.speedTrap:
        return 'Radar';
      case RadarType.redLight:
        return 'Kamera (Svetofor)';
      case RadarType.hazard:
        return 'Xavfli joy';
    }
  }

  String get localizedKey {
    switch (this) {
      case RadarType.stationary:
        return 'stationary_camera';
      case RadarType.mobile:
        return 'mobile_patrol';
      case RadarType.speedTrap:
        return 'speed_trap';
      case RadarType.redLight:
        return 'red_light_camera';
      case RadarType.hazard:
        return 'pothole';
    }
  }
}

class RadarPoint {
  final String id;
  final double lat;
  final double lng;
  final RadarType type;
  final int speedLimit; // e.g. 70 km/h, 60 km/h, 100 km/h
  final int confirmedCount;
  final DateTime lastConfirmed;
  final String title;
  final String? address;
  final double? distanceMeters;
  final List<String> features;

  const RadarPoint({
    required this.id,
    required this.lat,
    required this.lng,
    required this.type,
    required this.speedLimit,
    required this.confirmedCount,
    required this.lastConfirmed,
    required this.title,
    this.address,
    this.distanceMeters,
    this.features = const [],
  });

  LatLng get latLng => LatLng(lat, lng);

  RadarPoint copyWith({
    String? id,
    double? lat,
    double? lng,
    RadarType? type,
    int? speedLimit,
    int? confirmedCount,
    DateTime? lastConfirmed,
    String? title,
    String? address,
    double? distanceMeters,
    List<String>? features,
  }) {
    return RadarPoint(
      id: id ?? this.id,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      type: type ?? this.type,
      speedLimit: speedLimit ?? this.speedLimit,
      confirmedCount: confirmedCount ?? this.confirmedCount,
      lastConfirmed: lastConfirmed ?? this.lastConfirmed,
      title: title ?? this.title,
      address: address ?? this.address,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      features: features ?? this.features,
    );
  }

  factory RadarPoint.fromJson(Map<String, dynamic> json) {
    return RadarPoint(
      id: json['id'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      type: RadarType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RadarType.stationary,
      ),
      speedLimit: json['speed_limit'] as int? ?? json['speedLimit'] as int? ?? 60,
      confirmedCount: json['confirmed_count'] as int? ?? json['confirmedCount'] as int? ?? 1,
      lastConfirmed: DateTime.tryParse(json['last_confirmed']?.toString() ?? json['lastConfirmed']?.toString() ?? '') ?? DateTime.now(),
      title: json['title'] as String? ?? 'Speed Camera',
      address: json['address'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble(),
      features: (json['features'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lat': lat,
      'lng': lng,
      'type': type.name,
      'speedLimit': speedLimit,
      'confirmedCount': confirmedCount,
      'lastConfirmed': lastConfirmed.toIso8601String(),
      'title': title,
      'address': address,
      'distanceMeters': distanceMeters,
      'features': features,
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'title': title,
      'address': address ?? '',
      'lat': lat,
      'lng': lng,
      'type': type.name,
      'speed_limit': speedLimit,
      'confirmed_count': confirmedCount,
      'last_confirmed': lastConfirmed.toIso8601String(),
    };
  }
}
