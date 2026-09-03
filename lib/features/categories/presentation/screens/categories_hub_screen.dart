import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/features/map_radar/presentation/providers/map_placement_provider.dart';
import 'package:navigator/features/map_radar/presentation/providers/parking_zone_provider.dart';
import 'package:navigator/features/map_radar/presentation/widgets/add_custom_object_sheet.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';
import 'package:navigator/main_screen_wrapper.dart';

class CategoriesHubScreen extends ConsumerWidget {
  const CategoriesHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(settingsNotifierProvider).isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subtextColor = isDark ? Colors.white60 : const Color(0xFF8E8E93);
    final cardBg = isDark ? const Color(0xFF1E293B).withOpacity(0.95) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA);
    final headerBg = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF2F2F7);

    final rows = [
      (
        id: '1',
        title: 'GAI / YPX',
        category: 'Patrul & Post',
        icon: CupertinoIcons.shield_fill,
        color: const Color(0xFF007AFF),
        actionText: '+ Qo\'shish',
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(mapPlacementProvider.notifier).startPlacing(CustomObjectType.gai);
          ref.read(currentTabProvider.notifier).state = 0;
        },
      ),
      (
        id: '2',
        title: 'Radar',
        category: 'Tezlik nazorati',
        icon: CupertinoIcons.dot_radiowaves_left_right,
        color: const Color(0xFFFF9500),
        actionText: '+ Qo\'shish',
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(mapPlacementProvider.notifier).startPlacing(CustomObjectType.radar);
          ref.read(currentTabProvider.notifier).state = 0;
        },
      ),
      (
        id: '3',
        title: 'Kamera',
        category: 'Statsionar',
        icon: CupertinoIcons.camera_fill,
        color: const Color(0xFFFF3B30),
        actionText: '+ Qo\'shish',
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(mapPlacementProvider.notifier).startPlacing(CustomObjectType.kamera);
          ref.read(currentTabProvider.notifier).state = 0;
        },
      ),
      (
        id: '4',
        title: 'Parkovka',
        category: '4 burchakli hudud',
        icon: CupertinoIcons.placemark_fill,
        color: const Color(0xFF34C759),
        actionText: '🅿️ Chizish',
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(parkingZoneProvider.notifier).toggleDrawingMode();
          ref.read(currentTabProvider.notifier).state = 0;
        },
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F19) : const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Obyekt Qo\'shish',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: textColor,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Table Container (Jadval)
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(
                  children: [
                    // Table Header Row (Jadval boshi)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      color: headerBg,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              'OBYEKT',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: subtextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'TURI',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: subtextColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'AMAL',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: subtextColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderColor),

                    // Table Data Rows (Jadval qatorlari)
                    ...rows.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final row = entry.value;
                      final isLast = idx == rows.length - 1;

                      return Column(
                        children: [
                          InkWell(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              row.onTap();
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              child: Row(
                                children: [
                                  // 1. Obyekt (Icon + Name)
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: row.color.withOpacity(0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(row.icon, color: row.color, size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            row.title,
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: textColor,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 2. Turi (Category)
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      row.category,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: subtextColor,
                                      ),
                                    ),
                                  ),

                                  // 3. Amal (Action Button)
                                  Expanded(
                                    flex: 3,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: row.color.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: row.color.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          row.actionText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w800,
                                            color: row.color,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!isLast) Divider(height: 1, color: borderColor),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
