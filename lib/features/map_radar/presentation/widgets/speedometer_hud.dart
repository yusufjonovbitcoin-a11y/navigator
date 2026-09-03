import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:navigator/core/constants/app_typography.dart';

class SpeedometerHud extends StatelessWidget {
  final double currentSpeedKmh;
  final int speedLimitKmh;
  final bool isWarningActive;

  const SpeedometerHud({
    super.key,
    required this.currentSpeedKmh,
    this.speedLimitKmh = 70,
    this.isWarningActive = false,
  });

  Color _getSpeedColor() {
    final diff = currentSpeedKmh - speedLimitKmh;
    if (diff > 5) {
      return const Color(0xFFFF3B30); // Apple iOS Red
    } else if (diff > -5 && diff <= 5) {
      return const Color(0xFFFF9500); // Apple iOS Orange
    } else {
      return const Color(0xFF34C759); // Apple iOS Green
    }
  }

  @override
  Widget build(BuildContext context) {
    final speedColor = _getSpeedColor();
    final speedInt = currentSpeedKmh.round();

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
              color: isWarningActive ? speedColor : Colors.white.withOpacity(0.15),
              width: isWarningActive ? 2 : 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: isWarningActive ? speedColor.withOpacity(0.35) : Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: isWarningActive ? 2 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // European/Apple standard Speed limit circular badge
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFFF3B30), width: 4.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$speedLimitKmh',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Current Speed Digital HUD
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$speedInt',
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: speedColor,
                          height: 1.0,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'KM/H',
                        style: AppTypography.hudLabel.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: speedColor.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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
