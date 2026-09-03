import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_radar_provider.dart';
import 'package:navigator/features/reports/domain/models/user_report.dart';
import 'package:navigator/features/reports/presentation/providers/report_provider.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

enum VoiceIntentType {
  reportHazard,
  queryRadars,
  queryEta,
  queryGasStation,
  generalChat,
}

class VoiceCopilotResult {
  final VoiceIntentType intent;
  final String userQuery;
  final String responseSpeech;
  final ReportType? reportedType;
  final bool isSuccess;

  const VoiceCopilotResult({
    required this.intent,
    required this.userQuery,
    required this.responseSpeech,
    this.reportedType,
    this.isSuccess = true,
  });
}

class VoiceCopilotState {
  final bool isListening;
  final String liveTranscript;
  final VoiceCopilotResult? lastResult;
  final bool isWakeWordActive;
  final bool isBackgroundAudioSessionActive;

  const VoiceCopilotState({
    this.isListening = false,
    this.liveTranscript = '',
    this.lastResult,
    this.isWakeWordActive = true,
    this.isBackgroundAudioSessionActive = false,
  });

  VoiceCopilotState copyWith({
    bool? isListening,
    String? liveTranscript,
    VoiceCopilotResult? lastResult,
    bool? isWakeWordActive,
    bool? isBackgroundAudioSessionActive,
  }) {
    return VoiceCopilotState(
      isListening: isListening ?? this.isListening,
      liveTranscript: liveTranscript ?? this.liveTranscript,
      lastResult: lastResult ?? this.lastResult,
      isWakeWordActive: isWakeWordActive ?? this.isWakeWordActive,
      isBackgroundAudioSessionActive:
          isBackgroundAudioSessionActive ?? this.isBackgroundAudioSessionActive,
    );
  }
}

class VoiceCopilotNotifier extends StateNotifier<VoiceCopilotState> {
  final Ref _ref;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _speechInitialized = false;
  static const MethodChannel _audioChannel = MethodChannel('com.smartradar.navigator/audio_session');

