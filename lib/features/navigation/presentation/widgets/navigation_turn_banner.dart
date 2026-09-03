import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:navigator/features/navigation/domain/models/navigation_step.dart';

class NavigationTurnBanner extends StatelessWidget {
  final NavigationStep? step;
  final double distanceRemainingMeters;

  const NavigationTurnBanner({
    super.key,
    required this.step,
    required this.distanceRemainingMeters,
  });

  @override
  Widget build(BuildContext context) {
    if (step == null) return const SizedBox.shrink();

    final distStr = distanceRemainingMeters > 1000
        ? '${(distanceRemainingMeters / 1000).toStringAsFixed(1)} km'
        : '${distanceRemainingMeters.round()} m';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withOpacity(0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF34C759).withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF34C759).withOpacity(0.25),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Apple Maps Green Turn Arrow Box
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34C759), Color(0xFF30D158)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF34C759).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  step!.icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 14),

              // Distance and Next Maneuver Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      distStr,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF34C759),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      step!.instruction,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
