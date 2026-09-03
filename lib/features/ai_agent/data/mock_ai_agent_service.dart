import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/domain/models/driving_insights.dart';
import 'package:navigator/features/ai_agent/domain/models/risk_zone.dart';
import 'package:navigator/features/ai_agent/domain/services/ai_agent_service.dart';
import 'package:navigator/features/navigation/domain/models/route_info.dart';

class MockAiAgentService implements AiAgentService {
  @override
  Future<AiResponse> sendMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final lower = message.toLowerCase();

    // 1. Uzbek Language Prompts
    if (lower.contains('bugun') || lower.contains('kutmoqda') || lower.contains('holat')) {
      return AiResponse(
        text: '🛣️ **Bugungi Yo\'l Holati (Toshkent):**\n• Amir Temur shoh ko\'chasida o\'rtacha tirbandlik.\n• Bunyodkor ko\'chasida (Magic City yaqinida) 2 ta YPX radari faol.\n• Ob-havo: Ochiq 26°C. Ko\'rinish a\'lo darajada.\n• Eng qulay yo\'lga chiqish vaqti: 17:30 gacha.',
        suggestions: [
          'Chilonzorga eng yaxshi yo\'l qaysi?',
          'Bu haftadagi haydash ballim qanday?',
          'Eng ko\'p radarlar qayerda?',
        ],
        cardType: AiCardType.riskForecast,
        data: {
          'riskLevel': 'O\'rtacha',
          'activeCameras': 14,
          'reportedPatrols': 3,
          'weather': 'Ochiq 26°C',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('chilonzor') && (lower.contains('yo\'l') || lower.contains('qaysi') || lower.contains('yaxshi'))) {
      return AiResponse(
        text: '🚗 **Chilonzorga yo\'nalish tavsiyasi:**\nBunyodkor shoh ko\'chasi o\'rniga **Muqimiy aylanma yo\'li** orqali yurishni tavsiya qilaman. 3 ta tezlik kamerasidan aylanib o\'tasiz va tig\'iz vaqtda ~4 daqiqa tejaysiz.',
        suggestions: [
          'Harakatni boshlash',
          'Bugun yo\'llarda nima kutmoqda?',
          'Xavfsizlik ballini ko\'rish',
        ],
        cardType: AiCardType.routeAdvice,
        data: {
          'recommendedRoute': 'Muqimiy Aylanma Yo\'li',
          'distanceKm': 8.6,
          'radarsAvoided': 3,
          'timeSavedMin': 4,
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('ball') || lower.contains('reyting') || (lower.contains('hafta') && lower.contains('haydash'))) {
      return AiResponse(
        text: '🏆 **Haftalik Haydash Tahlili:**\nAjoyib natija! Xavfsizlik reytingingiz: **94/100** (Toshkent bo\'yicha eng yaxshi 5%).\n• Tezlik oshirishlar: 0 ta\n• Bosib o\'tilgan masofa: 184.2 km\n• Radar ogohlantirishlariga rioya: 100%\n• Karma ballari: +140 ball to\'plandi.',
        suggestions: [
          'Peshqadamlar Jadvali',
          'Bugun yo\'llarda nima kutmoqda?',
          '100 ballga chiqish sirlari',
        ],
        cardType: AiCardType.weeklySummary,
        data: {
          'score': 94,
          'distance': 184.2,
          'speedEvents': 0,
          'tier': 'Mohir Xavfsiz Haydovchi',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('qayerda') || (lower.contains('radar') && lower.contains('ko\'p'))) {
      return AiResponse(
        text: '⚠️ **Toshkentdagi faol radar hududlari:**\n1. **Bunyodkor shoh ko\'chasi** (Mobil radar va 60 km/soat kamerasi)\n2. **Amir Temur shoh ko\'chasi** (Autocon Dual 70 km/soat)\n3. **Kichik halqa yo\'li / Janubiy vokzal** (80 km/soat ko\'p qatorli radar)\n4. **Buyuk Ipak Yo\'li chorrahasi** (Svetofor va to\'xtash chizig\'i kamerasi)',
        suggestions: [
          'Radarlardan xoli yo\'nalish',
          'Yangi xavf haqida xabar berish',
          'Bugun yo\'llarda nima kutmoqda?',
        ],
        cardType: AiCardType.radarHotspots,
        data: {
          'hotspotCount': 4,
          'mostActive': 'Bunyodkor shoh ko\'chasi',
        },
        timestamp: DateTime.now(),
      );
    }

    // 2. Russian Language Prompts
    else if (lower.contains('сегодня') || lower.contains('ждет') || lower.contains('дорог')) {
      return AiResponse(
        text: '🛣️ **Ситуация на дорогах сегодня (Ташкент):**\n• Умеренный трафик на проспекте Амира Темура.\n• 2 активных патруля ДПС на проспекте Бунёдкор возле Magic City.\n• Погода: Ясно +26°C. Отличная видимость.\n• Оптимальное время выезда: до 17:30.',
        suggestions: [
          'Как лучше доехать до Чиланзара?',
          'Какой у меня рейтинг за неделю?',
          'Где сейчас больше всего камер?',
        ],
        cardType: AiCardType.riskForecast,
        data: {
          'riskLevel': 'Умеренный',
          'activeCameras': 14,
          'reportedPatrols': 3,
          'weather': 'Ясно 26°C',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('чиланзар') || lower.contains('маршрут') || lower.contains('доехать')) {
      return AiResponse(
        text: '🚗 **Рекомендация маршрута на Чиланзар:**\nРекомендую поехать через **объездную Мукими**, а не по проспекту Бунёдкор. Вы избежите 3 скоростных камер и сэкономите ~4 минуты.',
        suggestions: [
          'Начать поездку',
          'Что меня ждет на дорогах сегодня?',
          'Показать статистику безопасности',
        ],
        cardType: AiCardType.routeAdvice,
        data: {
          'recommendedRoute': 'Объездная Мукими',
          'distanceKm': 8.6,
          'radarsAvoided': 3,
          'timeSavedMin': 4,
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('рейтинг') || lower.contains('недел') || lower.contains('оценк')) {
      return AiResponse(
        text: '🏆 **Недельный анализ вождения:**\nОтличные показатели! Ваш индекс безопасности: **94/100** (входит в топ-5% по Ташкенту).\n• Превышений скорости: 0\n• Пройдено: 184.2 км\n• Реакция на предупреждения: 100%\n• Баллы кармы: +140 очков заработано.',
        suggestions: [
          'Таблица лидеров',
          'Что меня ждет на дорогах сегодня?',
          'Советы для 100 баллов',
        ],
        cardType: AiCardType.weeklySummary,
        data: {
          'score': 94,
          'distance': 184.2,
          'speedEvents': 0,
          'tier': 'Мастер Безопасного Вождения',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('камер') || lower.contains('пост') || lower.contains('засад')) {
      return AiResponse(
        text: '⚠️ **Активные радары и посты в Ташкенте:**\n1. **Проспект Бунёдкор** (Патруль с радаром и камера 60 км/ч)\n2. **Проспект Амира Темура** (Автокон Dual 70 км/ч)\n3. **Малая кольцевая дорога / Южный вокзал** (80 км/ч многополосный радар)\n4. **Перекресток Буюк Ипак Йули** (Камера на стоп-линию и красный свет)',
        suggestions: [
          'Маршрут без радаров',
          'Сообщить о событии',
          'Что меня ждет на дорогах сегодня?',
        ],
        cardType: AiCardType.radarHotspots,
        data: {
          'hotspotCount': 4,
          'mostActive': 'Проспект Бунёдкор',
        },
        timestamp: DateTime.now(),
      );
    }

    // 3. English Default Prompts
    else if (lower.contains('road today')) {
      return AiResponse(
        text: '🛣️ **Road Outlook Today:**\n• Moderate traffic on Amir Temur Ave.\n• 2 active mobile patrols spotted on Bunyodkor Ave near Magic City.\n• Weather: Clear 26°C. Excellent visibility.\n• Safest departure window: Before 17:30.',
        suggestions: [
          'Best route to Chilonzor?',
          'How was my driving this week?',
          'Show radar hotspots',
        ],
        cardType: AiCardType.riskForecast,
        data: {
          'riskLevel': 'Moderate',
          'activeCameras': 14,
          'reportedPatrols': 3,
          'weather': 'Sunny 26°C',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('chilonzor') || lower.contains('route')) {
      return AiResponse(
        text: '🚗 **Route Recommendation to Chilonzor:**\nI recommend taking the **Muqimi bypass** instead of Bunyodkor Ave. You will avoid 3 high-speed traps and save ~4 minutes during rush hour.',
        suggestions: [
          'Start navigation now',
          'What awaits me on the road today?',
          'Analyze my safety score',
        ],
        cardType: AiCardType.routeAdvice,
        data: {
          'recommendedRoute': 'Muqimi Bypass',
          'distanceKm': 8.6,
          'radarsAvoided': 3,
          'timeSavedMin': 4,
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('driving') || lower.contains('score') || lower.contains('week')) {
      return AiResponse(
        text: '🏆 **Weekly Driving Analysis:**\nOutstanding driving this week! Your Safety Score is **94/100** (Top 5% in Tashkent).\n• Speed Violations: 0\n• Distance Logged: 184.2 km\n• Radar Alerts Heeded: 100%\n• Karma Points: +140 pts earned.',
        suggestions: [
          'View Leaderboard',
          'What awaits me on the road today?',
          'Tips to reach 100 score',
        ],
        cardType: AiCardType.weeklySummary,
        data: {
          'score': 94,
          'distance': 184.2,
          'speedEvents': 0,
          'tier': 'Elite Safe Driver',
        },
        timestamp: DateTime.now(),
      );
    } else if (lower.contains('radar') || lower.contains('trap')) {
      return AiResponse(
        text: '⚠️ **Active Radar Hotspots in Tashkent:**\n1. **Bunyodkor Ave** (Mobile patrol & 60 km/h camera)\n2. **Amir Temur Ave** (Autocon Dual 70 km/h)\n3. **Little Ring Road / South Station** (80 km/h Multi-lane radar)\n4. **Buyuk Ipak Yuli Crossroad** (Red-light & stop-line camera)',
        suggestions: [
          'Best route avoiding radars',
          'Report a new camera',
          'What awaits me on the road today?',
        ],
        cardType: AiCardType.radarHotspots,
        data: {
          'hotspotCount': 4,
          'mostActive': 'Bunyodkor Ave',
        },
        timestamp: DateTime.now(),
      );
    } else {
      return AiResponse(
        text: 'Yo\'l harakati xavfsizligi va kameralar holati bo\'yicha yordam berishga tayyorman. Savolingizni bering! / Я готов помочь с информацией о дорогах и камерах. Задайте ваш вопрос!',
        suggestions: [
          'Bugun yo\'llarda nima kutmoqda?',
          'Что меня ждет на дорогах сегодня?',
          'What awaits me on the road today?',
        ],
        timestamp: DateTime.now(),
      );
    }
  }

  @override
  Future<DrivingInsights> getWeeklyInsights() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return DrivingInsights(
      weeklySpeedEvents: 0,
      safetyScore: 94,
      distanceDrivenKm: 184.2,
      cleanTripStreak: 8,
      karmaPointsEarned: 140,
      badges: ['Safe Master', 'Night Owl', 'Zero Speeding Week', 'Hazard Spotter'],
      aiSuggestions: [
        'Amir Temur shoh ko\'chasida 70 km/soat tezlikka to\'liq rioya qilindi.',
        'Плавность торможения улучшилась на 14% по сравнению с прошлой неделей.',
        'Great job maintaining safe following distance during rush hour.',
      ],
      generatedAt: DateTime.now(),
    );
  }

  @override
  Future<List<RiskZone>> getPredictedRiskZones(RouteInfo route) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return route.riskZones;
  }
}
