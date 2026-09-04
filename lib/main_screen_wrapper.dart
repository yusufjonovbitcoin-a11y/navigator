import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navigator/core/constants/app_colors.dart';
import 'package:navigator/core/localization/app_localizations.dart';
import 'package:navigator/features/ai_agent/presentation/screens/ai_agent_screen.dart';
import 'package:navigator/features/categories/presentation/screens/categories_hub_screen.dart';
import 'package:navigator/features/map_radar/presentation/screens/home_map_screen.dart';
import 'package:navigator/features/profile/presentation/screens/profile_screen.dart';
import 'package:navigator/features/reports/presentation/screens/reports_screen.dart';
import 'package:navigator/features/settings/presentation/providers/settings_provider.dart';

final currentTabProvider = StateProvider<int>((ref) => 0);

class MainScreenWrapper extends ConsumerWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currentTabProvider);
    final settings = ref.watch(settingsNotifierProvider);
    final isDark = settings.isDarkMode;
    final tr = AppLocalizations.of(context);

    final screens = const [
      HomeMapScreen(),
      AiAgentScreen(),
      CategoriesHubScreen(),
      ReportsScreen(),
      ProfileScreen(),
    ];

    final tabItems = [
      (CupertinoIcons.compass, CupertinoIcons.compass_fill, tr.tr('tab_home')),
      (CupertinoIcons.sparkles, CupertinoIcons.sparkles, tr.tr('tab_ai')),
      (CupertinoIcons.plus_circle, CupertinoIcons.plus_circle_fill, tr.tr('tab_add')),
      (CupertinoIcons.chart_bar_square, CupertinoIcons.chart_bar_square_fill, tr.tr('tab_reports')),
      (CupertinoIcons.person_crop_circle, CupertinoIcons.person_crop_circle_fill, tr.tr('tab_profile')),
    ];

    final activeColor = isDark ? AppColors.primary : const Color(0xFF007AFF);
    final inactiveColor = isDark ? AppColors.textSecondary.withOpacity(0.7) : const Color(0xFF8E8E93);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentTab,
        children: screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A).withOpacity(0.78) : Colors.white.withOpacity(0.88),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.white.withOpacity(0.12) : const Color(0xFFE5E5EA),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(tabItems.length, (idx) {
                final isSelected = currentTab == idx;
                final item = tabItems[idx];

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(currentTabProvider.notifier).state = idx;
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          isSelected ? item.$2 : item.$1,
                          color: isSelected ? activeColor : inactiveColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.$3,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? activeColor : inactiveColor,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
