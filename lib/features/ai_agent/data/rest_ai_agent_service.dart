import 'package:navigator/core/constants/api_endpoints.dart';
import 'package:navigator/core/network/api_client.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/domain/models/driving_insights.dart';
import 'package:navigator/features/ai_agent/domain/models/risk_zone.dart';
import 'package:navigator/features/ai_agent/domain/services/ai_agent_service.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';

class RestAiAgentService implements AiAgentService {
  final ApiClient _apiClient;

  RestAiAgentService(this._apiClient);

  @override
  Future<AiResponse> sendMessage(String message) async {
    final response = await _apiClient.post<AiResponse>(
      ApiEndpoints.aiChat,
      data: {'message': message},
      fromJson: (json) => AiResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'AI Assistant error');
  }

  @override
  Future<DrivingInsights> getWeeklyInsights() async {
    final response = await _apiClient.get<DrivingInsights>(
      ApiEndpoints.aiDrivingInsights,
      fromJson: (json) => DrivingInsights.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    throw Exception(response.message ?? 'Failed to load driving insights');
  }

  @override
  Future<List<RiskZone>> getPredictedRiskZones(RouteInfo route) async {
    final response = await _apiClient.post<List<RiskZone>>(
      ApiEndpoints.aiPredictRiskZones,
      data: {'routeId': route.id, 'points': route.toJson()['points']},
      fromJson: (jsonList) {
        if (jsonList is List) {
          return jsonList
              .map((item) => RiskZone.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      },
    );

    if (response.success && response.data != null) {
      return response.data!;
    }
    return [];
  }
}
