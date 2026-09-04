import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/ai_agent/data/supabase_ai_agent_service.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/domain/models/driving_insights.dart';
import 'package:navigator/features/ai_agent/domain/services/ai_agent_service.dart';
import 'package:speech_to_text/speech_to_text.dart';

// AI Service Provider powered by live Supabase context
final aiAgentServiceProvider = Provider<AiAgentService>((ref) {
  return SupabaseAiAgentService();
});

// Weekly Insights Future Provider
final weeklyInsightsProvider = FutureProvider<DrivingInsights>((ref) async {
  final aiService = ref.watch(aiAgentServiceProvider);
  return aiService.getWeeklyInsights();
});

// AI Chat State
class AiChatState {
  final List<AiResponse> messages;
  final bool isThinking;
  final bool isListening;
  final String speechBuffer;

  const AiChatState({
    this.messages = const [],
    this.isThinking = false,
    this.isListening = false,
    this.speechBuffer = '',
  });

  AiChatState copyWith({
    List<AiResponse>? messages,
    bool? isThinking,
    bool? isListening,
    String? speechBuffer,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      isListening: isListening ?? this.isListening,
      speechBuffer: speechBuffer ?? this.speechBuffer,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiAgentService _aiService;
  final SpeechToText _speechToText = SpeechToText();
  bool _speechInitialized = false;

  AiChatNotifier(this._aiService) : super(const AiChatState()) {
    _initChat();
  }

  void _initChat() {
    final welcome = AiResponse(
      text: '👋 **Salom! Men sizning sun\'iy intellekt yo\'l yordamchingizman.**\nRadarlar, yo\'l holati va yo\'l harakati xavfsizligi bo\'yicha qanday yordam bera olaman?',
      suggestions: [
        'Yaqin atrofda qanday radarlar bor?',
        'Bugungi yo\'l harakati va tirbandliklar',
        'Tezlik me\'yorlari va jarimalar',
        'Xavfsiz haydash bo\'yicha maslahatlar',
      ],
      timestamp: DateTime.now(),
    );
    state = state.copyWith(messages: [welcome]);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AiResponse.userMessage(text);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isThinking: true,
      speechBuffer: '',
    );

    try {
      final response = await _aiService.sendMessage(text);
      state = state.copyWith(
        messages: [...state.messages, response],
        isThinking: false,
      );
    } catch (e) {
      final errorMsg = AiResponse(
        text: 'Kechirasiz, so\'rovingizni qayta ishlashda xatolik yuz berdi. Internet aloqasini tekshiring.',
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isThinking: false,
      );
    }
  }

  Future<void> toggleVoiceRecording() async {
    if (state.isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
  }

  Future<void> _startListening() async {
    try {
      if (!_speechInitialized) {
        _speechInitialized = await _speechToText.initialize(
          onError: (e) => state = state.copyWith(isListening: false),
          onStatus: (status) {
            if (status == 'done' || status == 'notListening') {
              state = state.copyWith(isListening: false);
            }
          },
        );
      }

      if (_speechInitialized) {
        state = state.copyWith(isListening: true, speechBuffer: '');
        await _speechToText.listen(
          onResult: (result) {
            state = state.copyWith(speechBuffer: result.recognizedWords);
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              sendMessage(result.recognizedWords);
              _stopListening();
            }
          },
        );
      } else {
        // Fallback simulation for emulators without mic hardware
        state = state.copyWith(isListening: true, speechBuffer: 'Listening...');
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (state.isListening) {
            sendMessage('What awaits me on the road today?');
            state = state.copyWith(isListening: false, speechBuffer: '');
          }
        });
      }
    } catch (_) {
      state = state.copyWith(isListening: false);
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechToText.stop();
    } catch (_) {}
    state = state.copyWith(isListening: false);
  }
}

final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final aiService = ref.watch(aiAgentServiceProvider);
  return AiChatNotifier(aiService);
});
