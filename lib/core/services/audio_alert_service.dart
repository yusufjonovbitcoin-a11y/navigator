import 'package:flutter_tts/flutter_tts.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';

class AudioAlertService {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  AudioAlertService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        ],
      );
      await _tts.setSpeechRate(0.50); // Natural conversational tempo
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  Future<void> speak(String text, {String languageCode = 'ru'}) async {
    if (!_isInitialized) await _initTts();
    try {
      String ttsLang = 'ru-RU';
      if (languageCode == 'uz') {
        ttsLang = 'uz-UZ';
      } else if (languageCode == 'en') {
        ttsLang = 'en-US';
      }

      await _tts.setLanguage(ttsLang);

      // Attempt to pick a premium natural neural voice on iOS / Android if present
      try {
        final dynamic voices = await _tts.getVoices;
        if (voices is List) {
          for (final dynamic voice in voices) {
            if (voice is Map) {
              final name = voice['name']?.toString().toLowerCase() ?? '';
              final locale = voice['locale']?.toString() ?? '';
              if (ttsLang == 'ru-RU' && (locale.contains('ru') || name.contains('ru'))) {
                if (name.contains('milena') ||
                    name.contains('yuri') ||
                    name.contains('katya') ||
                    name.contains('enhanced') ||
                    name.contains('premium') ||
                    name.contains('natural')) {
                  await _tts.setVoice({
                    'name': voice['name'] as String,
                    'locale': voice['locale'] as String,
                  });
                  break;
                }
              }
            }
          }
        }
      } catch (_) {}

      await _tts.setSpeechRate(0.50);
      await _tts.setPitch(1.0);
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      // Graceful fallback
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  /// Converts meters into natural spoken Russian automotive distances (like Yandex Navigator)
  static String _formatRussianDistance(int meters) {
    if (meters >= 900) return 'один километр';
    if (meters >= 750) return 'восемьсот';
    if (meters >= 650) return 'семьсот';
    if (meters >= 550) return 'шестьсот';
    if (meters >= 450) return 'пятьсот';
    if (meters >= 350) return 'четыреста';
    if (meters >= 250) return 'триста';
    if (meters >= 180) return 'двести';
    if (meters >= 120) return 'сто пятьдесят';
    if (meters >= 80) return 'сто';
    if (meters >= 40) return 'пятьдесят';
    return '$meters';
  }

  /// Converts speed into natural spoken Russian words
  static String _formatRussianSpeed(int speed) {
    switch (speed) {
      case 40:
        return 'сорок';
      case 50:
        return 'пятьдесят';
      case 60:
        return 'шестьдесят';
      case 70:
        return 'семьдесят';
      case 80:
        return 'восемьдесят';
      case 90:
        return 'девяносто';
      case 100:
        return 'сто';
      case 110:
        return 'сто десять';
      default:
        return '$speed';
    }
  }

  /// Converts meters into natural spoken Uzbek distances
  static String _formatUzbekDistance(int meters) {
    if (meters >= 900) return 'bir kilometrda';
    if (meters >= 750) return 'sakkiz yuz metrda';
    if (meters >= 550) return 'olti yuz metrda';
    if (meters >= 450) return 'besh yuz metrda';
    if (meters >= 350) return 'to\'rt yuz metrda';
    if (meters >= 250) return 'uch yuz metrda';
    if (meters >= 150) return 'ikki yuz metrda';
    if (meters >= 80) return 'yuz metrda';
    return '$meters metrda';
  }

  /// Converts speed limit into natural spoken Uzbek words
  static String _formatUzbekSpeed(int speed) {
    switch (speed) {
      case 40:
        return 'qirqlik';
      case 50:
        return 'elliklik';
      case 60:
        return 'oltmishlik';
      case 70:
        return 'yetmishlik';
      case 80:
        return 'saksonlik';
      case 90:
        return 'to\'qsonlik';
      case 100:
        return 'yuzlik';
      case 110:
        return 'bir yuz o\'nlik';
      default:
        return '$speed lik';
    }
  }

  Future<void> announceRadar({
    RadarType type = RadarType.stationary,
    required String radarType,
    required int distanceMeters,
    required int speedLimit,
    required String languageCode,
    bool isOverSpeed = false,
  }) async {
    String text;

    if (languageCode == 'ru') {
      final distWord = _formatRussianDistance(distanceMeters);
      final speedWord = _formatRussianSpeed(speedLimit);

      if (isOverSpeed) {
        text = 'Снижайте скорость! Впереди камера на $speedWord.';
      } else {
        switch (type) {
          case RadarType.stationary:
            text = 'Через $distWord метров камера на $speedWord.';
            break;
          case RadarType.mobile:
            text = 'Через $distWord метров экипаж ДПС. Будьте внимательны.';
            break;
          case RadarType.speedTrap:
            text = 'Через $distWord метров начало контроля средней скорости. Ограничение $speedWord.';
            break;
          case RadarType.redLight:
            text = 'Через $distWord метров контроль светофора и стоп-линии.';
            break;
          case RadarType.hazard:
            text = 'Внимание! Через $distWord метров опасность на дороге.';
            break;
        }
      }
    } else if (languageCode == 'uz') {
      final distWord = _formatUzbekDistance(distanceMeters);
      final speedWord = _formatUzbekSpeed(speedLimit);

      if (isOverSpeed) {
        final humorousSpeedAlerts = [
          'Agar shtraf to\'lagingiz kelmasa, sekinroq yuring! Oldinda $speedWord radar!',
          'Tezlikni tushiring! Hamyonga rahm qiling, oldinda $speedWord kamera!',
          'Sekinroq yuring, shtraf to\'lash shart emas, oldinda radar!',
        ];
        text = humorousSpeedAlerts[DateTime.now().second % humorousSpeedAlerts.length];
      } else {
        switch (type) {
          case RadarType.stationary:
            text = '$distWord $speedWord statsionar kamera. Shtrafga tushmaslik uchun sekinroq yuring.';
            break;
          case RadarType.mobile:
            text = '$distWord YPX patrul xodimlari. Kamarni taqib, sekinroq yuring.';
            break;
          case RadarType.speedTrap:
            text = '$distWord o\'rtacha tezlik nazorati boshlanmoqda. Cheklov $speedWord.';
            break;
          case RadarType.redLight:
            text = '$distWord svetofor va to\'xtash chizig\'i nazorati.';
            break;
          case RadarType.hazard:
            text = '$distWord yo\'lda xavfli holat.';
            break;
        }
      }
    } else {
      if (isOverSpeed) {
        text = 'Reduce your speed! Speed camera ahead at $speedLimit kilometers per hour.';
      } else {
        text = 'In $distanceMeters meters, $radarType. Speed limit $speedLimit.';
      }
    }

    await speak(text, languageCode: languageCode);
  }

  Future<void> announceHazard({
    required String hazardType,
    required int distanceMeters,
    required String languageCode,
  }) async {
    String text;
    if (languageCode == 'ru') {
      final distWord = _formatRussianDistance(distanceMeters);
      text = 'Внимание! Через $distWord метров $hazardType на дороге. Будьте осторожны.';
    } else if (languageCode == 'uz') {
      final distWord = _formatUzbekDistance(distanceMeters);
      text = 'Diqqat! $distWord yo\'lda $hazardType. Ehtiyot bo\'ling.';
    } else {
      text = 'Caution! $hazardType reported $distanceMeters meters ahead. Drive safely.';
    }

    await speak(text, languageCode: languageCode);
  }
}
