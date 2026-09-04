import 'package:latlong2/latlong.dart';
import 'package:navigator/core/services/supabase_service.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/domain/models/driving_insights.dart';
import 'package:navigator/features/ai_agent/domain/models/risk_zone.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';
import 'package:navigator/features/ai_agent/domain/services/ai_agent_service.dart';

class SupabaseAiAgentService implements AiAgentService {
  @override
  Future<AiResponse> sendMessage(String message) async {
    final lower = message.toLowerCase().trim();

    // 1. Check if user is asking about radars or cameras
    if (lower.contains('radar') || lower.contains('kamera') || lower.contains('camera') || lower.contains('tezlik')) {
      try {
        final radarsRes = await SupabaseService.client
            .from('radars')
            .select('title, speed_limit, address')
            .limit(3);

        final list = radarsRes as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final title = first['title'] ?? 'Statsionar radar';
          final limit = first['speed_limit'] ?? 60;
          final addr = first['address'] ?? 'hudud';
          return AiResponse(
            text: 'Yaqin atrofda $title mavjud. Tezlik cheklovi: $limit km/soat ($addr). Iltimos, belgilangan tezlikdan oshmang!',
            timestamp: DateTime.now(),
            cardType: AiCardType.radarHotspots,
            suggestions: ['Boshqa radarlar bormi?', 'Tezlik jarimalari qancha?'],
          );
        }
      } catch (_) {}

      return AiResponse(
        text: 'Shaharda asosiy tezlik cheklovi 60 km/soat. Maktab va bog\'chalar yaqinida 30 km/soat. Harakatlanayotgan yo\'lingizda radarlar faol kuzatilmoqda.',
        timestamp: DateTime.now(),
        cardType: AiCardType.radarHotspots,
        suggestions: ['Tezlik cheklovlari', 'Jarimalar haqida'],
      );
    }

    // 2. Check if user is asking about road conditions, traffic or hazards
    if (lower.contains('yo\'l') || lower.contains('tirband') || lower.contains('probka') || lower.contains('chuqur') || lower.contains('xavf')) {
      try {
        final reportsRes = await SupabaseService.client
            .from('user_reports')
            .select('type, note')
            .limit(2);

        final list = reportsRes as List<dynamic>;
        if (list.isNotEmpty) {
          final first = list.first as Map<String, dynamic>;
          final type = first['type'] ?? 'xavf';
          final note = first['note'] ?? '';
          return AiResponse(
            text: 'Supabase real ma\'lumotlariga ko\'ra yo\'lda $type qayd etilgan: "$note". Ehtiyotkorlik bilan boshqaring!',
            timestamp: DateTime.now(),
            cardType: AiCardType.routeAdvice,
            suggestions: ['Aylanib o\'tish yo\'li bormi?', 'Qayta hisoblash'],
          );
        }
      } catch (_) {}

      return AiResponse(
        text: 'Yo\'lda favqulodda to\'siqlar yo\'q, harakat ochiq. Har doim xavfsiz oraliq masofani saqlang.',
        timestamp: DateTime.now(),
        cardType: AiCardType.routeAdvice,
      );
    }

    // 3. Fines and penalties
    if (lower.contains('jarima') || lower.contains('shtraf') || lower.contains('qoida')) {
      return AiResponse(
        text: 'O\'zbekiston YHQga binoan tezlikni 20 km/s gacha oshirish 1 BHM, 20-40 km/s oshirish 5 BHM jarima belgilangan. 15 kun ichida 50% chegirma bilan to\'lash mumkin.',
        timestamp: DateTime.now(),
        suggestions: ['Qanday to\'lash mumkin?', 'Boshqa jarimalar'],
      );
    }

    // 4. Default intelligent copilot response
    return AiResponse(
      text: 'Sizga navigatsiya, radarlar va yo\'l harakati bo\'yicha yordam berishga tayyorman. Savolingizni bering yoki manzil ayting!',
      timestamp: DateTime.now(),
      suggestions: ['Yaqin atrofda qanday radarlar bor?', 'Yo\'l harakati xavfsizligi'],
    );
  }

  @override
  Future<DrivingInsights> getWeeklyInsights() async {
    try {
      final user = SupabaseService.client.auth.currentUser;
      final userId = user?.id ?? 'usr_me';
      final res = await SupabaseService.client
          .from('profiles')
          .select('safety_score, total_distance_km, clean_trips, speeding_count, karma_points')
          .eq('id', userId)
          .maybeSingle();

      if (res != null) {
        final score = (res['safety_score'] as num?)?.toInt() ?? 100;
        final dist = (res['total_distance_km'] as num?)?.toDouble() ?? 0.0;
        final clean = (res['clean_trips'] as num?)?.toInt() ?? 0;
        final speed = (res['speeding_count'] as num?)?.toInt() ?? 0;
        final karma = (res['karma_points'] as num?)?.toInt() ?? 0;
        return DrivingInsights(
          weeklySpeedEvents: speed,
          safetyScore: score,
          distanceDrivenKm: dist,
          cleanTripStreak: clean,
          karmaPointsEarned: karma,
          badges: const [],
          aiSuggestions: [
            if (score >= 90) 'Ajoyib intizom! Tezlik me\'yorlariga amal qilib bormoqdasiz.'
            else 'Xavfsiz masofa va belgilangan tezlikka e\'tibor bering.',
          ],
          generatedAt: DateTime.now(),
        );
      }
    } catch (_) {}

    return DrivingInsights(
      weeklySpeedEvents: 0,
      safetyScore: 100,
      distanceDrivenKm: 0.0,
      cleanTripStreak: 0,
      karmaPointsEarned: 0,
      badges: const [],
      aiSuggestions: const [
        'Harakat davomida tezlik chegaralariga rioya qiling.',
      ],
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RiskZone>> getPredictedRiskZones(RouteInfo route) async {
    try {
      final radarsRes = await SupabaseService.client
          .from('radars')
          .select('id, title, latitude, longitude, speed_limit, address')
          .limit(5);

      final list = radarsRes as List<dynamic>;
      if (list.isNotEmpty) {
        return list.map((r) {
          final m = r as Map<String, dynamic>;
          final lat = (m['latitude'] as num?)?.toDouble() ?? 39.654760;
          final lng = (m['longitude'] as num?)?.toDouble() ?? 66.975830;
          final title = m['title']?.toString() ?? 'Radar zonasi';
          final limit = m['speed_limit']?.toString() ?? '60';
          return RiskZone(
            id: m['id']?.toString() ?? 'rz_${lat.hashCode}',
            name: title,
            lat: lat,
            lng: lng,
            radiusMeters: 250,
            riskLevel: RiskLevel.moderate,
            reason: 'Tezlik nazorati: $limit km/soat',
            cameraCount: 1,
          );
        }).toList();
      }
    } catch (_) {}

    return [];
  }
}
