import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/services/driving_behavior_service.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

class DrivingTelematicsCard extends ConsumerWidget {
  const DrivingTelematicsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drivingState = ref.watch(drivingBehaviorProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final lang = settings.language.code;
    final isUzbek = lang == 'uz';
    final isRussian = lang == 'ru';

    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF64748B);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.82) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.14) : const Color(0xFFE5E5EA),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Apple Health Activity Icon
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF34C759).withOpacity(0.4)),
                    ),
                    child: const Icon(CupertinoIcons.waveform_path_ecg, color: Color(0xFF34C759), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRussian
                              ? 'Анализ стиля вождения (Акселерометр)'
                              : isUzbek
                                  ? 'Xatti-harakatlar tahlili (Akselerometr)'
                                  : 'Driving Telematics & Behavior',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isRussian
                              ? 'Еженедельный AI отчет и телеметрия G-Force'
                              : isUzbek
                                  ? 'Haftalik AI hisoboti va G-kuch telemetriyasi'
                                  : 'Weekly AI report & G-force metrics',
                          style: TextStyle(
                            fontSize: 11,
                            color: subtextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34C759).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF34C759)),
                    ),
                    child: Text(
                      '${drivingState.safetyScore.toInt()}/100',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF34C759),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Weekly AI Summary Quote Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.primary.withOpacity(0.12),
                            const Color(0xFF0072FF).withOpacity(0.06),
                          ]
                        : [
                            const Color(0xFF007AFF).withOpacity(0.08),
                            const Color(0xFF34C759).withOpacity(0.06),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.primary.withOpacity(0.25) : const Color(0xFF007AFF).withOpacity(0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.quote_bubble_fill,
                      color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        drivingState.getWeeklySummary(lang),
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // 4 Real-time Sensor Metric Chips
              Row(
                children: [
                  Expanded(
                    child: _buildSensorChip(
                      icon: CupertinoIcons.forward_fill,
                      title: isRussian ? 'Ускорения' : isUzbek ? 'Tezlanish' : 'Rapid Accel',
                      value: '${drivingState.rapidAccelerationCount}',
                      color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSensorChip(
                      icon: CupertinoIcons.hand_raised_fill,
                      title: isRussian ? 'Торможения' : isUzbek ? 'Tormozlar' : 'Harsh Brake',
                      value: '${drivingState.harshBrakingCount}',
                      color: drivingState.harshBrakingCount == 0 ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSensorChip(
                      icon: CupertinoIcons.arrow_turn_up_right,
                      title: isRussian ? 'Повороты' : isUzbek ? 'Burilish' : 'Cornering',
                      value: '${drivingState.sharpCorneringCount}',
                      color: drivingState.sharpCorneringCount == 0 ? const Color(0xFF34C759) : const Color(0xFFFF9500),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSensorChip(
                      icon: CupertinoIcons.leaf_arrow_circlepath,
                      title: isRussian ? 'Экономия' : isUzbek ? 'Yoqilg\'i' : 'Eco Save',
                      value: '+${drivingState.fuelSavedPercentage.toInt()}%',
                      color: const Color(0xFF34C759),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorChip({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE5E5EA),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 9.5,
              color: isDark ? Colors.white.withOpacity(0.6) : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
