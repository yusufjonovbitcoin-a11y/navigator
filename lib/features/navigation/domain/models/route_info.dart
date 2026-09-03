import 'package:latlong2/latlong.dart';
import 'package:navigator/features/ai_agent/domain/models/risk_zone.dart';
import 'package:navigator/features/navigation/domain/models/navigation_step.dart';

class RouteInfo {
  final String id;
  final String name; // e.g. "via Bunyodkor Ave" or "via Little Ring Road"
  final List<LatLng> points;
  final double distanceKm;
  final int durationMinutes;
  final int radarCount;
  final int riskScore; // 0 (safest) to 100 (high risk)
  final bool isSafest;
  final String summary;
  final List<NavigationStep> steps;
  final List<RiskZone> riskZones;

  const RouteInfo({
    required this.id,
    required this.name,
    required this.points,
    required this.distanceKm,
    required this.durationMinutes,
    required this.radarCount,
    required this.riskScore,
    this.isSafest = false,
    required this.summary,
    this.steps = const [],
    this.riskZones = const [],
  });

  factory RouteInfo.fromJson(Map<String, dynamic> json) {
    final rawPoints = json['points'] as List<dynamic>? ?? [];
    final points = rawPoints.map((p) {
      if (p is List && p.length >= 2) {
        return LatLng((p[0] as num).toDouble(), (p[1] as num).toDouble());
      } else if (p is Map) {
        return LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble());
      }
      return const LatLng(0, 0);
    }).toList();

    final rawSteps = json['steps'] as List<dynamic>? ?? [];
    final steps = rawSteps
        .map((s) => NavigationStep.fromJson(s as Map<String, dynamic>))
        .toList();

    final rawRiskZones = json['riskZones'] as List<dynamic>? ?? [];
    final riskZones = rawRiskZones
        .map((r) => RiskZone.fromJson(r as Map<String, dynamic>))
        .toList();

    return RouteInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Standard Route',
      points: points,
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['durationMinutes'] as int? ?? 0,
      radarCount: json['radarCount'] as int? ?? 0,
      riskScore: json['riskScore'] as int? ?? 50,
      isSafest: json['isSafest'] as bool? ?? false,
      summary: json['summary'] as String? ?? '',
      steps: steps,
      riskZones: riskZones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points.map((p) => [p.latitude, p.longitude]).toList(),
      'distanceKm': distanceKm,
      'durationMinutes': durationMinutes,
      'radarCount': radarCount,
      'riskScore': riskScore,
      'isSafest': isSafest,
      'summary': summary,
      'steps': steps.map((s) => s.toJson()).toList(),
      'riskZones': riskZones.map((r) => r.toJson()).toList(),
    };
  }
}
