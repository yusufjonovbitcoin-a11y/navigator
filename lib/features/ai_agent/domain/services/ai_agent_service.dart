import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/domain/models/driving_insights.dart';
import 'package:navigator/features/ai_agent/domain/models/risk_zone.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';

abstract class AiAgentService {
  Future<AiResponse> sendMessage(String message);
  Future<DrivingInsights> getWeeklyInsights();
  Future<List<RiskZone>> getPredictedRiskZones(RouteInfo route);
}
