import 'package:flutter/material.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';

class AiInsightCard extends StatelessWidget {
  final AiResponse response;

  const AiInsightCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (response.cardType) {
      case AiCardType.weeklySummary:
        return _buildWeeklySummaryCard(isDark);
      case AiCardType.riskForecast:
        return _buildRiskForecastCard(isDark);
      case AiCardType.routeAdvice:
        return _buildRouteAdviceCard(isDark);
      case AiCardType.radarHotspots:
        return _buildRadarHotspotsCard(isDark);
      case AiCardType.none:
        return const SizedBox.shrink();
    }
  }

  Widget _buildWeeklySummaryCard(bool isDark) {
    final score = response.data?['score'] ?? 96;
    final dist = response.data?['distance'] ?? 240.0;
    final violations = response.data?['speedEvents'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.emoji_events_rounded, color: Color(0xFFFF9500), size: 20),
              SizedBox(width: 8),
              Text(
                'Haftalik AI Hisobot & Xavfsizlik',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF9500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Xavfsizlik', '$score/100', const Color(0xFF34C759), isDark),
              _buildMiniMetric('Masofa', '$dist km', isDark ? Colors.white : const Color(0xFF1C1C1E), isDark),
              _buildMiniMetric('Qoidabuzarlik', '$violations', violations == 0 ? const Color(0xFF34C759) : const Color(0xFFFF3B30), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskForecastCard(bool isDark) {
    final level = response.data?['riskLevel'] ?? 'O\'rtacha';
    final cams = response.data?['activeCameras'] ?? 18;
    final weather = response.data?['weather'] ?? 'Ochiq 24°C';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF9500).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9500), size: 20),
              SizedBox(width: 8),
              Text(
                'Jonli Yo\'l Xavflari Prognozi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFFFF9500)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Shahar Xavfi', level, const Color(0xFFFF9500), isDark),
              _buildMiniMetric('Kameralar', '$cams ta faol', isDark ? AppColors.primary : const Color(0xFF007AFF), isDark),
              _buildMiniMetric('Ob-havo', weather, isDark ? Colors.white : const Color(0xFF1C1C1E), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteAdviceCard(bool isDark) {
    final route = response.data?['recommendedRoute'] ?? 'Muqimiy aylanma';
    final dist = response.data?['distanceKm'] ?? 8.6;
    final saved = response.data?['timeSavedMin'] ?? 6;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF34C759).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, color: Color(0xFF34C759), size: 20),
              SizedBox(width: 8),
              Text(
                'AI Tavsiya Qilgan Xavfsiz Yo\'l',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF34C759)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniMetric('Marshrut', route, const Color(0xFF34C759), isDark),
              _buildMiniMetric('Masofa', '$dist km', isDark ? Colors.white : const Color(0xFF1C1C1E), isDark),
              _buildMiniMetric('Tejalgan vaqt', '+$saved daq', const Color(0xFF34C759), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadarHotspotsCard(bool isDark) {
    final count = response.data?['hotspotCount'] ?? 4;
    final top = response.data?['mostActive'] ?? 'Bunyodkor shoh ko\'chasi';

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFF3B30).withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMiniMetric('Faol Radar Qatorlari', '$count ta sektor', const Color(0xFFFF3B30), isDark),
          _buildMiniMetric('Eng Ko\'p Radarlar', top, isDark ? Colors.white : const Color(0xFF1C1C1E), isDark),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : const Color(0xFF64748B)),
        ),
      ],
    );
  }
}