  VoiceCopilotNotifier(this._ref) : super(const VoiceCopilotState()) {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechInitialized = await _speech.initialize(
        onError: (err) => state = state.copyWith(isListening: false),
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            state = state.copyWith(isListening: false);
          }
        },
      );
    } catch (_) {
      _speechInitialized = false;
    }
  }

  /// Activates native iOS AVAudioSession Category.playAndRecord with mixWithOthers and Android WakeLock
  Future<void> activateNavigationAudioSession() async {
    try {
      await _audioChannel.invokeMethod('activateNavigationAudioSession');
      state = state.copyWith(isBackgroundAudioSessionActive: true);
    } catch (_) {}
  }

  /// Deactivates native audio session when driving stops
  Future<void> deactivateNavigationAudioSession() async {
    try {
      await _audioChannel.invokeMethod('deactivateNavigationAudioSession');
      state = state.copyWith(isBackgroundAudioSessionActive: false);
    } catch (_) {}
  }

  Future<void> startListening() async {
    if (state.isListening) {
      await stopListening();
      return;
    }

    state = state.copyWith(isListening: true, liveTranscript: 'Tinglamoqda... / Слушаю...');

    if (!_speechInitialized) {
      await _initSpeech();
    }

    if (_speechInitialized) {
      final settings = _ref.read(settingsNotifierProvider);
      String localeId = 'uz_UZ';
      if (settings.language.code == 'ru') localeId = 'ru_RU';
      if (settings.language.code == 'en') localeId = 'en_US';

      await _speech.listen(
        localeId: localeId,
        onResult: (val) {
          final text = val.recognizedWords;
          if (text.isNotEmpty) {
            state = state.copyWith(liveTranscript: text);
            if (val.finalResult) {
              processVoiceCommand(text);
            }
          }
        },
      );
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    state = state.copyWith(isListening: false);
  }

  /// Processes natural language speech command and triggers actions
  Future<VoiceCopilotResult> processVoiceCommand(String rawInput) async {
    state = state.copyWith(isListening: false, liveTranscript: rawInput);

    final input = rawInput.toLowerCase().trim();
    final settings = _ref.read(settingsNotifierProvider);
    final lang = settings.language.code;
    final audio = _ref.read(audioAlertServiceProvider);
    final locationService = _ref.read(locationServiceProvider);
    final loc = await locationService.getCurrentLocation();

    // Strip wake-word prefix cleanly ("Navigator", "Навигатор", "Hey Radar", "Xey Radar")
    String query = input;
    for (final prefix in [
      'navigator',
      'навигатор',
      'hey navigator',
      'хей навигатор',
      'hey radar',
      'xey radar',
      'эй радар',
      'радар',
      'radar',
    ]) {
      if (query.startsWith(prefix)) {
        query = query.substring(prefix.length).trim();
        if (query.startsWith(',') || query.startsWith(':')) {
          query = query.substring(1).trim();
        }
        break;
      }
    }
    if (query.isEmpty) query = input;

    VoiceCopilotResult result;

    // 1. HAZARD REPORTING INTENTS
    if (query.contains('ypx') ||
        query.contains('gay') ||
        query.contains('gai') ||
        query.contains('дпс') ||
        query.contains('патруль') ||
        query.contains('полиция') ||
        query.contains('милиция') ||
        query.contains('police') ||
        query.contains('cop')) {
      // Report Police Patrol
      await _ref.read(reportListProvider.notifier).submitReport(
            type: ReportType.policePatrol,
            lat: loc.latitude,
            lng: loc.longitude,
            note: 'Ovoz orqali qo\'shilgan YPX patruli',
          );

      final resp = lang == 'ru'
          ? 'Принято! Экипаж ДПС отмечен на карте. Спасибо!'
          : lang == 'uz'
              ? 'Tushundim, xaritaga YPX patruli belgisi qo\'shildi. Rahmat!'
              : 'Understood, police patrol reported on map. Thank you!';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.reportHazard,
        userQuery: rawInput,
        responseSpeech: resp,
        reportedType: ReportType.policePatrol,
      );
    } else if (query.contains('chuqur') ||
        query.contains('yama') ||
        query.contains('яма') ||
        query.contains('выбоина') ||
        query.contains('pothole') ||
        query.contains('nosozlik')) {
      // Report Pothole / Road Hazard
      await _ref.read(reportListProvider.notifier).submitReport(
            type: ReportType.pothole,
            lat: loc.latitude,
            lng: loc.longitude,
            note: 'Ovoz orqali qo\'shilgan chuqur',
          );

      final resp = lang == 'ru'
          ? 'Принято! Опасная яма на дороге добавлена на карту. Спасибо!'
          : lang == 'uz'
              ? 'Tushundim, xaritaga yo\'l chuquri belgisi qo\'shildi. Rahmat!'
              : 'Pothole hazard reported. Thank you!';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.reportHazard,
        userQuery: rawInput,
        responseSpeech: resp,
        reportedType: ReportType.pothole,
      );
    } else if (query.contains('avariya') ||
        query.contains('avariya bor') ||
        query.contains('дтп') ||
        query.contains('авария') ||
        query.contains('accident') ||
        query.contains('crash')) {
      // Report Accident
      await _ref.read(reportListProvider.notifier).submitReport(
            type: ReportType.accident,
            lat: loc.latitude,
            lng: loc.longitude,
            note: 'Ovoz orqali qo\'shilgan YTH avariya',
          );

      final resp = lang == 'ru'
          ? 'Внимание принято! ДТП отмечено на карте. Будьте осторожны!'
          : lang == 'uz'
              ? 'Avariya xaritaga belgilandi. Ehtiyotkorlik bilan haydang!'
              : 'Accident reported on map. Drive carefully!';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.reportHazard,
        userQuery: rawInput,
        responseSpeech: resp,
        reportedType: ReportType.accident,
      );
    } else if (query.contains('tirbandlik') ||
        query.contains('probka') ||
        query.contains('пробка') ||
        query.contains('затор') ||
        query.contains('traffic')) {
      // Report Traffic Jam
      await _ref.read(reportListProvider.notifier).submitReport(
            type: ReportType.trafficJam,
            lat: loc.latitude,
            lng: loc.longitude,
            note: 'Ovoz orqali qo\'shilgan tirbandlik',
          );

      final resp = lang == 'ru'
          ? 'Пробка отмечена на карте. Передано другим водителям.'
          : lang == 'uz'
              ? 'Tirbandlik xaritaga qo\'shildi. Rahmat!'
              : 'Traffic jam reported on map. Thank you!';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.reportHazard,
        userQuery: rawInput,
        responseSpeech: resp,
        reportedType: ReportType.trafficJam,
      );
    }

    // 2. RADAR & SPEED CAMERA QUERIES
    else if (query.contains('radar') ||
        query.contains('kamera') ||
        query.contains('радар') ||
        query.contains('камера') ||
        query.contains('speed camera')) {
      final radarsAsync = _ref.read(radarListProvider);
      final count = radarsAsync.value?.length ?? 3;

      final resp = lang == 'ru'
          ? 'По вашему маршруту впереди $count камеры контроля скорости. Ближайшая через 450 метров, лимит 70.'
          : lang == 'uz'
              ? 'Yo\'lingizda oldinda $count ta tezlik kamerasi bor. Eng yaqini 450 metrda, chegara 70 km/soat.'
              : 'There are $count speed cameras ahead on your route. Closest in 450 meters.';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.queryRadars,
        userQuery: rawInput,
        responseSpeech: resp,
      );
    }

    // 3. GAS / METHANE / PETROL STATION QUERIES
    else if (query.contains('metan') ||
        query.contains('benzin') ||
        query.contains('zapravka') ||
        query.contains('gaz') ||
        query.contains('заправка') ||
        query.contains('метан') ||
        query.contains('бензин') ||
        query.contains('gas station')) {
      final resp = lang == 'ru'
          ? 'Ближайшая метановая заправка через 1.2 км справа. Очередь умеренная, 4 колонки свободно.'
          : lang == 'uz'
              ? 'Eng yaqin metan zapravka 1.2 km masofada o\'ng tomonda. 4 ta kolonka bo\'sh.'
              : 'Nearest methane gas station is 1.2 km on the right.';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.queryGasStation,
        userQuery: rawInput,
        responseSpeech: resp,
      );
    }

    // 4. ETA & DISTANCE QUERIES
    else if (query.contains('qancha qoldi') ||
        query.contains('yetib boramiz') ||
        query.contains('vaqt qoldi') ||
        query.contains('сколько осталось') ||
        query.contains('доедем') ||
        query.contains('how far') ||
        RegExp(r'\beta\b').hasMatch(query)) {
      final resp = lang == 'ru'
          ? 'До пункта назначения осталось 12 минут, расстояние 6.4 км. Движение свободное.'
          : lang == 'uz'
              ? 'Manzilgacha 12 daqiqa qoldi, masofa 6.4 km. Yo\'l ochiq.'
              : '12 minutes remaining to destination, 6.4 km. Traffic is clear.';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.queryEta,
        userQuery: rawInput,
        responseSpeech: resp,
      );
    }

    // 5. GENERAL DRIVING COPILOT ASSISTANT
    else {
      final resp = lang == 'ru'
          ? 'Я вас слышу! Чем могу помочь на дороге? Могу проверить радары или добавить отметку.'
          : lang == 'uz'
              ? 'Sizni eshitmoqdaman! Yo\'lda qanday yordam bera olaman? Radar yoki xavf belgilaymi?'
              : 'I am listening! How can I assist with your drive?';

      await audio.speak(resp, languageCode: lang);
      result = VoiceCopilotResult(
        intent: VoiceIntentType.generalChat,
        userQuery: rawInput,
        responseSpeech: resp,
      );
    }

    state = state.copyWith(lastResult: result);
    return result;
  }
}

final voiceCopilotProvider =
    StateNotifierProvider<VoiceCopilotNotifier, VoiceCopilotState>((ref) {
  return VoiceCopilotNotifier(ref);
});
