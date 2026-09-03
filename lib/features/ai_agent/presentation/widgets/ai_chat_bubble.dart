import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/features/ai_agent/domain/models/ai_response.dart';
import 'package:navigator/features/ai_agent/presentation/widgets/ai_insight_card.dart';

class AiChatBubble extends StatelessWidget {
  final AiResponse message;
  final ValueChanged<String>? onSuggestionTapped;

  const AiChatBubble({
    super.key,
    required this.message,
    this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (message.isUser) {
      return _buildUserBubble(isDark);
    } else {
      return _buildAiBubble(isDark);
    }
  }

  Widget _buildUserBubble(bool isDark) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, left: 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.primary : const Color(0xFF007AFF),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? AppColors.primary : const Color(0xFF007AFF)).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isDark ? Colors.black : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14.5,
          ),
        ),
      ),
    );
  }

  Widget _buildAiBubble(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final brandColor = isDark ? AppColors.primary : const Color(0xFF007AFF);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16, right: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // AI Avatar Icon
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: brandColor.withOpacity(0.18),
                  ),
                  child: Icon(
                    CupertinoIcons.sparkles,
                    color: brandColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),

                // AI Response Body
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                      border: Border.all(
                        color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14.5,
                            height: 1.4,
                          ),
                        ),
                        if (message.cardType != AiCardType.none)
                          AiInsightCard(response: message),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Suggestions Chips
            if (message.suggestions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 42, top: 8),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: message.suggestions.map((sug) {
                    return ActionChip(
                      label: Text(sug),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: brandColor,
                        fontWeight: FontWeight.w700,
                      ),
                      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                      side: BorderSide(
                        color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      onPressed: () => onSuggestionTapped?.call(sug),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
