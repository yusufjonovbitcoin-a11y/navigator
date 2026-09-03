import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/features/map_radar/presentation/providers/parking_zone_provider.dart';
import 'package:navigator/features/map_radar/presentation/widgets/save_parking_dialog.dart';

class ParkingDrawingHud extends ConsumerWidget {
  const ParkingDrawingHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parkingZoneProvider);
    final notifier = ref.read(parkingZoneProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pointsCount = state.draftPoints.length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A).withOpacity(0.92) : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF00E5FF).withOpacity(0.4) : const Color(0xFF007AFF).withOpacity(0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.primary : const Color(0xFF007AFF)).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.primary : const Color(0xFF007AFF)).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          CupertinoIcons.pencil_ellipsis_rectangle,
                          color: isDark ? AppColors.primary : const Color(0xFF007AFF),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🅿️ Parkovka Chizish Rejimi',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              pointsCount == 0
                                  ? 'Xaritaga bosing: 4 ta burchak belgilang'
                                  : pointsCount < 3
                                      ? '$pointsCount ta nuqta qo\'yildi (kamida 3-4 ta)'
                                      : '$pointsCount ta burchakli hudud tayyor!',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: pointsCount >= 3
                                    ? const Color(0xFF34C759)
                                    : (isDark ? Colors.white60 : const Color(0xFF64748B)),
                                fontWeight: pointsCount >= 3 ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Exit Button
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          notifier.toggleDrawingMode();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(CupertinoIcons.clear, color: Color(0xFFFF3B30), size: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Undo Button
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: pointsCount > 0
                                ? () {
                                    HapticFeedback.selectionClick();
                                    notifier.undoLastPoint();
                                  }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.arrow_uturn_left,
                                  size: 14,
                                  color: pointsCount > 0
                                      ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Orqaga',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: pointsCount > 0
                                        ? (isDark ? Colors.white : const Color(0xFF1C1C1E))
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Clear Button
                      Expanded(
                        child: SizedBox(
                          height: 36,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFF2F2F7),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: pointsCount > 0
                                ? () {
                                    HapticFeedback.selectionClick();
                                    notifier.clearDraft();
                                  }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.trash,
                                  size: 14,
                                  color: pointsCount > 0 ? const Color(0xFFFF3B30) : Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Tozalash',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: pointsCount > 0 ? const Color(0xFFFF3B30) : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Save Button
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          height: 36,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            color: pointsCount >= 3 ? const Color(0xFF34C759) : Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            onPressed: pointsCount >= 3
                                ? () {
                                    HapticFeedback.mediumImpact();
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const SaveParkingDialog(),
                                    );
                                  }
                                : null,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(CupertinoIcons.checkmark_alt, size: 16, color: Colors.white),
                                SizedBox(width: 4),
                                Text(
                                  'Saqlash',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
