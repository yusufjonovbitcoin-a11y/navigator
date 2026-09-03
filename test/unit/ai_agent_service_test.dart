import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:navigator/features/ai_agent/data/mock_ai_agent_service.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';

void main() {
  group('MockAiAgentService Tests', () {
    late MockAiAgentService aiService;

    setUp(() {
      aiService = MockAiAgentService();
    });

    test('sendMessage responds to "road today" prompt with risk forecast', () async {
      final response = await aiService.sendMessage('What awaits me on the road today?');

      expect(response.text, isNotEmpty);
      expect(response.cardType, equals(AiCardType.riskForecast));
      expect(response.suggestions, isNotEmpty);
      expect(response.data?['riskLevel'], isNotNull);
    });

    test('sendMessage responds to "chilonzor" prompt with route advice', () async {
      final response = await aiService.sendMessage('Best route to Chilonzor?');

      expect(response.text, contains('Muqimi'));
      expect(response.cardType, equals(AiCardType.routeAdvice));
      expect(response.data?['timeSavedMin'], equals(4));
    });

    test('getWeeklyInsights returns valid driving stats and safety score', () async {
      final insights = await aiService.getWeeklyInsights();

      expect(insights.safetyScore, greaterThanOrEqualTo(90));
      expect(insights.weeklySpeedEvents, equals(0));
      expect(insights.badges, contains('Safe Master'));
      expect(insights.aiSuggestions, isNotEmpty);
    });

    test('getPredictedRiskZones returns risk zones on route', () async {
      const testRoute = RouteInfo(
        id: 'r1',
        name: 'Test',
        points: [LatLng(41.31, 69.24)],
        distanceKm: 5.0,
        durationMinutes: 10,
        radarCount: 2,
        riskScore: 30,
        summary: 'Test',
      );

      final zones = await aiService.getPredictedRiskZones(testRoute);
      expect(zones, isList);
    });
  });
}
