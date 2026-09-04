import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/services/voice_copilot_service.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/voice_wave_indicator.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class VoiceAssistantOverlay extends ConsumerStatefulWidget {
  const VoiceAssistantOverlay({super.key});

  static void show(BuildContext context) {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const VoiceAssistantOverlay(),
    );
  }

  @override
  ConsumerState<VoiceAssistantOverlay> createState() => _VoiceAssistantOverlayState();
}

class _VoiceAssistantOverlayState extends ConsumerState<VoiceAssistantOverlay> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceCopilotProvider.notifier).startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceCopilotProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isUzbek = settings.language.code == 'uz';
    final isRussian = settings.language.code == 'ru';

    final quickChips = isRussian
        ? [
            '«Эй Радар, здесь экипаж ДПС»',
            '«Впереди глубокая яма»',
            '«Сколько осталось до Чиланзара?»',
            '«Есть ли радары по пути?»',
            '«Где ближайшая метановая заправка?»',
            '«Впереди стационарная камера»',
          ]
        : isUzbek
            ? [
                '«Hey Radar, o\'ngda YPX turibdi»',
                '«Bu yerda chuqur bor»',
                '«Chilonzorga qancha qoldi?»',
                '«Yo\'lda qanday radarlar bor?»',
                '«Eng yaqin metan zapravka»',
                '«Oldinda stasionar kamera bor»',
              ]
            : [
                '«Hey Radar, police patrol ahead»',
                '«There is a pothole here»',
                '«How much time to Chilonzor?»',
                '«Show speed cameras»',
                '«Find closest methane gas station»',
                '«Speed camera ahead»',
              ];

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F1D).withOpacity(0.92),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.18), width: 1.0)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Top Apple Drag Pill
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
              ),

              // 2. Siri Glowing Orb & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFF0072FF), Color(0xFFA855F7)],
                        radius: 0.9,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E5FF).withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        voiceState.isListening ? CupertinoIcons.waveform : CupertinoIcons.sparkles,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 800.ms),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hey Radar • Voice Copilot',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: voiceState.isListening ? const Color(0xFF34C759) : Colors.white54,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            voiceState.isListening
                                ? (isRussian ? 'Слушаю ваш голос...' : isUzbek ? 'Ovozingizni tinglamoqda...' : 'Listening...')
                                : (isRussian ? 'Готов к командам' : isUzbek ? 'Buyruqqa tayyor' : 'Ready'),
                            style: TextStyle(
                              fontSize: 12,
                              color: voiceState.isListening ? const Color(0xFF34C759) : Colors.white60,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Live Transcript / Response Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Column(
                  children: [
                    if (voiceState.isListening) ...[
                      const VoiceWaveIndicator(),
                      const SizedBox(height: 12),
                    ],
                    Text(
                      voiceState.lastResult != null
                          ? voiceState.lastResult!.responseSpeech
                          : voiceState.liveTranscript.isNotEmpty
                              ? voiceState.liveTranscript
                              : (isRussian
                                  ? 'Скажите: «Эй Радар, впереди ДПС» или «Сколько осталось?»'
                                  : isUzbek
                                      ? 'Ayting: «Hey Radar, o\'ngda YPX turibdi» yoki «Qancha qoldi?»'
                                      : 'Say: "Hey Radar, police patrol ahead" or "Show radars"'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: voiceState.lastResult != null ? const Color(0xFF34C759) : Colors.white,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Quick Simulator / Voice Test Prompts
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isRussian ? 'БЫСТРЫЕ ГОЛОСОВЫЕ КОМАНДЫ (НАЖМИТЕ ДЛЯ ПРОВЕРКИ):' : isUzbek ? 'TEZKOR OVOZLI BUYRUQLAR (TEKSHIRISH UCHUN BOSING):' : 'QUICK VOICE COMMANDS:',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.45),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickChips.map((phrase) {
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      ref.read(voiceCopilotProvider.notifier).processVoiceCommand(phrase);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(CupertinoIcons.mic_fill, size: 12, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            phrase,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // 5. Mic Control Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: voiceState.isListening ? const Color(0xFFFF3B30) : AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    if (voiceState.isListening) {
                      ref.read(voiceCopilotProvider.notifier).stopListening();
                    } else {
                      ref.read(voiceCopilotProvider.notifier).startListening();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        voiceState.isListening ? CupertinoIcons.stop_fill : CupertinoIcons.mic_fill,
                        color: voiceState.isListening ? Colors.white : Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        voiceState.isListening
                            ? (isRussian ? 'Остановить запись' : isUzbek ? 'Tinglashni to\'xtatish' : 'Stop Listening')
                            : (isRussian ? 'Нажмите и говорите' : isUzbek ? 'Bosing va gapiring' : 'Tap & Speak'),
                        style: TextStyle(
                          color: voiceState.isListening ? Colors.white : Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
