import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/ai_agent/presentation/providers/ai_agent_provider.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/ai_chat_bubble.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/voice_assistant_overlay.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/voice_wave_indicator.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class AiAgentScreen extends ConsumerStatefulWidget {
  const AiAgentScreen({super.key});

  @override
  ConsumerState<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends ConsumerState<AiAgentScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage([String? customText]) {
    final text = customText ?? _textController.text;
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _textController.clear();

    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 150,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _openVoiceCopilotOverlay() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const VoiceAssistantOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final chatState = ref.watch(aiChatProvider);

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);

    final quickPrompts = [
      tr.tr('prompt_1'),
      tr.tr('prompt_2'),
      tr.tr('prompt_3'),
      tr.tr('prompt_4'),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF0072FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: brandColor.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(CupertinoIcons.sparkles, color: Colors.black, size: 16),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr.tr('ai_agent_title'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF34C759),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Online • Siri Traffic Copilot',
                      style: TextStyle(fontSize: 10.5, color: subtextColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Siri Hands-free Orb Button
          GestureDetector(
            onTap: _openVoiceCopilotOverlay,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF2D55), Color(0xFF5856D6), Color(0xFF007AFF)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5856D6).withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(CupertinoIcons.waveform_path, color: Colors.white, size: 15),
                  SizedBox(width: 4),
                  Text(
                    'Hey Radar',
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Quick Suggested Prompts Row (iOS Pills)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: quickPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => _sendMessage(prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? 0.1 : 0.03),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Text(
                        prompt,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 2. Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: chatState.messages.length + (chatState.isThinking ? 1 : 0),
              itemBuilder: (context, idx) {
                if (idx < chatState.messages.length) {
                  final msg = chatState.messages[idx];
                  return AiChatBubble(
                    message: msg,
                    onSuggestionTapped: (sug) => _sendMessage(sug),
                  );
                } else {
                  // Thinking Indicator
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        CupertinoActivityIndicator(color: brandColor, radius: 10),
                        const SizedBox(width: 10),
                        Text(
                          'AI yo\'l harakati va radarlarni tahlil qilmoqda...',
                          style: TextStyle(fontSize: 12, color: subtextColor),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          // 3. Voice Recording Banner (if active)
          if (chatState.isListening)
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFFFF3B30).withOpacity(0.2),
                  child: Row(
                    children: [
                      const VoiceWaveIndicator(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          chatState.speechBuffer.isEmpty
                              ? tr.tr('listening')
                              : chatState.speechBuffer,
                          style: const TextStyle(color: Color(0xFFFF3B30), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // 4. Map-style Search Input Bar
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.92),
                  border: Border(
                    top: BorderSide(
                      color: isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFE5E5EA),
                      width: 0.8,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Text Field Container (clean, uniform background, no search icon)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: _focusNode.hasFocus
                                ? const Color(0xFF007AFF)
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _textController,
                            focusNode: _focusNode,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              filled: false,
                              fillColor: Colors.transparent,
                              hintText: tr.tr('type_a_message'),
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white.withOpacity(0.45) : const Color(0xFF8E8E93),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onSubmitted: (val) => _sendMessage(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Dynamic Action Button (Mic -> Send button when text is entered)
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: _textController,
                      builder: (context, val, _) {
                        final hasText = val.text.trim().isNotEmpty;

                        if (hasText) {
                          // Send Button
                          return GestureDetector(
                            onTap: () => _sendMessage(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: brandColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: brandColor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_up,
                                color: isDark ? Colors.black : Colors.white,
                                size: 20,
                              ),
                            ),
                          );
                        } else {
                          // Microphone Button
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              ref.read(aiChatProvider.notifier).toggleVoiceRecording();
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: chatState.isListening
                                    ? const Color(0xFFFF3B30)
                                    : (isDark ? Colors.white.withOpacity(0.1) : const Color(0xFFF2F2F7)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFE5E5EA),
                                  width: 0.8,
                                ),
                              ),
                              child: Icon(
                                chatState.isListening ? CupertinoIcons.mic_fill : CupertinoIcons.mic,
                                color: chatState.isListening ? Colors.white : brandColor,
                                size: 20,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
