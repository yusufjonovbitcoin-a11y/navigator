import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navigator/core/constants/app_colors.dart';

class VoiceWaveIndicator extends StatelessWidget {
  const VoiceWaveIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final delayMs = index * 120;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleY(
              begin: 0.3,
              end: 1.5,
              duration: 500.ms,
              delay: delayMs.ms,
              curve: Curves.easeInOut,
            );
      }),
    );
  }
}
