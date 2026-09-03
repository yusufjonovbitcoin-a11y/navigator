import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/constants/app_typography.dart';
import 'package:navigator/features/map_radar/domain/models/radar_point.dart';

class NextRadarBanner extends StatelessWidget {
  final RadarPoint radar;
  final double distanceMeters;
  final bool isOverSpeed;
  final VoidCallback onTestVoice;

  const NextRadarBanner({
    super.key,
    required this.radar,
    required this.distanceMeters,
    required this.isOverSpeed,
    required this.onTestVoice,
  });

  @override
  Widget build(BuildContext context) {
    final distInt = distanceMeters.round();
    final alertColor = isOverSpeed ? const Color(0xFFFF3B30) : const Color(0xFFFF9500); // Apple iOS Alert Red & Orange

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: alertColor.withOpacity(0.6),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: alertColor.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // iOS Pulsating Radar Indicator
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: alertColor.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: alertColor.withOpacity(0.4), width: 1),
                ),
                child: Center(
                  child: Icon(
                    CupertinoIcons.camera_fill,
                    color: alertColor,
                    size: 22,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(begin: const Offset(0.92, 0.92), end: const Offset(1.08, 1.08), duration: 700.ms),
              const SizedBox(width: 14),

              // Title and Address
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            radar.type.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: alertColor,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Text(
                            '${radar.speedLimit} km/h',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (isOverSpeed)
                      const Text(
                        "⚠️ Shtraf to'lagingiz kelmasa sekinroq yuring!",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xFFFF453A),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      )
                    else
                      Text(
                        radar.address ?? radar.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Distance Countdown & Speaker Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${distInt}m',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: alertColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: onTestVoice,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.speaker_2_fill, color: AppColors.primary, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Voice',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
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
}
