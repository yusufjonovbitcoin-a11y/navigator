import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';
import 'package:navigator/core/localization/app_localizations.dart';

enum ReportType {
  stationaryRadar,
  policePatrol,
  accident,
  roadwork,
  trafficJam,
  pothole,
}

extension ReportTypeExtension on ReportType {
  String getLocalizedTitle(AppLocalizations tr) {
    switch (this) {
      case ReportType.stationaryRadar:
        return tr.tr('stationary_camera');
      case ReportType.policePatrol:
        return tr.tr('mobile_patrol');
      case ReportType.accident:
        return tr.tr('accident');
      case ReportType.roadwork:
        return tr.tr('roadwork');
      case ReportType.trafficJam:
        return tr.tr('traffic_jam');
      case ReportType.pothole:
        return tr.tr('pothole');
    }
  }

  String get title {
    switch (this) {
      case ReportType.stationaryRadar:
        return 'Multi Radar';
      case ReportType.policePatrol:
        return 'Police Radar (GAY)';
      case ReportType.accident:
        return 'Car Accident';
      case ReportType.roadwork:
        return 'Road Works';
      case ReportType.trafficJam:
        return 'Traffic Jam';
      case ReportType.pothole:
        return 'Road Hazard / Pothole';
    }
  }

  Duration get defaultLifespan {
    switch (this) {
      case ReportType.policePatrol:
        return const Duration(minutes: 45);
      case ReportType.accident:
        return const Duration(minutes: 60);
      case ReportType.trafficJam:
        return const Duration(minutes: 45);
      case ReportType.pothole:
        return const Duration(days: 7);
      case ReportType.roadwork:
        return const Duration(days: 14);
      case ReportType.stationaryRadar:
        return const Duration(days: 30);
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.stationaryRadar:
        return Icons.radar_rounded;
      case ReportType.policePatrol:
        return Icons.local_police_rounded;
      case ReportType.accident:
        return Icons.car_crash_rounded;
      case ReportType.roadwork:
        return Icons.construction_rounded;
      case ReportType.trafficJam:
        return Icons.traffic_rounded;
      case ReportType.pothole:
        return Icons.warning_amber_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.stationaryRadar:
        return const Color(0xFFFF3366);
      case ReportType.policePatrol:
        return const Color(0xFF3B82F6);
      case ReportType.accident:
        return const Color(0xFFEF4444);
      case ReportType.roadwork:
        return const Color(0xFFF59E0B);
      case ReportType.trafficJam:
        return const Color(0xFFFB8500);
      case ReportType.pothole:
        return const Color(0xFFA855F7);
    }
  }

  RadarType toRadarType() {
    switch (this) {
      case ReportType.stationaryRadar:
        return RadarType.stationary;
      case ReportType.policePatrol:
        return RadarType.mobile;
      case ReportType.accident:
      case ReportType.roadwork:
      case ReportType.trafficJam:
      case ReportType.pothole:
        return RadarType.hazard;
    }
  }
}

class UserReport {
  final String id;
  final ReportType type;
  final double lat;
  final double lng;
  final DateTime timestamp;
  final String userId;
  final String? address;
  final String? note;
  final int upvotes;
  final int downvotes;
  final int authorTrustLevel; // 1 to 5 (Level 5 = Instant Live on Map)
  final String status; // 'active', 'verified', 'expired'
  final DateTime expiresAt;

  UserReport({
    required this.id,
    required this.type,
    required this.lat,
    required this.lng,
    required this.timestamp,
    required this.userId,
    this.address,
    this.note,
    this.upvotes = 1,
    this.downvotes = 0,
    this.authorTrustLevel = 5,
    this.status = 'active',
    DateTime? expiresAt,
  }) : expiresAt = expiresAt ?? timestamp.add(type.defaultLifespan);

  LatLng get latLng => LatLng(lat, lng);

  /// Whether the report is expired or voted down as false
  bool get isExpired =>
      DateTime.now().isAfter(expiresAt) || (downvotes >= 2 && downvotes > upvotes);

  /// Live on map as long as it has not expired and has not been downvoted
  bool get isVisibleOnMap => !isExpired;

  UserReport copyWith({
    String? id,
    ReportType? type,
    double? lat,
    double? lng,
    DateTime? timestamp,
    String? userId,
    String? address,
    String? note,
    int? upvotes,
    int? downvotes,
    int? authorTrustLevel,
    String? status,
    DateTime? expiresAt,
  }) {
    return UserReport(
      id: id ?? this.id,
      type: type ?? this.type,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
      address: address ?? this.address,
      note: note ?? this.note,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      authorTrustLevel: authorTrustLevel ?? this.authorTrustLevel,
      status: status ?? this.status,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  factory UserReport.fromJson(Map<String, dynamic> json) {
    final type = ReportType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => ReportType.stationaryRadar,
    );
    final rawDate = json['created_at']?.toString() ?? json['timestamp']?.toString() ?? '';
    final parsed = DateTime.tryParse(rawDate);
    final timestamp = parsed != null ? parsed.toLocal() : DateTime.now();

    return UserReport(
      id: json['id'] as String,
      type: type,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      timestamp: timestamp,
      userId: json['author_id'] as String? ?? json['userId'] as String? ?? 'user_1',
      address: json['address'] as String?,
      note: json['note'] as String?,
      upvotes: json['upvotes'] as int? ?? 1,
      downvotes: json['downvotes'] as int? ?? 0,
      authorTrustLevel: json['author_karma'] != null
          ? ((json['author_karma'] as int) >= 1500 ? 5 : 3)
          : (json['authorTrustLevel'] as int? ?? 5),
      status: json['status'] as String? ?? 'active',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())?.toLocal() ?? timestamp.add(type.defaultLifespan)
          : timestamp.add(type.defaultLifespan),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'lat': lat,
      'lng': lng,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'address': address,
      'note': note,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'authorTrustLevel': authorTrustLevel,
      'status': status,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabase() {
    return {
      'id': id,
      'type': type.name,
      'lat': lat,
      'lng': lng,
      'note': note ?? '',
      'upvotes': upvotes,
      'downvotes': downvotes,
      'author_id': userId,
      'author_karma': authorTrustLevel * 300,
      'created_at': timestamp.toUtc().toIso8601String(),
    };
  }
}
