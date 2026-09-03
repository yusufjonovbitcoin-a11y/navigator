import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_placement_provider.dart';
import 'package:navigator/features/map_radar/presentation/widgets/add_custom_object_sheet.dart';

class MapPlacementHud extends ConsumerWidget {
  const MapPlacementHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapPlacementProvider);
    if (!state.isPlacing || state.activeType == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = state.activeType!;

    final color = type == CustomObjectType.gai
        ? const Color(0xFF007AFF)
        : type == CustomObjectType.radar
            ? const Color(0xFFFF9500)
            : const Color(0xFFFF3B30);

    final title = type == CustomObjectType.gai
        ? 'GAI / YPX joylashtirish'
        : type == CustomObjectType.radar
            ? 'Radarni joylashtirish'
            : 'Kamerani joylashtirish';

    final icon = type == CustomObjectType.gai
        ? CupertinoIcons.shield_fill
        : type == CustomObjectType.radar
            ? CupertinoIcons.dot_radiowaves_left_right
            : CupertinoIcons.camera_fill;

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
                border: Border.all(color: color.withOpacity(0.5), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Xaritaning istalgan joyiga bosing',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(mapPlacementProvider.notifier).cancelPlacing();
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
            ),
          ),
        ),
      ),
    );
  }
}
